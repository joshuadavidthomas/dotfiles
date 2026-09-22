# /// script
# requires-python = ">=3.11"
# dependencies = ["python-dotenv==1.2.2", "packaging>=24"]
# ///
"""Personal mise layouts. All generated state lives outside project repositories."""
from __future__ import annotations

import argparse
import fcntl
import hashlib
import json
import os
from pathlib import Path
import re
import shlex
import shutil
import subprocess
import sys
import tomllib
import time

from packaging.specifiers import SpecifierSet

from dotenv import dotenv_values


def log_status(message):
    """Match mise's dim prefix without putting terminal escapes in JSON or logs."""
    styled = (sys.stderr.isatty() and os.environ.get("TERM") != "dumb"
              and not os.environ.get("NO_COLOR") and os.environ.get("CLICOLOR") != "0")
    prefix = "\033[2mmise\033[0m" if styled else "mise"
    print(f"{prefix} {message}", file=sys.stderr, flush=True)


def run(argv, cwd, env=None):
    return subprocess.run(argv, cwd=cwd, env=env, stdin=subprocess.DEVNULL,
                          stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)


def fingerprint(paths):
    h = hashlib.sha256()
    for path in sorted(set(paths)):
        h.update(str(path).encode())
        h.update(path.read_bytes() if path.is_file() else b"<missing>")
    return h.hexdigest()


def load_json(path):
    try:
        return json.loads(path.read_text())
    except (OSError, ValueError):
        return {}


def write_json(path, value):
    temp = path.with_suffix(".tmp")
    temp.write_text(json.dumps(value))
    temp.chmod(0o600)
    temp.replace(path)


def ancestors(cwd):
    """Don't cross a checkout boundary, including a Git worktree's .git file."""
    out = []
    for path in [cwd, *cwd.parents]:
        out.append(path)
        if (path / ".git").exists() or path == Path.home():
            break
    return out


def script_metadata(path):
    try:
        text = path.read_text()
        match = re.search(r"(?m)^# /// script\s*\n(.*?)^# ///\s*$", text, re.S)
        if not match:
            return None
        return tomllib.loads("\n".join(line[2:] if line.startswith("# ") else line[1:]
                                     for line in match[1].splitlines()))
    except (OSError, UnicodeError, ValueError):
        return None


class Layout:
    def __init__(self, cwd, *, path_pass=False):
        self.path_pass = path_pass
        self.cwd = cwd.resolve()
        self.home = Path.home()
        self.chain = ancestors(self.cwd)
        self.cache = Path(os.environ.get("XDG_CACHE_HOME", self.home / ".cache")) / "mise/layouts"
        self.cache.mkdir(parents=True, exist_ok=True, mode=0o700)
        self.env = {}
        self.paths = []
        self.watch = set()
        self.messages = []
        self.base_env = os.environ.copy()
        # uv run's helper environment must never become the target environment.
        self.base_env.pop("VIRTUAL_ENV", None)
        self.base_env.pop("UV_ACTIVE", None)
        self.options = {}
        options_path = Path(__file__).parents[1] / "layouts.toml"
        self.watch.add(options_path)
        if options_path.exists():
            self.options = tomllib.loads(options_path.read_text())

    def log(self, prefix, message):
        message = f"{prefix}: {message}"
        self.messages.append(message)
        if not self.path_pass:
            log_status(message)

    def check_message(self, root, kind, cached):
        if kind == "uv":
            prefix = "layout uv"
            message = "Project lock file unchanged; using existing environment" if cached else "Syncing with project lock file"
        elif kind == "requirements":
            prefix = "layout uv"
            message = "requirements.txt unchanged; using existing environment" if cached else "Syncing with requirements.txt"
        elif kind in {"npm", "pnpm", "bun"}:
            prefix = f"layout {kind}"
            message = "Project dependencies are up to date" if cached else "Installing project dependencies"
        elif kind == "script-sync":
            prefix = "layout uvscript"
            message = f"{root.name} unchanged; using existing environment" if cached else f"Syncing dependencies for {root.name}"
        elif kind.startswith("lint-"):
            prefix = "dotenv"
            message = "Lint check unchanged" if cached else "Checking environment file"
        else:
            prefix = f"layout {kind}"
            message = "Check unchanged" if cached else "Checking setup"
        self.log(prefix, message)

    def alias_help(self, prefix, descriptions):
        self.log(prefix, "Aliases:")
        for usage, description in descriptions:
            self.log(prefix, f"  {usage} - {description}")

    def bucket(self, root, kind):
        key = hashlib.sha256((str(root) + "\0" + kind).encode()).hexdigest()[:24]
        path = self.cache / key
        path.mkdir(exist_ok=True, mode=0o700)
        return path

    def once(self, root, kind, sources, outputs, action):
        """Serialize work, and record successful post-install input hashes only."""
        self.watch.update(sources)
        self.watch.update(outputs)
        bucket = self.bucket(root, kind)
        with (bucket / "lock").open("a") as lock:
            fcntl.flock(lock, fcntl.LOCK_EX)
            stamp = bucket / "state.json"
            current = fingerprint(sources)
            if load_json(stamp).get("fingerprint") == current and all(p.exists() for p in outputs):
                self.check_message(root, kind, cached=True)
                return True
            self.check_message(root, kind, cached=False)
            try:
                action()
            except (OSError, RuntimeError) as exc:
                prefix = "layout uv" if kind in {"uv", "requirements"} else ("layout uvscript" if kind == "script-sync" else f"layout {kind}")
                self.log(prefix, str(exc))
                return False
            write_json(stamp, {"fingerprint": fingerprint(sources)})
            return True

    def command(self, argv, root, extra=None, *, visible=False):
        env = self.base_env | self.env | (extra or {})
        if visible:
            result = subprocess.run(argv, cwd=root, env=env, stdin=subprocess.DEVNULL,
                                    stdout=sys.stderr, stderr=sys.stderr, text=True)
        else:
            result = run(argv, root, env)
        if result.returncode:
            display = [str(Path(a).relative_to(root)) if a.startswith(str(root) + os.sep) else a for a in argv]
            raise RuntimeError(f"{shlex.join(display)} failed (exit {result.returncode})")
        if visible:
            return ""
        return result.stdout.strip()

    def dotenv(self):
        project = next((p / ".env" for p in self.chain if (p / ".env").is_file()), None)
        self.watch.update(p / ".env" for p in self.chain)
        self.watch.add(self.home / ".env")
        files = list(dict.fromkeys(p for p in [project, self.home / ".env"] if p and p.is_file()))
        for path in files:
            def lint(path=path):
                result = run(["dotenv-linter", "--quiet", "check", str(path)], path.parent, self.base_env)
                if result.returncode:
                    self.log("dotenv", f"dotenv-linter found issues in {path.name}; run dotenv-linter on that file for details")
            self.once(path.parent, "lint-" + path.name, [path], [], lint)
            # Match project first, home second; interpolate using the preceding environment.
            before = os.environ.copy()
            try:
                os.environ.update(self.env)
                self.env.update({k: v for k, v in dotenv_values(path).items() if v is not None})
            finally:
                os.environ.clear()
                os.environ.update(before)

    def exclusions(self):
        root = next((p for p in self.chain if (p / ".git").exists()), None)
        if root is None:
            return
        source = root / ".gitignore.local"
        self.watch.add(source)
        result = run(["git", "rev-parse", "--git-path", "info/exclude"], root)
        if result.returncode:
            return
        target = Path(result.stdout.strip())
        if not target.is_absolute():
            target = root / target
        begin = "# >>> mise layouts .gitignore.local"
        end = "# <<< mise layouts .gitignore.local"
        old = target.read_text() if target.exists() else ""
        clean = re.sub(re.escape(begin) + r"\n.*?" + re.escape(end) + r"\n?", "", old, flags=re.S)
        new = clean
        if source.exists():
            if new and not new.endswith("\n"):
                new += "\n"
            new += begin + "\n.gitignore.local\n" + source.read_text().rstrip("\n") + "\n" + end + "\n"
        if new != old:
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text(new)

    def wrappers(self, root, kind, commands):
        folder = self.bucket(root, "aliases-" + kind) / "bin"
        folder.mkdir(exist_ok=True)
        for stale in folder.iterdir():
            if stale.name not in commands:
                stale.unlink()
        for name, argv in commands.items():
            executable = shutil.which(argv[0], path=self.base_env.get("PATH")) or argv[0]
            content = "#!/bin/sh\n" + "cd " + shlex.quote(str(root)) + " || exit\n"
            if self.env.get("VIRTUAL_ENV"):
                content += "export VIRTUAL_ENV=" + shlex.quote(self.env["VIRTUAL_ENV"]) + "\n"
                content += 'export PATH="$VIRTUAL_ENV/bin:$PATH"\n'
            content += "exec " + shlex.join([executable, *argv[1:]]) + ' "$@"\n'
            target = folder / name
            if not target.exists() or target.read_text() != content:
                target.write_text(content)
                target.chmod(0o700)
        self.paths.append(str(folder))

    def python(self):
        root = next((p for p in self.chain if (p / "uv.lock").exists() or (p / "requirements.txt").exists()), None)
        if root is None:
            return False
        # A uv workspace owns the environment even when entered through a member.
        for parent in self.chain[self.chain.index(root) + 1:]:
            pyproject = parent / "pyproject.toml"
            if pyproject.exists() and (parent / "uv.lock").exists():
                data = tomllib.loads(pyproject.read_text())
                if "workspace" in data.get("tool", {}).get("uv", {}):
                    root = parent
        is_uv = (root / "uv.lock").exists()
        configured = self.env.get("UV_PROJECT_ENVIRONMENT", self.base_env.get("UV_PROJECT_ENVIRONMENT", ".venv")) if is_uv else ".venv"
        venv = Path(configured)
        if not venv.is_absolute():
            venv = root / venv
        sources = [root / "pyproject.toml", root / "uv.lock", root / "requirements.txt", root / ".python-version", root / "uv.toml", venv / "pyvenv.cfg"]
        if is_uv and (root / "pyproject.toml").exists():
            workspace = tomllib.loads((root / "pyproject.toml").read_text()).get("tool", {}).get("uv", {}).get("workspace", {})
            for pattern in workspace.get("members", []):
                sources.extend(root.glob(pattern.rstrip("/") + "/pyproject.toml"))
        def install():
            if (venv / "bin/python").exists():
                project_file = root / "pyproject.toml"
                requirement = (tomllib.loads(project_file.read_text()).get("project", {}).get("requires-python", "")
                               if project_file.exists() else "")
                pin_file = root / ".python-version"
                pin = pin_file.read_text().strip() if pin_file.exists() else ""
                constraints = [requirement] if requirement else []
                if re.fullmatch(r"\d+(?:\.\d+){0,2}", pin):
                    constraints.append("==" + pin + (".*" if pin.count(".") < 2 else ""))
                if constraints:
                    version = self.command([str(venv / "bin/python"), "-c", "import platform; print(platform.python_version())"], root)
                    if any(version not in SpecifierSet(c) for c in constraints):
                        backup = self.bucket(root, "venv-backups") / ("venv-" + str(time.time_ns()))
                        self.log("layout uv", f"Python {version} does not satisfy {', '.join(constraints)}")
                        self.log("layout uv", f"Preserving old environment at {backup}")
                        shutil.move(str(venv), str(backup))
            if not (venv / "bin/python").exists():
                self.log("layout uv", "No virtual environment exists.")
                self.log("layout uv", "Executing `uv venv` to create one.")
                self.command(["uv", "venv", "--seed", str(venv)], root, visible=True)
            if is_uv:
                self.command(["uv", "sync"], root, visible=True)
            else:
                self.command(["uv", "pip", "install", "--python", str(venv / "bin/python"), "-r", "requirements.txt"], root, visible=True)
        if not self.once(root, "uv" if is_uv else "requirements", sources, [venv / "bin/python"], install):
            return True
        self.env.update(VIRTUAL_ENV=str(venv), UV_ACTIVE="1")
        self.paths.append(str(venv / "bin"))
        commands = {"uvi": ["uv", "pip", "install"], "uvl": ["uv", "pip", "compile"], "uvr": ["uv", "run"],
                    "uvs": ["uv", "pip", "install", "-r", "requirements.txt"]}
        if is_uv:
            commands = {"uv" + k: ["uv", *v] for k, v in {
                "a": ["add"], "e": ["export"], "i": ["pip", "install"], "l": ["lock"],
                "r": ["run"], "s": ["sync"], "t": ["tree"]}.items()}
        self.wrappers(root, "python", commands)
        if is_uv:
            descriptions = [
                ("uva [packages...]", "Add package(s) as project dependency"),
                ("uve", "Export project requirements"),
                ("uvi [packages...]", "Install package(s) in project environment"),
                ("uvl", "Lock project dependencies"),
                ("uvr [args...]", "Run Python in project environment"),
                ("uvs", "Sync project environment"),
                ("uvt", "Show project dependency tree"),
            ]
        else:
            descriptions = [
                ("uvi [packages...]", "Install package(s) in project environment"),
                ("uvl [pyproject.toml|requirements.in]", "Lock project dependencies"),
                ("uvr [args...]", "Run Python in project environment"),
                ("uvs", "Sync project environment"),
            ]
        self.alias_help("layout uv", descriptions)
        return True

    def javascript(self):
        root = next((p for p in self.chain if (p / "package.json").exists()), None)
        if root is None:
            return
        for parent in self.chain[self.chain.index(root) + 1:]:
            if (parent / "pnpm-workspace.yaml").exists() or load_json(parent / "package.json").get("workspaces"):
                root = parent
        package = load_json(root / "package.json")
        locks = {"npm": ["package-lock.json", "npm-shrinkwrap.json"], "pnpm": ["pnpm-lock.yaml"], "bun": ["bun.lock", "bun.lockb"]}
        present = [manager for manager, names in locks.items() if any((root / n).exists() for n in names)]
        requested = package.get("packageManager", "").split("@", 1)[0]
        manager = requested or (present[0] if len(present) == 1 else "")
        inputs = [root / "package.json", root / "pnpm-workspace.yaml", root / ".npmrc", root / "bunfig.toml"]
        inputs += [root / name for names in locks.values() for name in names]
        workspaces = package.get("workspaces", [])
        if isinstance(workspaces, dict):
            workspaces = workspaces.get("packages", [])
        for pattern in workspaces:
            if not pattern.startswith("!"):
                inputs.extend(root.glob(pattern.rstrip("/") + "/package.json"))
        # pnpm's workspace manifest and lockfile cover resolution; member manifests
        # must also invalidate the stamp before the lockfile has been regenerated.
        if (root / "pnpm-workspace.yaml").exists():
            for directory, folders, files in os.walk(root):
                folders[:] = [name for name in folders if name not in {"node_modules", ".git", ".venv"}]
                if "package.json" in files:
                    inputs.append(Path(directory) / "package.json")
        self.watch.update(inputs)
        if manager not in locks:
            if len(present) > 1:
                self.log("layout javascript", "multiple JavaScript lockfiles; set packageManager to select one")
            return
        if manager not in present:
            return
        needs_modules = any(package.get(k) for k in ["dependencies", "devDependencies", "optionalDependencies", "workspaces"])
        outputs = [root / "node_modules"] if needs_modules or (root / "pnpm-workspace.yaml").exists() else []
        self.once(root, manager, inputs, outputs, lambda: self.command([manager, "install"], root, visible=True))

    def scripts(self):
        roots = []
        for p in self.chain:
            scripts = [f for f in sorted(p.glob("*.py")) if script_metadata(f) is not None]
            if scripts:
                roots = [(p, scripts)]
                break
        for item in self.options.get("scripts", []):
            root = Path(os.path.expandvars(os.path.expanduser(item["directory"]))).resolve()
            if self.cwd == root or root in self.cwd.parents:
                roots = [(root, sorted(root.glob("*.py")))]
                break
        if not roots:
            return
        root, scripts = roots[0]
        site_paths = []
        pythons = {}
        for script in scripts:
            lock = Path(str(script) + ".lock")
            bucket = self.bucket(script, "script")
            previous = load_json(bucket / "python.json").get("python")
            outputs = [Path(previous)] if previous else [bucket / "not-yet-synced"]
            def install(script=script, bucket=bucket):
                self.command(["uv", "sync", "--script", str(script)], root, visible=True)
                python = self.command(["uv", "python", "find", "--script", str(script)], root)
                write_json(bucket / "python.json", {"python": python})
            if not self.once(script, "script-sync", [script, lock], outputs, install):
                continue
            python = load_json(bucket / "python.json")["python"]
            pythons[script] = python
            paths = json.loads(self.command([python, "-c", "import json,sysconfig; print(json.dumps([sysconfig.get_path('purelib'),sysconfig.get_path('platlib')]))"], root))
            site_paths.extend(paths)
        if site_paths:
            self.log("layout uvscript", "Adding script environments to PYTHONPATH")
            old = self.env.get("PYTHONPATH", self.base_env.get("PYTHONPATH", ""))
            self.env["PYTHONPATH"] = os.pathsep.join(dict.fromkeys([*site_paths, *filter(None, old.split(os.pathsep))]))
            self.checker(root, list(dict.fromkeys(site_paths)))
        operations = {"a": ["add"], "e": ["export"], "l": ["lock"], "r": ["run"], "s": ["sync"], "t": ["tree"]}
        if len(scripts) == 1 and scripts[0] in pythons:
            script = scripts[0]
            commands = {"uv" + k: ["uv", *v, "--script", str(script)] for k, v in operations.items()}
            commands["uvi"] = ["uv", "pip", "install", "--python", pythons[script]]
            self.wrappers(root, "scripts", commands)
            self.alias_help("layout uvscript", [
                ("uva [packages...]", f"Add package(s) as dependency to {script.name}"),
                ("uve", f"Export requirements for {script.name}"),
                ("uvi [packages...]", f"Install package(s) in {script.name}'s environment"),
                ("uvl", f"Lock dependencies for {script.name}"),
                ("uvr [args...]", f"Run {script.name}"),
                ("uvs", f"Sync {script.name}'s environment"),
                ("uvt", f"Show dependency tree for {script.name}"),
            ])
        elif scripts:
            commands = {"uv" + k + "s": ["uv", *v, "--script"] for k, v in operations.items()}
            self.wrappers(root, "scripts", commands)
            folder = self.bucket(root, "aliases-scripts") / "bin"
            content = '#!/bin/sh\ncd ' + shlex.quote(str(root)) + ''' || exit
if [ "$#" -lt 1 ]; then echo 'Usage: uvis script.py packages...' >&2; exit 2; fi
script=$1
shift
python=$(uv python find --script "$script") || exit
exec uv pip install --python "$python" "$@"
'''
            (folder / "uvis").write_text(content)
            (folder / "uvis").chmod(0o700)
            self.alias_help("layout uvscript", [
                ("uvas [script.py] [packages...]", "Add package(s) as dependency to script"),
                ("uves [script.py]", "Export requirements for a script"),
                ("uvis [script.py] [packages...]", "Install package(s) in script's environment"),
                ("uvls [script.py]", "Lock dependencies for a script"),
                ("uvrs [script.py] [args...]", "Run a script"),
                ("uvss [script.py]", "Sync a script's environment"),
                ("uvts [script.py]", "Show dependency tree for a script"),
            ])

    def checker(self, root, paths):
        candidates = [root / "pyrightconfig.json", root / "pyproject.toml"]
        self.watch.update(candidates)
        config = candidates[0] if candidates[0].exists() else candidates[1]
        text = config.read_text() if config.exists() else ""
        missing = [p for p in paths if p not in text]
        if missing:
            # Diagnostic only; never rewrite a project's checker settings.
            name = "Basedpyright" if "[tool.basedpyright]" in text else "Pyright"
            self.log("layout uvscript", f"{name}:")
            self.log("layout uvscript", "  Config missing script paths in executionEnvironments")
            self.log("layout uvscript", "  Missing paths:")
            for path in missing:
                self.log("layout uvscript", f"    * {path}")
            reference = ("https://docs.basedpyright.com/latest/configuration/config-files/#execution-environment-options"
                         if name == "Basedpyright" else "https://github.com/microsoft/pyright/blob/main/docs/configuration.md#execution-environment-options")
            self.log("layout uvscript", f"  Reference: {reference}")

    def watch_files(self):
        # Watch actual inputs, not directory mtimes. Missing inputs must not be
        # returned: mise interprets them as deletions on every prompt. Its native
        # config discovery already detects file creation in cwd and its parents.
        return sorted(str(path) for path in self.watch if path.is_file())

    def result(self):
        for parent in self.chain:
            self.watch.update(parent / name for name in ["uv.lock", "requirements.txt", "package.json"])
        self.dotenv()
        self.exclusions()
        self.python()
        self.javascript()
        self.scripts()
        return {"env": [{"key": k, "value": v} for k, v in self.env.items()],
                "paths": list(dict.fromkeys(self.paths)), "watch_files": self.watch_files(),
                "messages": self.messages}


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--cwd", required=True)
    parser.add_argument("--path-pass", action="store_true")
    args = parser.parse_args()
    try:
        result = Layout(Path(args.cwd), path_pass=args.path_pass).result()
    except Exception as exc:
        # Avoid dumping environment values or command output into the prompt.
        message = f"layout: setup failed ({type(exc).__name__}); run the helper directly to diagnose"
        if not args.path_pass:
            log_status(message)
        result = {"env": [], "paths": [], "watch_files": [], "messages": [message]}
    print(json.dumps(result))

# /// script
# requires-python = ">=3.11"
# dependencies = ["python-dotenv==1.2.2", "packaging>=24"]
# ///
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('layouts', Path(__file__).parents[1] / 'lib/layouts.py')
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)


class LayoutTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.home = Path(self.temp.name).resolve()
        self.root = self.home / 'project with spaces'
        self.root.mkdir()
        subprocess.run(['git', 'init', '-q', str(self.root)], check=True)
        self.calls = []
        self.env_patch = patch.dict(os.environ, {'XDG_CACHE_HOME': str(self.home / 'cache')})
        self.env_patch.start()
        self.addCleanup(self.env_patch.stop)
        self.home_patch = patch.object(Path, 'home', return_value=self.home)
        self.home_patch.start()
        self.addCleanup(self.home_patch.stop)

    def layout(self, cwd=None):
        return mod.Layout(cwd or self.root)

    def test_watches_detect_creation_and_deletion_without_missing_paths(self):
        layout = self.layout()
        target = self.root / 'nested' / 'project' / 'uv.lock'
        layout.watch.add(target)
        self.assertIn(str(self.root), layout.watch_files())
        self.assertTrue(all(Path(p).exists() for p in layout.watch_files()))
        target.parent.mkdir(parents=True)
        self.assertIn(str(target.parent), layout.watch_files())
        target.touch()
        self.assertIn(str(target), layout.watch_files())
        target.unlink()
        self.assertIn(str(target.parent), layout.watch_files())
        self.assertTrue(all(Path(p).exists() for p in layout.watch_files()))

    def test_dotenv_order_interpolation_and_lint(self):
        (self.root / '.env').write_text('LAYOUT_TEST=project\nPROJECT_ONLY=yes\n')
        (self.home / '.env').write_text('LAYOUT_TEST=home\nHOME_COPY=${PROJECT_ONLY}\n')
        def fake_run(argv, cwd, env=None):
            self.calls.append(argv)
            return subprocess.CompletedProcess(argv, 0, '', '')
        with patch.object(mod, 'run', side_effect=fake_run):
            layout = self.layout()
            layout.dotenv()
            self.assertEqual(layout.env['LAYOUT_TEST'], 'home')
            self.assertEqual(layout.env['HOME_COPY'], 'yes')
            self.assertEqual(len(self.calls), 2)
            self.layout().dotenv()
            self.assertEqual(len(self.calls), 2)
            (self.root / '.env').write_text('LAYOUT_TEST=changed\n')
            self.layout().dotenv()
            self.assertEqual(len(self.calls), 3)

    def test_status_ignores_unrelated_renames_but_reports_inputs_and_reentry(self):
        dotenv = self.root / '.env'
        dotenv.write_text('LAYOUT_TEST=initial\n')
        def evaluate(cwd=None):
            layout = self.layout(cwd)
            layout.watch.update([self.root, dotenv, self.root / 'package.json'])
            layout.log('dotenv', 'Lint check unchanged')
            layout.finish_status()
        with patch.dict(os.environ, {'MISE_LAYOUTS_SESSION': 'test-shell'}), \
                patch.object(mod, 'log_status') as output:
            evaluate()
            self.assertEqual(output.call_count, 1)
            output.reset_mock()
            (self.root / 'production.dump').write_text('unrelated')
            (self.root / 'production.dump').rename(self.root / 'db.dump')
            evaluate()
            output.assert_not_called()
            dotenv.write_text('LAYOUT_TEST=changed-value\n')
            evaluate()
            self.assertEqual(output.call_count, 1)
            output.reset_mock()
            (self.root / 'package.json').write_text('{}')
            evaluate()
            self.assertEqual(output.call_count, 1)
            output.reset_mock()
            dotenv.unlink()
            evaluate()
            self.assertEqual(output.call_count, 1)
            output.reset_mock()
            evaluate(self.home)
            evaluate()
            self.assertEqual(output.call_count, 2)
            output.reset_mock()
            with patch.dict(os.environ, {'MISE_LAYOUTS_SESSION': 'another-shell'}):
                evaluate()
            self.assertEqual(output.call_count, 1)

    def test_git_exclusions_preserve_and_remove(self):
        target = self.root / '.git/info/exclude'
        target.write_text('existing-rule\n')
        source = self.root / '.gitignore.local'
        source.write_text('private.txt\n')
        self.layout().exclusions()
        self.assertIn('existing-rule', target.read_text())
        result = subprocess.run(['git', 'check-ignore', 'private.txt'], cwd=self.root, capture_output=True)
        self.assertEqual(result.returncode, 0)
        source.unlink()
        self.layout().exclusions()
        self.assertEqual(target.read_text(), 'existing-rule\n')

    def test_git_worktree(self):
        subprocess.run(['git', '-c', 'user.name=Test', '-c', 'user.email=test@example.com', 'commit', '--allow-empty', '-qm', 'initial'], cwd=self.root, check=True)
        wt = self.home / 'worktree'
        subprocess.run(['git', 'worktree', 'add', '-qb', 'test', str(wt)], cwd=self.root, check=True)
        (wt / '.gitignore.local').write_text('local.txt\n')
        self.layout(wt).exclusions()
        result = subprocess.run(['git', 'check-ignore', 'local.txt'], cwd=wt, capture_output=True)
        self.assertEqual(result.returncode, 0)

    def test_freshness_failure_and_deleted_output(self):
        source = self.root / 'input'
        output = self.root / 'output'
        source.write_text('a')
        def action():
            self.calls.append('run')
            output.touch()
        self.layout().once(self.root, 'test', [source], [output], action)
        cached = self.layout()
        cached.once(self.root, 'test', [source], [output], action)
        self.assertTrue(any('Check unchanged' in m for m in cached.messages))
        self.assertEqual(len(self.calls), 1)
        source.write_text('b')
        def fail():
            raise RuntimeError('expected failure')
        self.assertFalse(self.layout().once(self.root, 'test', [source], [output], fail))
        self.layout().once(self.root, 'test', [source], [output], action)
        output.unlink()
        self.layout().once(self.root, 'test', [source], [output], action)
        self.assertEqual(len(self.calls), 3)

    def test_js_managers_and_workspace(self):
        for manager, lock in [('npm', 'package-lock.json'), ('pnpm', 'pnpm-lock.yaml'), ('bun', 'bun.lock'), ('bun', 'bun.lockb')]:
            with self.subTest(manager=manager, lock=lock):
                root = self.root / lock
                root.mkdir()
                (root / 'package.json').write_text(json.dumps({'packageManager': manager + '@1'}))
                (root / lock).touch()
                (root / 'src').mkdir()
                layout = self.layout(root / 'src')
                with patch.object(layout, 'command') as command:
                    layout.javascript()
                    command.assert_called_once_with([manager, 'install'], root, visible=True)
        (self.root / 'package.json').write_text('{"workspaces":["packages/*"],"packageManager":"pnpm@1"}')
        (self.root / 'pnpm-lock.yaml').touch()
        member = self.root / 'packages/member'
        member.mkdir(parents=True)
        (member / 'package.json').write_text('{}')
        layout = self.layout(member)
        with patch.object(layout, 'command') as command:
            layout.javascript()
            command.assert_called_once_with(['pnpm', 'install'], self.root, visible=True)

    def test_ambiguous_js_skips(self):
        (self.root / 'package.json').write_text('{}')
        (self.root / 'package-lock.json').touch()
        (self.root / 'bun.lock').touch()
        layout = self.layout()
        with patch.object(layout, 'command') as command:
            layout.javascript()
            command.assert_not_called()
            self.assertIn('multiple JavaScript lockfiles', layout.messages[0])

    def test_uv_and_requirements_activation(self):
        for kind in ['uv', 'requirements']:
            with self.subTest(kind=kind):
                root = self.root / kind
                root.mkdir()
                (root / ('uv.lock' if kind == 'uv' else 'requirements.txt')).touch()
                layout = self.layout(root)
                def fake_command(argv, cwd, extra=None, **kwargs):
                    self.calls.append(argv)
                    (root / '.venv/bin').mkdir(parents=True, exist_ok=True)
                    (root / '.venv/bin/python').touch()
                    return ''
                with patch.object(layout, 'command', side_effect=fake_command):
                    layout.python()
                self.assertEqual(layout.env['VIRTUAL_ENV'], str(root / '.venv'))
                aliases = Path(layout.paths[-1])
                self.assertTrue((aliases / 'uvi').exists())
                self.assertTrue((aliases / 'uvs').exists())
                if kind == 'uv':
                    self.assertTrue((aliases / 'uva').exists())
                else:
                    self.assertIn('requirements.txt', (aliases / 'uvs').read_text())

    def test_script_paths_and_aliases(self):
        script = self.root / 'one script.py'
        script.write_text('# /// script\n# dependencies = ["example"]\n# ///\nprint(1)\n')
        python = self.home / 'script-venv/bin/python'
        python.parent.mkdir(parents=True)
        python.touch()
        site = str(self.home / 'script-venv/lib/site-packages')
        def fake_command(argv, cwd, extra=None, **kwargs):
            self.calls.append(argv)
            if argv[:3] == ['uv', 'python', 'find']:
                return str(python)
            if argv[0] == str(python):
                return json.dumps([site, site])
            return ''
        with patch.object(mod.Layout, 'command', side_effect=fake_command):
            layout = self.layout()
            layout.scripts()
            self.assertIn(site, layout.env['PYTHONPATH'])
            self.assertEqual(layout.env['PYTHONPATH'].split(os.pathsep).count(site), 1)
            folder = Path(layout.paths[-1])
            self.assertIn("'" + str(script) + "'", (folder / 'uvr').read_text())
            self.assertIn('--python', (folder / 'uvi').read_text())
            count = sum(c[:2] == ['uv', 'sync'] for c in self.calls)
            self.layout().scripts()
            self.assertEqual(sum(c[:2] == ['uv', 'sync'] for c in self.calls), count)
            second = self.root / 'two.py'
            second.write_text(script.read_text())
            layout = self.layout()
            layout.scripts()
            folder = Path(layout.paths[-1])
            for name in ['uvas', 'uves', 'uvis', 'uvls', 'uvrs', 'uvss', 'uvts']:
                self.assertTrue((folder / name).exists(), name)
            self.assertFalse((folder / 'uva').exists())

    def test_requirements_replaces_incompatible_python_and_keeps_backup(self):
        (self.root / 'requirements.txt').touch()
        (self.root / 'pyproject.toml').write_text('[project]\nrequires-python = ">=3.12,<3.14"\n')
        python = self.root / '.venv/bin/python'
        python.parent.mkdir(parents=True)
        python.write_text('original interpreter')
        (self.root / '.venv/pyvenv.cfg').write_text('version_info = 3.14.5\n')
        def fake_command(argv, cwd, extra=None, **kwargs):
            self.calls.append(argv)
            if argv[0] == str(python):
                return '3.14.5'
            if argv[:2] == ['uv', 'venv']:
                python.parent.mkdir(parents=True)
                python.write_text('compatible interpreter')
            return ''
        layout = self.layout()
        with patch.object(layout, 'command', side_effect=fake_command):
            layout.python()
        self.assertEqual(python.read_text(), 'compatible interpreter')
        backups = list(layout.bucket(self.root, 'venv-backups').glob('*/bin/python'))
        self.assertEqual(len(backups), 1)
        self.assertEqual(backups[0].read_text(), 'original interpreter')
        self.assertTrue(any(c[:2] == ['uv', 'venv'] for c in self.calls))
        self.assertTrue(any(c[:3] == ['uv', 'pip', 'install'] for c in self.calls))

    def test_wrapper_preserves_arguments(self):
        layout = self.layout()
        layout.wrappers(self.root, 'test', {'showargs': ['/usr/bin/printf', '%s\n']})
        result = subprocess.run([str(Path(layout.paths[-1]) / 'showargs'), 'hello world', '$(no-command)'], capture_output=True, text=True)
        self.assertEqual(result.stdout, 'hello world\n$(no-command)\n')


if __name__ == '__main__':
    unittest.main()

#!/usr/bin/env python
from __future__ import annotations

import json
import re
import sys
from collections.abc import Sequence
from dataclasses import dataclass
from enum import Enum


class Shell(str, Enum):
    SH = "sh"
    BASH = "bash"
    ZSH = "zsh"
    KSH = "ksh"
    FISH = "fish"
    COMMAND = "command"

    @property
    def as_ext(self) -> str:
        return f".{self.value}"

    @property
    def shell_name(self) -> str:
        if self == Shell.COMMAND:
            return "bash"
        return self.value


@dataclass
class ShellInfo:
    file_path: str
    filename: str
    expected_shell: str | None

    @classmethod
    def from_path(cls, file_path: str) -> ShellInfo:
        """Create ShellInfo from a file path."""
        filename = file_path.split("/")[-1] if "/" in file_path else file_path

        # Determine expected shell based on extension
        expected_shell = None
        for shell in Shell:
            if filename.endswith(shell.as_ext):
                expected_shell = shell.shell_name
                break

        return cls(
            file_path=file_path, filename=filename, expected_shell=expected_shell
        )


def is_likely_shell_script(file_path: str) -> bool:
    for shell in Shell:
        if file_path.endswith(shell.as_ext):
            return True

    filename = file_path.split("/")[-1] if "/" in file_path else file_path

    if "." not in filename or filename.startswith("."):
        return True

    return False


def check_shebang(content: str, file_path: str) -> list[str]:
    issues = []
    shell_info = ShellInfo.from_path(file_path)

    if shell_info.expected_shell is None:
        if content.strip().startswith("#!/bin/bash") or re.search(
            r"^#!/bin/bash", content, re.MULTILINE
        ):
            issues.append(
                "Use '#!/usr/bin/env bash' instead of '#!/bin/bash' for better portability"
            )
    else:
        shebang_pattern = rf"^#!\s*/bin/{shell_info.expected_shell}\b"
        if re.search(shebang_pattern, content, re.MULTILINE):
            issues.append(
                f"Use '#!/usr/bin/env {shell_info.expected_shell}' instead of '#!/bin/{shell_info.expected_shell}' for better portability"
            )

    return issues


def main(argv: Sequence[str] | None = None) -> int:
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON input: {e}", file=sys.stderr)
        return 1

    tool_name = input_data.get("tool_name", "")
    tool_input = input_data.get("tool_input", {})
    file_path = tool_input.get("file_path", "")

    if not is_likely_shell_script(file_path):
        return 0

    issues = []
    if tool_name == "Write":
        content = tool_input.get("content", "")
        issues = check_shebang(content, file_path)
    elif tool_name == "Edit":
        new_string = tool_input.get("new_string", "")
        issues = check_shebang(new_string, file_path)
    elif tool_name == "MultiEdit":
        edits = tool_input.get("edits", [])
        for edit in edits:
            new_string = edit.get("new_string", "")
            issues.extend(check_shebang(new_string, file_path))

    if issues:
        seen = set()
        unique_issues = []
        for issue in issues:
            if issue not in seen:
                seen.add(issue)
                unique_issues.append(issue)

        for message in unique_issues:
            print(f"• {message}", file=sys.stderr)

        # Exit code 2 blocks tool call and shows stderr to Claude
        return 2

    return 0


if __name__ == "__main__":
    raise SystemExit(main())

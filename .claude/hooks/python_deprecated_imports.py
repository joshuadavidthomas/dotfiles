#!/usr/bin/env python
from __future__ import annotations

import json
import re
import sys
from collections.abc import Sequence as ABCSequence
from dataclasses import dataclass
from enum import Enum


@dataclass
class ImportRule:
    pattern: str
    old_usage: str
    new_usage: str


class DeprecatedImport(Enum):
    OPTIONAL = ImportRule(
        pattern=r"from\s+typing\s+import\s+.*\bOptional\b",
        old_usage="Optional[X]",
        new_usage="X | None",
    )
    DICT = ImportRule(
        pattern=r"from\s+typing\s+import\s+.*\bDict\b",
        old_usage="Dict",
        new_usage="dict",
    )
    TUPLE = ImportRule(
        pattern=r"from\s+typing\s+import\s+.*\bTuple\b",
        old_usage="Tuple",
        new_usage="tuple",
    )
    SEQUENCE = ImportRule(
        pattern=r"from\s+typing\s+import\s+.*\bSequence\b",
        old_usage="typing.Sequence",
        new_usage="collections.abc.Sequence",
    )

    def format_message(self) -> str:
        return f"Use '{self.value.new_usage}' instead of '{self.value.old_usage}' (from typing import {self.name.title()})"


@dataclass
class FileInfo:
    file_path: str
    filename: str

    @classmethod
    def from_path(cls, file_path: str) -> FileInfo:
        filename = file_path.split("/")[-1] if "/" in file_path else file_path
        return cls(file_path=file_path, filename=filename)


def is_python_file(file_path: str) -> bool:
    return file_path.endswith(".py") or file_path.endswith(".pyi")


def check_deprecated_imports(content: str) -> list[str]:
    issues = []

    for deprecated in DeprecatedImport:
        if re.search(deprecated.value.pattern, content, re.MULTILINE):
            issues.append(deprecated.format_message())

    return issues


def main(argv: ABCSequence[str] | None = None) -> int:
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON input: {e}", file=sys.stderr)
        return 1

    tool_name = input_data.get("tool_name", "")
    tool_input = input_data.get("tool_input", {})
    file_path = tool_input.get("file_path", "")

    if not is_python_file(file_path):
        return 0

    issues = []
    if tool_name == "Write":
        content = tool_input.get("content", "")
        issues = check_deprecated_imports(content)
    elif tool_name == "Edit":
        new_string = tool_input.get("new_string", "")
        issues = check_deprecated_imports(new_string)
    elif tool_name == "MultiEdit":
        edits = tool_input.get("edits", [])
        for edit in edits:
            new_string = edit.get("new_string", "")
            issues.extend(check_deprecated_imports(new_string))

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

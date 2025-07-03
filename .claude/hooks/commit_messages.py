#!/usr/bin/env python
from __future__ import annotations

import json
import re
import sys
from collections.abc import Sequence


COMMIT_MESSAGE_PROMPT = """\
<git-commit-messages>
<requirements>
- Maximum 72 characters - no exceptions
- Imperative mood - "Add feature" not "Added feature" or "Adding feature"
- Focus on the overall change - omit minor/trivial changes
- Single line only - no body, no explanations
</requirements>

<what-to-include>
- The primary purpose of the change
- What was added, fixed, updated, or removed
- The component or area affected (when relevant)
</what-to-include>

<what-to-exclude>
- Implementation details
- Minor refactoring or cleanup
- File names (unless critical to understanding)
- "Also" or "and" statements for unrelated changes
</what-to-exclude>

<examples>
<good-messages>
- Add user authentication middleware
- Fix memory leak in image processing
- Update dependencies to latest versions
- Remove deprecated API endpoints
- Refactor database connection pooling
</good-messages>

<bad-messages>
- Updated some files and fixed a few bugs
- Changes to improve the codebase
- Fixed the issue where the application would crash when...
- Added new feature, updated tests, and cleaned up code
- feat: add user authentication to the API
- fix(auth): resolve token expiration issue
</bad-messages>
</examples>
</git-commit-messages>"""


def extract_commit_message(command: str) -> str | None:
    """Extract commit message from git commit command."""
    # Match patterns like: git commit -m "message" or git commit --message="message"
    patterns = [
        r'git\s+commit\s+.*-m\s+"([^"]+)"',
        r'git\s+commit\s+.*-m\s+\'([^\']+)\'',
        r'git\s+commit\s+.*--message="([^"]+)"',
        r'git\s+commit\s+.*--message=\'([^\']+)\'',
    ]
    
    for pattern in patterns:
        match = re.search(pattern, command)
        if match:
            return match.group(1)
    return None


# Validation rules: (validation_function, error_message)
COMMIT_VALIDATIONS = [
    (lambda m: len(m) <= 72, lambda m: f"Commit message too long ({len(m)} chars). Maximum is 72 characters."),
    (lambda m: not re.match(r'^(Added|Fixed|Updated|Removed|Changed|Created|Deleted|Implemented)', m), 
     lambda m: "Use imperative mood (e.g., 'Add' not 'Added')"),
    (lambda m: not re.match(r'^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?:', m),
     lambda m: "Don't use conventional commit format (feat:, fix:, etc.)"),
]


def main(argv: Sequence[str] | None = None) -> int:
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON input: {e}", file=sys.stderr)
        return 1

    tool_name = input_data.get("tool_name", "")
    tool_input = input_data.get("tool_input", {})
    command = tool_input.get("command", "")

    if tool_name != "Bash" or not command:
        return 1

    # Check if this is a git commit command
    if re.search(r"\bgit\s+commit\b", command):
        message = extract_commit_message(command)
        if not message:
            # Let git handle the case where no message is provided
            return 0
        
        # Validate the commit message
        issues = []
        for validation_fn, error_fn in COMMIT_VALIDATIONS:
            if not validation_fn(message):
                issues.append(error_fn(message))
        
        if issues:
            print(COMMIT_MESSAGE_PROMPT, file=sys.stderr)
            print("\nValidation errors:", file=sys.stderr)
            for issue in issues:
                print(f"• {issue}", file=sys.stderr)
            return 2  # Block the commit

    return 0


if __name__ == "__main__":
    raise SystemExit(main())

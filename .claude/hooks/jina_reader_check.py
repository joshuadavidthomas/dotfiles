#!/usr/bin/env python
from __future__ import annotations

import json
import sys
from collections.abc import Sequence
from urllib.parse import urlparse


def main(argv: Sequence[str] | None = None) -> int:
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON input: {e}", file=sys.stderr)
        return 1

    tool_name = input_data.get("tool_name", "")
    tool_input = input_data.get("tool_input", {})
    url = tool_input.get("url", "")

    if tool_name != "WebFetch" or not url:
        return 1

    parsed_url = urlparse(url)

    if parsed_url.fragment == "jina-fallback":
        return 0

    if not url.startswith("https://r.jina.ai/"):
        print(
            "• Please prepend 'https://r.jina.ai/' to all fetch calls", file=sys.stderr
        )
        print(f"• Use: https://r.jina.ai/{url}", file=sys.stderr)
        print(f"• If Jina fails, retry with: {url}#jina-fallback", file=sys.stderr)
        # Exit code 2 blocks tool call and shows stderr to Claude
        return 2

    return 0


if __name__ == "__main__":
    raise SystemExit(main())

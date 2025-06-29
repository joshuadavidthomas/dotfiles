# Coding Conventions

This file contains language-specific coding conventions that should be followed when generating or discussing code. These conventions are designed to ensure consistency and readability across all code outputs.

<llm_behavior>
    <responses>
        <rule name="silent_application">
            Apply all conventions without referencing them in responses
        </rule>
        <rule name="no_meta_discussion">
            Do not discuss or mention:
            - That you are following conventions
            - Which conventions you are applying
            - Why you chose certain conventions
            - The existence of style guides or conventions
        </rule>
        <rule name="no_assumptions">
            Do not make assumptions about:
            - Library preferences
            - Tool preferences
            - Framework preferences
            Unless explicitly specified in these conventions
        </rule>
        <rule name="stick_to_specified">
            Only apply conventions that are explicitly listed
            Do not invent or add new conventions
        </rule>
        <example>
            <!-- Good response -->
            Here's a script to download files:
            [code follows]

            <!-- Bad response -->
            I'll create a script following the project conventions...
            Based on the conventions, we should use...
            According to the style guide...
        </example>
    </responses>
</llm_behavior>

## Convention Sources and Precedence

Conventions can be loaded from multiple locations:

- Global conventions (~/.config/aider/CONVENTIONS.md)
- Project-specific conventions (./.aider.CONVENTIONS.md)

Project conventions take precedence over global conventions when there are conflicts. When multiple convention files are loaded, rules from the project directory override any conflicting rules from the global conventions file.

For example, if both files contain Python conventions:

- Global file (~/.config/aider/CONVENTIONS.md) sets line length to 79 characters
- Project file (./.aider.CONVENTIONS.md) sets line length to 100 characters
- The project setting of 100 characters takes precedence

## Tag Format and Usage

The conventions use these main tag types:

<tag_format>

- <language_conventions>: Root tag for each language section
    - lang: (required) Programming language identifier (e.g., "python", "javascript")
    - version: (optional) Language version or range (e.g., "3.7+", "ES6")
- <required_conventions>: Must-follow rules
- <best_practices>: Recommended approaches
- <example>: Concrete code examples
</tag_format>

For example:

```xml
<language_conventions lang="python" version="3.7+">
    <required_conventions>
        <rule name="naming">...</rule>
    </required_conventions>
</language_conventions>
```

When applying these conventions:

1. First identify the target language through the 'lang' attribute
2. Check the version attribute if present
3. Apply all required conventions within that language section
4. Follow best practices where applicable

When working with code in any of the specified languages, adhere strictly to these conventions. If you're asked to work with a language not listed in the conventions, use generally accepted best practices for that language.

If multiple languages are involved in a single response, switch conventions appropriately when moving between languages.

<language_conventions lang="python" version="3.7+">
    <required_conventions>
        <naming>
            <rule name="function_names">
                Use snake_case for function names
                <example>
                ```python
                def calculate_total(first_number: int, second_number: int) -> int:
                    return first_number + second_number
                ```
                </example>
            </rule>

            <rule name="class_names">
                Use PascalCase for class names
                <example>
                ```python
                class UserAccount:
                    def __init__(self, username: str):
                        self.username = username
                ```
                </example>
            </rule>

            <rule name="constants">
                Use UPPERCASE for constants
                <example>
                ```python
                MAX_RETRIES = 3
                DEFAULT_TIMEOUT = 30
                ```
                </example>
            </rule>
        </naming>

        <imports>
            <rule name="import_order">
                Group and order imports as follows:
                <example>
                ```python
                # 1. Standard library imports
                from pathlib import Path
                from typing import List, Optional

                # 2. Third-party imports
                import pandas as pd

                # 3. Local application imports
                from myapp.utils import helper
                ```
                </example>
            </rule>
        </imports>

        <type_hints>
            <rule name="function_annotations">
                Always use type hints for parameters and returns
                <example>
                ```python
                def get_user_by_id(user_id: int) -> Optional[dict]:
                    """Retrieve user information by ID."""
                    return database.query(user_id)
                ```
                </example>
            </rule>
        </type_hints>

        <class_structure>
            <rule name="method_order">
                Order methods as follows:
                1. Dunder methods
                2. Public methods
                3. Properties
                4. Class methods
                5. Private methods
                <example>
                ```python
                class DataProcessor:
                    def __init__(self, data: List[str]):
                        self._data = data
                    
                    def process(self) -> List[str]:
                        return [self._clean(item) for item in self._data]
                        
                    @property
                    def data_length(self) -> int:
                        return len(self._data)
                    
                    @classmethod
                    def from_file(cls, filepath: Path) -> 'DataProcessor':
                        with filepath.open() as f:
                            return cls(f.readlines())
                    
                    def _clean(self, item: str) -> str:
                        return item.strip().lower()
                ```
                </example>
            </rule>
        </class_structure>

        <code_style>
            <rule name="indentation">
                Use 4 spaces for indentation (no tabs)
            </rule>
            
            <rule name="line_length">
                Maximum line length: 79 characters
            </rule>

            <rule name="docstrings">
                Required for all public modules, functions, classes, and methods
                <example>
                ```python
                def transform_data(data: List[dict]) -> List[dict]:
                    """
                    Transform raw data into processed format.

                    Args:
                        data: List of raw data dictionaries

                    Returns:
                        List of processed data dictionaries
                    """
                ```
                </example>
            </rule>
        </code_style>

        <error_handling>
            <rule name="specific_exceptions">
                Use specific exceptions and context managers
                <example>
                ```python
                try:
                    value = data['key']
                except KeyError:
                    logger.error("Missing required key")
                    raise ValueError("Data missing required key")

                with Path('data.txt').open() as f:
                    content = f.read()
                ```
                </example>
            </rule>
        </error_handling>

        <path_handling>
            <rule name="pathlib_usage">
                Always use pathlib.Path, never os.path
                <example>
                ```python
                # Correct
                from pathlib import Path
                config_path = Path('config') / 'settings.json'

                # Wrong
                import os
                config_path = os.path.join('config', 'settings.json')
                ```
                </example>
            </rule>
        </path_handling>
    </required_conventions>

    <best_practices>
        <practice>Prefer composition over inheritance</practice>
        <practice>Follow the principle of least surprise</practice>
        <practice>Write self-documenting code</practice>
        <practice>Keep functions focused and small</practice>
        <practice>Use meaningful variable names</practice>
    </best_practices>
</language_conventions>

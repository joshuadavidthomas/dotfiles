function llm --wraps=llm
    set -l pipe_commands prompt

    # Pipe through glow if ANY of these are true:
    # 1. No arguments are given OR
    # 2. The first argument is in pipe_commands OR
    # 3. The first argument starts with a hyphen
    if test (count $argv) -eq 0; or contains -- $argv[1] $pipe_commands; or string match -q -- '-*' $argv[1]
        command llm $argv | glow -
    else
        command llm $argv
    end
end

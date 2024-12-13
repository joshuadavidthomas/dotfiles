function shadow --description "Create a shadowed command with fallback"
    set -l parts (string split -m 1 = $argv)
    if test (count $parts) -ne 2
        echo "Usage: shadow ORIGINAL=REPLACEMENT"
        return 1
    end

    set -l original (string trim -c '"' -c "'" $parts[1])
    set -l replacement_cmd (string trim -c '"' -c "'" $parts[2])
    set -l replacement_parts (string split ' ' $replacement_cmd)
    set -l replacement $replacement_parts[1]
    set -l replacement_args $replacement_parts[2..-1]

    eval "function $original --wraps=$replacement
        if contains -- --raw \$argv; or contains -- -R \$argv
            command $original (string match -v -- --raw -R \$argv)
        else if command -v $replacement >/dev/null
            command $replacement $replacement_args \$argv
        else
            command $original \$argv
        end
    end"
end

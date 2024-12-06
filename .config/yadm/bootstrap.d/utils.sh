#!/usr/bin/env bash

check_root() {
        if [[ $EUID -ne 0 ]]; then
                echo "This script requires root privileges. Please enter your password."
                exec sudo "$0" "$@"
        fi
}

load_env() {
        local env_file="${1:-.env}" # Default to .env if no argument is provided
        local prefix=""
        local specific_keys=()
        local OPTIND opt

        # Resolve the path relative to the current script's location
        local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        env_file="$(cd "$script_dir" && realpath -s "$env_file")"

        # Parse additional options
        shift # Remove the first argument (env_file) from the argument list
        while getopts ":p:k:" opt; do
                case $opt in
                p) prefix="$OPTARG" ;;
                k) IFS=',' read -ra specific_keys <<<"$OPTARG" ;;
                \?)
                        echo "Invalid option -$OPTARG" >&2
                        return 1
                        ;;
                :)
                        echo "Option -$OPTARG requires an argument." >&2
                        return 1
                        ;;
                esac
        done

        if [[ ! -f "$env_file" ]]; then
                echo "Error: $env_file does not exist." >&2
                return 1
        fi

        echo "Loading .env file: $env_file"

        while IFS= read -r line || [[ -n "$line" ]]; do
                if [[ ! $line =~ ^\s*# && -n $line ]]; then
                        if [[ $line =~ ^([^=]+)=(.*)$ ]]; then
                                key="${BASH_REMATCH[1]}"
                                value="${BASH_REMATCH[2]}"

                                key=$(echo "$key" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
                                value=$(echo "$value" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e 's/^["\x27]\(.*\)["\x27]$/\1/')

                                if [[ -z "$prefix" && ${#specific_keys[@]} -eq 0 ]] ||
                                        [[ -n "$prefix" && "$key" == "$prefix"* ]] ||
                                        [[ " ${specific_keys[*]} " =~ " $key " ]]; then
                                        export "$key=$value"
                                        echo "Loaded: $key"
                                fi
                        fi
                fi
        done <"$env_file"
}

unload_env() {
        local prefix="${1:-}"

        if [[ -z "$prefix" ]]; then
                echo "Error: Prefix not provided." >&2
                return 1
        fi

        # Find all environment variables starting with the prefix and unset them
        for var in $(compgen -v "${prefix}"); do
                unset "$var"
                echo "Unset: $var"
        done
}

check_command() {
        command -v "$1" >/dev/null 2>&1 || {
                echo >&2 "Command '$1' not found. Exiting."
                return 1
        }
}

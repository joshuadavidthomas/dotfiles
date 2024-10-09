#!/usr/bin/env bash

check_root() {
        if [[ $EUID -ne 0 ]]; then
                echo "This script requires root privileges. Please enter your password."
                exec sudo "$0" "$@"
        fi
}

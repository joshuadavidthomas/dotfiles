function web2app
    if test (count $argv) -ne 3
        echo "Usage: web2app <AppName> <AppURL> <IconURL> (IconURL must be in PNG -- use https://dashboardicons.com)"
        return 1
    end

    set -l APP_NAME $argv[1]
    set -l APP_URL $argv[2]
    set -l ICON_URL $argv[3]
    set -l ICON_DIR "$HOME/.local/share/applications/icons"
    set -l DESKTOP_FILE "$HOME/.local/share/applications/$APP_NAME.desktop"
    set -l ICON_PATH "$ICON_DIR/$APP_NAME.png"

    mkdir -p "$ICON_DIR"

    if not curl -sL -o "$ICON_PATH" "$ICON_URL"
        echo "Error: Failed to download icon."
        return 1
    end

    echo "[Desktop Entry]
Version=1.0
Name=$APP_NAME
Comment=$APP_NAME
Exec=vivaldi --new-window --enable-features=UseOzonePlatform --ozone-platform=wayland --app=\"$APP_URL\" --name=\"$APP_NAME\" --class=\"$APP_NAME\"
Terminal=false
Type=Application
Icon=$ICON_PATH
StartupNotify=true" > "$DESKTOP_FILE"

    chmod +x "$DESKTOP_FILE"
end

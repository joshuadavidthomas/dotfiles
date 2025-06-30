# Arch Bootstrap Scripts Organization

Since yadm already handles the dotfiles, the bootstrap scripts focus on:
1. Installing packages the configs expect
2. Enabling services
3. Setting up accounts/logins
4. Downloading external resources (fonts, wallpapers)

## Bootstrap Process (7-8 Scripts)

A pragmatic approach with clear functional layers:

```
01-base            # yay + system essentials (audio, network, bluetooth)
10-shell           # fish, CLI tools, terminal emulators
20-desktop         # Complete Hyprland + utilities + fonts/themes
30-development     # All dev tools, languages, containers
40-browsers        # Just browsers
50-apps            # All user apps (productivity, communication, media)
99-finalize        # Cleanup, first-run wizard, enable services
```

### 01-base - System Foundation

**Purpose**: Install package manager and essential system components

**Packages**:
- Build tools: git, base-devel (for yay)
- Core utilities: curl, wget, unzip, zip, man-db, man-pages, openssh, rsync
- System tools: htop, btop, ncdu, tree, lsof, strace
- Key remapping: keyd
- Audio: pipewire, pipewire-alsa, pipewire-jack, pipewire-pulse, wireplumber, pamixer
- Bluetooth: bluez, bluez-utils
- Printing: cups, system-config-printer
- Power: power-profiles-daemon, thermald (laptops)

**Actions**:
- Install yay from AUR
- Configure pacman (color, parallel downloads)
- Enable services: bluetooth, cups, systemd-timesyncd, keyd
- Set up audio (pipewire user services)

### 10-shell - Terminal Environment

**Purpose**: Everything needed for a productive shell/CLI workflow

**Packages**:
- Shell: fish, tmux, starship
- Core tools: git, neovim, ripgrep, fd, fzf, sd, jq, yq
- Better tools: bat, eza, zoxide, dust, duf, bottom, procs
- Network tools: httpie, xh, curlie, bandwhich, gping
- Additional: atuin, direnv, tealdeer, hyperfine, tokei

**Actions**:
- Set fish as default shell: `chsh -s /usr/bin/fish`
- Initialize zoxide database
- Install tealdeer pages: `tldr --update`
- Optional: atuin login if credentials provided

### 20-desktop - Complete Desktop Environment

**Purpose**: Full Hyprland desktop with all utilities and appearance

**Packages**:
- Core: hyprland, hypridle, hyprlock, hyprpaper, waybar, wofi
- Qt/Wayland: qt5-wayland, qt6-wayland
- Portals: xdg-desktop-portal-hyprland, xdg-desktop-portal-gtk
- Terminal emulators: ghostty-git, wezterm, kitty
- Clipboard: clipse, wl-clipboard, wl-clip-persist
- Screenshots: grim, slurp, swappy
- Notifications: swaync
- File manager: nautilus, nautilus-open-any-terminal, sushi
- Utilities: hyprpicker, hyprpolkitagent, brightnessctl, playerctl, pavucontrol
- System fonts: ttf-liberation, noto-fonts, noto-fonts-emoji, noto-fonts-cjk
- Nerd fonts: ttf-cascadia-code-nerd, ttf-firacode-nerd, ttf-font-awesome
- Theme: GTK theme (Tokyo Night/Catppuccin), papirus-icon-theme, capitaine-cursors
- Qt theming: qt5ct, qt6ct, kvantum

**Actions**:
- Create ~/.bash_profile for Hyprland auto-start on tty1
- Download wallpapers to ~/Pictures/Wallpapers
- Run `fc-cache -fv` for fonts
- Set environment variables for Wayland
- Configure xdg-user-dirs

### 30-development - Development Tools

**Purpose**: Complete development environment

**Packages**:
- Languages: mise-bin (manages node, python, rust, go via .tool-versions)
- Git tools: git-delta, lazygit, github-cli, glab
- Build tools: just, make, cmake, meson, ninja
- Containers: docker, docker-compose, lazydocker, dive
- Cloud: kubectl, k9s, helm, terraform, flyctl, awscli
- Database: postgresql-client, redis, sqlite
- Additional: pre-commit, watchexec, entr

**Actions**:
- Run `mise install` to set up languages
- Install global packages: npm install -g pnpm yarn
- Add user to docker group
- Enable docker service

### 40-browsers - Web Browsers

**Purpose**: Web browsers (simple and focused)

**Packages**: firefox, chromium, vivaldi

### 50-apps - User Applications

**Purpose**: All productivity, communication, and media apps

**Productivity**:
- Password: 1password, 1password-cli
- Office: libreoffice-fresh
- Notes: obsidian
- PDF: zathura, zathura-pdf-mupdf
- Email: thunderbird
- Calculator: gnome-calculator

**Communication**:
- signal-desktop, discord, slack-desktop
- zoom, teams-for-linux

**Media**:
- Audio: spotify, spotify-tui, ncspot
- Video: vlc, mpv, obs-studio
- Graphics: gimp, inkscape
- Tools: yt-dlp, ffmpeg

### 99-finalize - System Finalization

**Purpose**: Clean up and prepare for first use

**Actions**:
- Clean package cache: `yay -Sc --noconfirm`
- Remove orphans: `yay -Qtdq | yay -Rns -`
- Update mlocate database: `sudo updatedb`
- Enable user services (syncthing, atuin sync if configured)
- Launch first-run wizard for account setups
- Create ~/.config/first-run-complete marker
- Offer reboot prompt

## Key Principles

1. **Idempotent**: All scripts can be run multiple times safely
2. **Progressive**: Each script builds on the previous to create complete layers
3. **Modular**: Skip sections you don't need (e.g., skip 30-development)
4. **Clear dependencies**: Desktop needs shell, development needs desktop, etc.
#!/usr/bin/env bash

set -euo pipefail

CONFIG_REPO="https://github.com/Dromader2137/dros.git"
CLONE_DIR="$HOME/configs"

function info() { echo -e "\e[32m[INFO]\e[0m $1"; }
function warn() { echo -e "\e[33m[WARN]\e[0m $1"; }
function error() { echo -e "\e[31m[ERROR]\e[0m $1"; }

copy_config() {
  local src="$1"
  local dest="$2"
  rm -rf "$dest"
  if [ -e "$src" ]; then
    info "Copying config from $src to $dest"
    mkdir -p "$(dirname "$dest")"
    cp -r "$src" "$dest"
  else
    warn "No config found at $src"
  fi
}

LOG_FILE="/tmp/arch-setup.log"
run_cmd() {
    local cmd="$*"
    echo -e "\n Running: $cmd" >> "$LOG_FILE"

    if ! eval "$cmd" >> "$LOG_FILE" 2>&1; then
        error "Command failed: $cmd"
        echo "---- Output from log ----"
        tail -n 50 "$LOG_FILE"
        echo "-------------------------"
        exit 1
    fi
}

info "Installing gum (for better interactive prompts), git and base-devel (for AUR packages)"
run_cmd "sudo pacman -S --noconfirm --needed gum git base-devel"

info "Adding Chaotic-AUR repository"
run_cmd "sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com"
run_cmd "sudo pacman-key --lsign-key 3056513887B78AEB"
run_cmd "sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'"
run_cmd "sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'"
if ! grep -q "chaotic-aur" /etc/pacman.conf; then
    run_cmd "echo -e '\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist' | sudo tee -a /etc/pacman.conf"
    run_cmd "sudo pacman -Syu --noconfirm"
else
    warn "Chaotic-AUR is already present in pacman.conf"
fi

info "Choose an AUR helper"
AUR_HELPER=$(gum choose "yay" "paru" --cursor.foreground 212 --height 2)
if [[ "$AUR_HELPER" == "yay" ]]; then
    info "Installing yay"
    run_cmd "sudo pacman -S --noconfirm yay"
elif [[ "$AUR_HELPER" == "paru" ]]; then
    info "Installing paru"
    run_cmd "sudo pacman -S --noconfirm paru"
else
    error "No AUR helper chosen, requiered!"
    exit 1;
fi

if [ -d "$CLONE_DIR" ]; then
  warn "Config directory already exists at $CLONE_DIR, removing it."
  run_cmd "rm -rf "$CLONE_DIR""
fi
info "Cloning config repo from $CONFIG_REPO"
run_cmd "git clone "$CONFIG_REPO" "$CLONE_DIR""

if gum confirm "Do you want to setup fish?"; then
  info "Installing Fish"
  run_cmd ""$AUR_HELPER" -S --noconfirm --needed fish"
  info "Installing Eza (ls replacement with nice colors)"
  run_cmd ""$AUR_HELPER" -S --noconfirm --needed eza"
  info "Setting Fish as the default shell"
  run_cmd "sudo chsh -s /usr/bin/fish "$USER""
  copy_config "$CLONE_DIR/.config/fish" "$HOME/.config/fish"

  if gum confirm "Do you want to install Starship prompt?"; then
    info "Installing Starship"
    run_cmd ""$AUR_HELPER" -S --noconfirm --needed starship"
    copy_config "$CLONE_DIR/configs/starship.toml" "$HOME/.config/starship.toml"
  fi
fi

if gum confirm "Do you want to setup nvim?"; then
  info "Installing Neovim"
  run_cmd ""$AUR_HELPER" -S --noconfirm --needed neovim"
  copy_config "$CLONE_DIR/configs/nvim" "$HOME/.config/nvim"
fi

GRAPHICS_ENV="none"

if gum confirm "Do you want to setup graphical environment?"; then
  info "Choose your graphical driver to install"

  DRIVER_CHOICE=$(gum choose --limit=1 "intel" "amd" "nvidia" "nvidia-opensource" "none" --cursor.foreground 212 --height 5)

  for DRIVER in $DRIVER_CHOICE; do
    case "$DRIVER" in
      intel)
        info "Installing Intel graphics drivers"
        run_cmd ""$AUR_HELPER" -S --noconfirm --needed mesa libva-intel-driver vulkan-intel libvpl vpl-gpu-rt"
        ;;
      amd)
        info "Installing AMD graphics drivers"
        run_cmd ""$AUR_HELPER" -S --noconfirm --needed mesa vulkan-radeon"
        ;;
      nvidia)
        info "Installing NVIDIA proprietary drivers"
        run_cmd ""$AUR_HELPER" -S --noconfirm --needed nvidia-open nvidia-utils libva-nvidia-driver"
        ;;
      nvidia-opensource)
        info "Installing NVIDIA open-source drivers"
        run_cmd ""$AUR_HELPER" -S --noconfirm --needed mesa vulkan-nouveau"
        ;;
      none)
        warn "Skipping graphical driver installation"
        ;;
      *)
        warn "Unknown option: $DRIVER, skipping"
        ;;
    esac
  done

  info "Installing desktop packages"
  run_cmd ""$AUR_HELPER" -S --noconfirm --needed qt5ct qt6ct hyprland alacritty eww jq socat imv rofi zathura librewolf slurp grim mpv ttf-mononoki-nerd nerd-fonts-symbols-mono nerd-fonts-symbols nerd-fonts-symbols-common noto-fonts-emoji hyprlock ttf-hanazono bibata-cursor-translucent"

  GRAPHICS_ENV="hypr"

  run_cmd "librewolf --headless & sleep 5; pkill librewolf"
  LIBREWOLF_PROFILE_DIR=$(find "$HOME/.librewolf" -maxdepth 1 -type d -name "*.default-default" | head -n 1)
  if [ -d "$LIBREWOLF_PROFILE_DIR" ]; then
    copy_config "$CLONE_DIR/configs/userChrome.css" "$LIBREWOLF_PROFILE_DIR/chrome/userChrome.css"
    echo 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' >> "$LIBREWOLF_PROFILE_DIR/user.js"
    echo 'user_pref("browser.toolbars.bookmarks.visibility", "never");' >> "$LIBREWOLF_PROFILE_DIR/user.js"
  else
    warn "LibreWolf profile not found, skipping chrome config"
  fi

  copy_config "$CLONE_DIR/themes" "$HOME/.themes"
  copy_config "$CLONE_DIR/configs/.gtkrc-2.0" "$HOME/.gtkrc-2.0"
  copy_config "$CLONE_DIR/configs/alacritty" "$HOME/.config/alacritty"
  copy_config "$CLONE_DIR/configs/eww" "$HOME/.config/eww"
  copy_config "$CLONE_DIR/configs/imv" "$HOME/.config/imv"
  copy_config "$CLONE_DIR/configs/rofi" "$HOME/.config/rofi"
  copy_config "$CLONE_DIR/configs/zathura" "$HOME/.config/zathura"
  copy_config "$CLONE_DIR/configs/qt5ct" "$HOME/.config/qt5ct"
  copy_config "$CLONE_DIR/configs/qt6ct" "$HOME/.config/qt6ct"
  copy_config "$CLONE_DIR/configs/gtk-3.0" "$HOME/.config/gtk-3.0"
  copy_config "$CLONE_DIR/configs/gtk-4.0" "$HOME/.config/gtk-4.0"
  copy_config "$CLONE_DIR/configs/xsettingsd" "$HOME/.config/xsettingsd"
  copy_config "$CLONE_DIR/configs/hypr" "$HOME/.config/hypr"
  copy_config "$CLONE_DIR/configs/zathura" "$HOME/.config/zathura"
  copy_config "$CLONE_DIR/configs/user-dirs.dirs" "$HOME/.config/user-dirs.dirs"
  run_cmd "gsettings set org.gnome.desktop.interface gtk-theme gruvbox"

  for DRIVER in $DRIVER_CHOICE; do
    if [[ "$DRIVER" == "nvidia" ]]; then
      echo -e 'env = LIBVA_DRIVER_NAME,nvidia\nenv = __GLX_VENDOR_LIBRARY_NAME,nvidia\nenv = NVD_BACKEND,direct' >> "$HOME/.config/hypr/hyprland.conf"
      echo -e 'cursor {\nno_hardware_cursor = true\n}' >> "$HOME/.config/hypr/hyprland.conf"
    elif [[ "$DRIVER" == "nvidia-opensource" ]]; then
      echo -e 'cursor {\nno_hardware_cursor = true\n}' >> "$HOME/.config/hypr/hyprland.conf"
    fi
  done

  info "Creating XDG user directories"
  XDG_DESKTOP_DIR="$HOME/desktop"
  XDG_DOWNLOAD_DIR="$HOME/downloads"
  XDG_TEMPLATES_DIR="$HOME/templates"
  XDG_PUBLICSHARE_DIR="$HOME/public"
  XDG_DOCUMENTS_DIR="$HOME/documents"
  XDG_MUSIC_DIR="$HOME/music"
  XDG_PICTURES_DIR="$HOME/pictures"
  XDG_VIDEOS_DIR="$HOME/videos"
  for dir in "$XDG_DESKTOP_DIR" "$XDG_DOWNLOAD_DIR" "$XDG_TEMPLATES_DIR" "$XDG_PUBLICSHARE_DIR" "$XDG_DOCUMENTS_DIR" "$XDG_MUSIC_DIR" "$XDG_PICTURES_DIR" "$XDG_VIDEOS_DIR"; do
    if [ ! -d "$dir" ]; then
      mkdir -p "$dir"
    else
      warn "Directory $dir already exists"
    fi
  done

  if gum confirm "Do you want to setup sound with Pipewire?"; then
    info "Installing Pipewire, Pipewire-Pulse, WirePlumber, and Pulsemixer"
    run_cmd ""$AUR_HELPER" -S --noconfirm --needed pipewire pipewire-pulse wireplumber pulsemixer"
    info "Enabling and starting Pipewire services"
    run_cmd "systemctl --user enable --now pipewire pipewire-pulse wireplumber"
  fi

  if gum confirm "Do you want to setup sound with MPD and NCMPCPP?"; then
    info "Installing MPD and NCMPCPP"
    run_cmd ""$AUR_HELPER" -S --noconfirm --needed mpd ncmpcpp"
    copy_config "$CLONE_DIR/.config/mpd" "$HOME/.config/mpd"
    copy_config "$CLONE_DIR/.config/ncmpcpp" "$HOME/.config/ncmpcpp"
  fi

  if gum confirm "Do you want to setup Bluetooth?"; then
    info "Installing Bluetooth"
    run_cmd ""$AUR_HELPER" -S --noconfirm --needed bluez bluez-utils bluetui"
    info "Enabling and starting Bluetooth service"
    run_cmd "sudo systemctl enable --now bluetooth"
  fi
fi

if gum confirm "Do you want to setup rust?"; then
  info "Installing Rustup"
  run_cmd ""$AUR_HELPER" -S --noconfirm rustup"

  if gum confirm "Do you want to setup rust nightly?"; then
    info "Installing nightly toolchain"
    run_cmd "rustup install nightly"
    run_cmd "rustup default nightly"
  else
    info "Installing stable toolchain"
    run_cmd "rustup install stable"
    run_cmd "rustup default stable"
  fi
fi

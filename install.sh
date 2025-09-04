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

info "Installing gum (for better interactive prompts)"
sudo pacman -S --noconfirm --needed gum

echo "Which AUR helper would you like to install? (yay/paru)"
read -rp "Enter choice: " aur_helper

case "$aur_helper" in
  yay)
    info "Installing yay..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
    ;;
  paru)
    info "Installing paru..."
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    (cd /tmp/paru && makepkg -si --noconfirm)
    ;;
  *)
    warn "Invalid choice, AUR is requiered."
    exit 1;
    ;;
esac

if [ -d "$CLONE_DIR" ]; then
  warn "Config directory already exists at $CLONE_DIR, removing it."
  rm -rf "$CLONE_DIR"
fi

info "Cloning config repo from $CONFIG_REPO"
git clone "$CONFIG_REPO" "$CLONE_DIR"


if gum confirm "Do you want to setup fish?"; then
  info "Installing Fish shell"
  "$aur_helper" -S --noconfirm --needed fish
  info "Setting Fish as default shell for the current user"
  chsh -s /usr/bin/fish
  copy_config "$CLONE_DIR/.config/fish" "$HOME/.config/fish"

  if gum confirm "Do you want to install Starship prompt?"; then
    info "Installing Starship prompt"
    "$aur_helper" -S --noconfirm --needed starship
    copy_config "$CLONE_DIR/.config/starship.toml" "$HOME/.config/starship.toml"
  fi
fi

if gum confirm "Do you want to setup nvim?"; then
  info "Installing Neovim"
  "$aur_helper" -S --noconfirm --needed neovim
  copy_config "$CLONE_DIR/.config/nvim" "$HOME/.config/nvim"
fi

GRAPHICS_ENV="none"

if gum confirm "Do you want to setup graphical environment?"; then
  info "Choose your graphical driver(s) to install (use space to select multiple)"

  DRIVER_CHOICE=$(gum choose --no-limit \
    "intel" \
    "amd" \
    "nvidia" \
    "nvidia-opensource" \
    "none" \
    --cursor.foreground 212 \
    --height 5)

  for DRIVER in $DRIVER_CHOICE; do
    case "$DRIVER" in
      intel)
        info "Installing Intel graphics drivers and VA-API acceleration"
        "$aur_helper" -S --noconfirm --needed mesa libva-intel-driver vulkan-intel libvpl vpl-gpu-rt
        ;;
      amd)
        info "Installing AMD graphics drivers and video acceleration"
        "$aur_helper" -S --noconfirm --needed mesa vulkan-radeon
        ;;
      nvidia)
        info "Installing NVIDIA proprietary drivers and video acceleration"
        "$aur_helper" -S --noconfirm --needed nvidia-open nvidia-utils libva-nvidia-driver
        ;;
      nvidia-opensource)
        info "Installing NVIDIA open-source Vulkan driver (NVK)"
        "$aur_helper" -S --noconfirm --needed mesa vulkan-nouveau
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
  "$aur_helper" -S --noconfirm --needed qt5ct qt6ct hyprland alacritty eww imv rofi zathura librewolf-bin zathura slurp grim mpv
  GRAPHICS_ENV="hypr"
  copy_config "$CLONE_DIR/.librewolf/t07hmt5u.default-default/chrome" "$HOME/.librewolf/t07hmt5u.default-default/chrome"
  copy_config "$CLONE_DIR/.themes" "$HOME/.themes"
  copy_config "$CLONE_DIR/.gtkrc-2.0" "$HOME/.gtkrc-2.0"
  copy_config "$CLONE_DIR/.config/alacritty" "$HOME/.config/alacritty"
  copy_config "$CLONE_DIR/.config/eww" "$HOME/.config/eww"
  copy_config "$CLONE_DIR/.config/imv" "$HOME/.config/imv"
  copy_config "$CLONE_DIR/.config/rofi" "$HOME/.config/rofi"
  copy_config "$CLONE_DIR/.config/zathura" "$HOME/.config/zathura"
  copy_config "$CLONE_DIR/.config/qt5ct" "$HOME/.config/qt5ct"
  copy_config "$CLONE_DIR/.config/qt6ct" "$HOME/.config/qt6ct"
  copy_config "$CLONE_DIR/.config/hypr" "$HOME/.config/hypr"
  copy_config "$CLONE_DIR/.config/zathura" "$HOME/.config/zathura"
  copy_config "$CLONE_DIR/.config/user-dirs.dirs" "$HOME/.config/user-dirs.dirs"

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
      info "Creating $dir"
      mkdir -p "$dir"
    else
      warn "Directory $dir already exists"
    fi
  done


  if gum confirm "Do you want to setup sound with Pipewire?"; then
    info "Installing Pipewire, Pipewire-Pulse, WirePlumber, and Pulsemixer"
    "$aur_helper" -S --noconfirm --needed pipewire pipewire-pulse wireplumber
    "$aur_helper" -S --noconfirm --needed pulsmixer
    info "Enabling and starting Pipewire services"
    systemctl --user enable --now pipewire pipewire-pulse wireplumber
  fi

  if gum confirm "Do you want to setup sound with MPD and NCMPCPP?"; then
    info "Installing MPD and ncmpcpp"
    "$aur_helper" -S --noconfirm --needed mpd ncmpcpp
    info "Creating MPD configuration directory"
    copy_config "$CLONE_DIR/.config/mpd" "$HOME/.config/mpd"
  fi

  if gum confirm "Do you want to setup Bluetooth?"; then
    info "Installing Bluetooth packages"
    "$aur_helper" -S --noconfirm --needed bluez bluez-utils
    "$aur_helper" -S --noconfirm --needed bluetuith
    info "Enabling and starting Bluetooth service"
    sudo systemctl enable --now bluetooth
  fi
fi


if gum confirm "Do you want to setup rust?"; then
  info "Installing rustup using $aur_helper"
  "$aur_helper" -S --noconfirm rustup

  if gum confirm "Do you want to setup rust nightly?"; then
    info "Installing nightly toolchain"
    rustup install nightly
    rustup default nightly
  fi
fi

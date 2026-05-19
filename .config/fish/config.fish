contains $HOME/.cargo/bin/ $fish_user_paths; or set -Ua fish_user_paths $HOME/.cargo/bin/
contains $HOME/.local/bin/ $fish_user_paths; or set -Ua fish_user_paths $HOME/.local/bin/
contains $HOME/.nsight/nsys/bin/ $fish_user_paths; or set -Ua fish_user_paths $HOME/.nsight/nsys/bin/

if status is-login
	export XCURSOR_SIZE=28
	export XCURSOR_THEME=Bibata_Spirit
	export XDG_SESSION_TYPE=wayland
	export XDG_SESSION_DESKTOP=sway
	export QT_QPA_PLATFORMTHEME=qt6ct
	export QT_QPA_PLATFORM=wayland
	export GTK_THEME=gruvbox
	export ELECTRON_OZONE_PLATFORM_HINT=auto
	export BROWSER=librewolf
	export EDITOR=nvim
	export VISUAL=nvim
	export CALIBRE_USE_SYSTEM_THEME=true
	export VULKAN_HOME=$HOME/.local/share/vulkan-sdk
	export VULKAN_DOWNLOAD=$HOME/.local/share/vulkan-sdk/releases

	WLR_RENDERER=vulkan sway
end

if status is-interactive
	starship init fish | source

	set fish_greeting

	export EDITOR="nvim"
	export VISUAL="nvim"

	alias nv="nvim"
	alias hx="helix"

	alias ls="exa -l --group-directories-first -s Extension"
	alias la="exa -la --group-directories-first -s Extension"
	alias ll="exa -l --group-directories-first -s Extension -T -L 3"
	alias lla="exa -la --group-directories-first -s Extension -T -L 2"

	alias gs="git status"
	alias ga="git add"
	alias gc="git commit -m"
	alias gca="git commit -a -m"
	alias gf="git fetch"
	alias gpl="git pull"
	alias gp="git push"
	alias gl='git log --color --graph --pretty=format:'\''%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'\'' --abbrev-commit'
	alias gla='git log --all --color --graph --pretty=format:'\''%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'\'' --abbrev-commit'
	alias gsw="git switch"
	alias gr="git restore"
	alias gd="git diff"
	alias gcb="git checkout -b"
	alias gbm="git branch -m"
	alias gbd="git branch -D"
	alias gm="git merge"

	alias disk="lsblk -a -o NAME,SIZE,FSUSED,TYPE,FSTYPE,MOUNTPOINTS"

	alias wificu="nmcli d w connect --ask"
	alias wifick="nmcli d w connect"
	alias nets="nmcli"
	alias pip="curl ip.me"
end

if status is-interactive
	starship init fish | source
	set fish_greeting
	export EDITOR="nvim"
	export VISUAL="nvim"

	alias ls="exa -l --group-directories-first -s Extension"
	alias la="exa -la --group-directories-first -s Extension"
	alias ll="exa -la --group-directories-first -s Extension -T -L 2"

	alias gs="git status"
	alias ga="git add"
	alias gc="git commit -m"
	alias gf="git pull"
	alias gp="git push"
	alias gpa="git push --all"
	alias gl='git log --color --graph --pretty=format:'\''%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'\'' --abbrev-commit'
	alias gsw="git switch"
	alias gr="git restore"
	alias gd="git diff"
	alias gcb="git checkout -b"
	alias gbm="git branch -m"

	alias disk="lsblk -a -o NAME,SIZE,FSUSED,TYPE,FSTYPE,MOUNTPOINTS"

	alias vpnd="nmcli connection down Proton-NL"
	alias vpnu="nmcli connection up Proton-NL"

	alias cliplen="wl-paste | wc -w"

	alias wificu="nmcli d w connect --ask"
	alias wifick="nmcli d w connect"
	alias nets="nmcli"
	alias pip="curl ip.me"

	contains $HOME/.cargo/bin/ $fish_user_paths; or set -Ua fish_user_paths $HOME/.cargo/bin/
	contains $HOME/.local/bin/ $fish_user_paths; or set -Ua fish_user_paths $HOME/.local/bin/
end

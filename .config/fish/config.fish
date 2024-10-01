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
	alias gl="git log --graph --oneline --all"
	alias gsw="git switch"
	alias gr="git restore"
	alias gd="git diff"
	alias gcb="git checkout -b"
	alias gbm="git brach -m"
	alias disk="lsblk -a -o NAME,SIZE,FSUSED,TYPE,FSTYPE,MOUNTPOINTS"
	contains $HOME/.cargo/bin/ $fish_user_paths; or set -Ua fish_user_paths $HOME/.cargo/bin/
	contains $HOME/.local/bin/ $fish_user_paths; or set -Ua fish_user_paths $HOME/.local/bin/
end

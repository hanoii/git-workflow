#ddev-generated

# Path
export PATH=~/.bun/bin:~/.local/bin:$PATH:/usr/games

# This is so that child processes have appropriate access to this var
export SHELL

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# ahoy
COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

# fzf
source /opt/.fzf.bash

# fzf-git
source /opt/fzf-git.sh/fzf-git.sh

# z.lua
mkdir -p /mnt/ddev-global-cache/z.lua/${HOSTNAME}
_ZL_DATA=/mnt/ddev-global-cache/z.lua/${HOSTNAME}/.zlua
export _ZL_DATA
if [[ "$BASHOPTS" =~ login_shell ]]; then
  eval "$(lua /opt/z.lua/z.lua --init bash enhanced once fzf)"
fi

# starship prompt
function set_win_title(){
  if [[ $@ == *"starship_precmd"* ]]; then
    return
  fi
  if [[ $@ == *"__fzf_"* ]]; then
    return
  fi
  # Shortening $PWD
  # /var/www/html -> /v/w/html
  local short_pwd=$(echo "$PWD" | sed 's/\([^\/]\)[^\/]*\//\1\//g')
  echo -ne "\033]0;$@$DDEV_PROJECT/ddev: $short_pwd\007"
}
starship_precmd_user_func="set_win_title"
trap "set_win_title \"\${BASH_COMMAND} - \"" DEBUG
eval "$(starship init bash)"

# eza aliases to ls
# https://gist.github.com/AppleBoiy/04a249b6f64fd0fe1744aff759a0563b
alias ls='eza --color=always --group-directories-first --icons'
alias ll='eza -la --icons --octal-permissions --group-directories-first'

# go
export PATH=$PATH:/usr/local/go/bin:~/go/bin
unset GOARCH
unset GOOS

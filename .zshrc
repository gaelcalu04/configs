# Set own functions autolaoadable
fpath=(~/.zsh/functions $fpath)
autoload -U ${fpath[1]}/*(.N:t)

# Basic init
setopt no_beep complete_in_word rm_star_wait longlistjobs nonomatch hash_list_all

eval `dircolors`

autoload -U colors && colors
autoload add-zsh-hook

# Stuff for terminal compatibility
set_color
typeset -A key

key[Home]=${terminfo[khome]}
key[End]=${terminfo[kend]}
key[Insert]=${terminfo[kich1]}
key[Delete]=${terminfo[kdch1]}
key[Up]=${terminfo[kcuu1]}
key[Down]=${terminfo[kcud1]}
key[Left]=${terminfo[kcub1]}
key[Right]=${terminfo[kcuf1]}
key[PageUp]=${terminfo[kpp]}
key[PageDown]=${terminfo[knp]}
for k in ${(k)key} ; do
        # $terminfo[] entries are weird in ncurses application mode...
        [[ ${key[$k]} == $'\eO'* ]] && key[$k]=${key[$k]/O/[}
done
unset k
# setup key accordingly
[[ -n "${key[Home]}"    ]]  && bindkey  "${key[Home]}"    beginning-of-line
[[ -n "${key[End]}"     ]]  && bindkey  "${key[End]}"     end-of-line
[[ -n "${key[Insert]}"  ]]  && bindkey  "${key[Insert]}"  overwrite-mode
[[ -n "${key[Delete]}"  ]]  && bindkey  "${key[Delete]}"  delete-char
# the next two are one of my favorites
[[ -n "${key[Up]}"      ]]  && bindkey  "${key[Up]}"      up-line-or-search
[[ -n "${key[Down]}"    ]]  && bindkey  "${key[Down]}"    down-line-or-search
[[ -n "${key[Left]}"    ]]  && bindkey  "${key[Left]}"    backward-char
[[ -n "${key[Right]}"   ]]  && bindkey  "${key[Right]}"   forward-char


bindkey "^[[H" beginning-of-line
bindkey "^[[1~" beginning-of-line
bindkey "^[OH" beginning-of-line
bindkey "^[[F"  end-of-line
bindkey "^[[4~" end-of-line
bindkey "^[OF" end-of-line
bindkey " " magic-space    # also do history expansion on space


# nice ones
bindkey "2D" backward-word          # shift+l
bindkey "2C" forward-word           # shift+r
bindkey "5D" backward-word          # shift+l
bindkey "5C" forward-word           # shift+r
bindkey "6D" backward-delete-word   # ctrl+shift+l
bindkey "6C" delete-word            # ctrl+shift+r
bindkey "7D" beginning-of-line      # ctrl+alt+l
bindkey "7C" end-of-line            # ctrl+alt+r
#bindkey '\e[3~' delete-char
bindkey '^R' history-incremental-search-backward


# Git&Svn Stuff
autoload -Uz vcs_info
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr "%{$fg_bold[green]%}●%{$reset_color%}"
zstyle ':vcs_info:*' unstagedstr "%{$fg_bold[yellow]%}●%{$reset_color%}"
zstyle ':vcs_info:*' enable git svn
vcsprecmd () {
# checking for untracked files is too slow
    if [[ -z $(git ls-files --other --exclude-standard 2> /dev/null) ]]; then
        zstyle ':vcs_info:*' formats "%{$fg_bold[white]%}[%b%{$reset_color%}%c%u%{$fg_bold[white]%}]%{$reset_color%}"
    else
        zstyle ':vcs_info:*' formats "%{$fg_bold[white]%}[%b%{$reset_color%}%c%u%{$fg_bold[red]%}●%{$reset_color%}%{$fg_bold[white]%}]%{$reset_color%}"
    fi
    vcs_info
}
add-zsh-hook precmd vcsprecmd

# Fancy prompt with returncode at failure
setopt prompt_subst
if [[ $EUID -ne 0 ]]; then
    PS1=$'%{$fg[red]%}%(?..%?\n)%{$reset_color%}%{$fg_bold[white]%}%n%{$reset_color%}][%{$fg_bold[yellow]%}%m:%{$reset_color%}${vcs_info_msg_0_}%{$fg[cyan]%}%~/%{$reset_color%}'
else
    PS1=$'%{$fg[red]%}%(?..%?\n)%{$reset_color%}%{$fg_bold[red]%}%n%{$reset_color%}][%{$fg[yellow]%}%m:%{$reset_color%}${vcs_info_msg_0_}%{$fg[cyan]%}%~/%{$reset_color%}'
fi

# Some variables
export TERM="xterm-256color"
export LANG=en_US.UTF-8
export EDITOR=emacsclient
export PAGER=less
export BROWSER=chromium

# if a command lasts longer than $REPORTTIME time is shown
REPORTTIME=15

# show login/logout actions except of root and actual user
WATCHFMT='%T: %n has %a %l from %m'
watch=(notme root)


# completion
autoload -U compinit && compinit
zmodload -i zsh/complist
zstyle ':completion:*'                  verbose yes
zstyle ':completion:*'                  group-name
zstyle ':completion:*'                  use-cache on
zstyle ':completion:*'                  cache-path ~/.zsh/cache
zstyle ':completion:*'                  matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*'                  menu select=2
zstyle ':completion:*'                  group-name ''
zstyle ':completion:*:commands'         rehash on
zstyle ':completion:*:descriptions'     format "%{$bg[green]%}%{$fg[black]%}%d%{$reset_color%}"
zstyle ':completion:*:corrections'      format "%{$bg[green]%}%{$fg[black]%}%d%{$reset_color%}"
zstyle ':completion:*:messages'         format "%{$bg[green]%}%{$fg[black]%}%d%{$reset_color%}"
zstyle ':completion:*:warnings'         format "%{$fg[red]%}%d%{$reset_color%}"
zstyle ':completion:*:default'          select-prompt "%{$fg_bold[green]%}%SMatch %M %P%s%{$reset_color%}"
zstyle ':completion:*:default'          list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:options'          auto-description '%d'
zstyle ':completion:*:options'          description 'yes'
zstyle ':completion:*:approximate:'     max-errors 'reply=( $((($#PREFIX+$#SUFFIX)/3 )) numeric )'
zstyle ':completion::(^approximate*):*:functions' ignored-patterns '_*'




# correction
setopt correct                                                     
zstyle -e ':completion:*' completer '                              
    if [[ $_last_try != "$HISTNO$BUFFER$CURSOR" ]] ; then          
        _last_try="$HISTNO$BUFFER$CURSOR"                          
        reply=(_complete _match _ignored _prefix _files)           
    else                                                           
        if [[ $words[1] == (rm|mv) ]] ; then                       
            reply=(_complete _files)                               
        else                                                       
            reply=(_oldlist _expand _complete _ignored _correct _approximate _files)
        fi                                                         
    fi'                                                            


# magic url quoting
autoload -U url-quote-magic
zle -N self-insert url-quote-magic

# my aliases
alias ls='ls --color=auto'
alias l='ls -la'
alias lt='ls -rtl'
alias mplayer='mplayer -msgcolor'
alias diff='colordiff'


alias 0='return 0'

alias -g myip='print ${${$(LC_ALL=C /sbin/ifconfig eth0)[7]}:gs/addr://}'
alias scan_wlans="/sbin/iwlist scanning 2>/dev/null | grep -e 'Cell' -e 'Channel\:' -e 'Encryption' -e 'ESSID' -e 'WPA' | sed 's|Cell|\nCell|g'"
alias find_hosts="fping -a -g $(/sbin/ifconfig `/sbin/route -n | grep 'UG ' | head -n1 | awk {'print $8'}` | grep -i 'inet' | cut -f'2' -d':' | cut -f'1' -d' ' | cut -f'1-3' -d'.').1 $(/sbin/ifconfig `/sbin/route -n | grep 'UG '| head -n1 | awk {'print $8'}` | grep -i 'inet' | cut -f'2' -d':' | cut -f'1' -d' ' | cut -f'1-3' -d'.').254 2>/dev/null"
alias speedtest="wget -O- http://cachefly.cachefly.net/200mb.test >/dev/null"
alias -g G='| grep'


# less & grep color support
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'
#export GREP_OPTIONS='--color=auto'
export GREP_COLOR='1;32'

# Goodbye
ciao () {
    echo "Please come again!"
}
add-zsh-hook zshexit ciao

# change directory without cd
setopt autocd

# history
HISTFILE=~/.history

# Remember about a years worth of history (AWESOME)
SAVEHIST=10000
HISTSIZE=10000

# Don't overwrite, append!
setopt APPEND_HISTORY

# Write after each command
# setopt INC_APPEND_HISTORY

# Killer: share history between multiple shells
setopt SHARE_HISTORY

# If I type cd and then cd again, only save the last one
setopt HIST_IGNORE_DUPS

# Even if there are commands inbetween commands that are the same, still only save the last one
setopt HIST_IGNORE_ALL_DUPS

# Pretty Obvious.  Right?
setopt HIST_REDUCE_BLANKS

# If a line starts with a space, don't save it.
setopt HIST_IGNORE_SPACE
setopt HIST_NO_STORE

# When using a hist thing, make a newline show the change before executing it.
setopt HIST_VERIFY

# Save the time and how long a command ran
setopt EXTENDED_HISTORY

# Obvious history stuff
setopt HIST_SAVE_NO_DUPS
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS

# Set Git options for different work environments
export GIT_AUTHOR_NAME="Gaël Porté"
export GIT_AUTHOR_EMAIL="porte.gael@hotmail.fr"

alias emc="emacs"
alias emt="emacs -nw"
alias ec="emacsclient -c"
alias et="emacsclient -t"
alias ee="emacsclient -n"

# ls 
 alias ls='ls -h --color=auto'
 alias la='ls $LS_OPTIONS -lah'
 alias ll='ls $LS_OPTIONS -lh'
 alias l='ls $LS_OPTIONS'

# alias to avoid making mistakes:
 alias rm='rm -v'
 alias cp='cp -v'
 alias mv='mv -v'

# others
 alias ps='ps aux'
 alias ipt='iptables -L'
 alias net='netstat -apt'
 alias ifc='ifconfig'
 alias df='df -h'
 alias du='du -sh'
 alias pi='ping www.alice-dsl.de'

# apt-stuff
 alias inst='pacman -S'
  # purge or not
 remove (){
  echo "Konfigurationsdateien loeschen? j/n"
  read var
if [ $var = "j" ]; then
 aptitude purge ${1}
  elif [ $var = "n" ]; then
 aptitude remove ${1}
fi
}
 alias uinst='remove'

  #####
  ## pipe search through less
 search (){
 aptitude search ${1}|less;
}
 alias srch='search'
  ###

#export TERM=gnome-terminal
export TERMINAL=gnome-terminal

# start X11 in first prompt
#if [[ -z $DISPLAY && $XDG_VTNR -eq 1 ]]; then
#    exec startx
#fi




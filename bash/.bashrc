# If not running interactively, don't do anything
[ -z "$PS1" ] && return

PATH=$PATH:~/go/bin

HISTCONTROL=ignoredups:ignorespace
shopt -s histappend
PROMPT_COMMAND='history -a'
HISTSIZE=100000
HISTFILESIZE=100000
shopt -s checkwinsize
shopt -s cmdhist
shopt -s cdspell

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

function parse_git_branch {
    git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1) /'
}

function git_unadded_new {
    if git rev-parse --is-inside-work-tree &> /dev/null
    then
        if [[ -z $(git ls-files --other --exclude-standard 2> /dev/null) ]]
        then
            echo ""
        else
            echo "@ "
        fi
    fi
}

function git_needs_commit {
    if [[ "git rev-parse --is-inside-work-tree &> /dev/null)" != 'true' ]] && git rev-parse --quiet --verify HEAD &> /dev/null
    then
        git diff-index --cached --quiet --ignore-submodules HEAD 2> /dev/null
        (( $? && $? != 128 )) && echo "@ "
    fi
}

function git_modified_files {
    if [[ "git rev-parse --is-inside-work-tree &> /dev/null)" != 'true' ]] && git rev-parse --quiet --verify HEAD &> /dev/null
    then
        git diff --no-ext-diff --ignore-submodules --quiet --exit-code || echo "@ "
    fi
}

function short_pwd {
    echo $PWD | sed "s:${HOME}:~:" | sed "s:/\(.\)[^/]*:/\1:g" | sed "s:/[^/]*$:/$(basename $PWD):"
}

if [ `id -u` = 0 ]; then
    COLOUR="04;01;31m"
    PATH_COLOUR="01;31m"
    TIME_COLOUR="0;31m"
else
    COLOUR="01;32m"
    PATH_COLOUR="01;34m"
    TIME_COLOUR="0;33m"
fi

BOLD_RED="01;31m"
BOLD_GREEN="01;32m"
BOLD_BLUE="01;34m"


#PS1='${debian_chroot:+($debian_chroot)}\[\033[$COLOUR\]\u@\h\[\033[00m\]:\[\033[01;$PATH_COLOUR\]$(short_pwd)\[\033[00m\]\[\033[01;35m\]\n$(parse_git_branch)\[\033[00m\]\[\033[$BOLD_RED\]$(git_unadded_new)\[\033[00m\]\[\033[$BOLD_GREEN\]$(git_needs_commit)\[\033[00m\]\[\033[$BOLD_BLUE\]$(git_modified_files)\[\033[00m\]> '
# PS1='${debian_chroot:+($debian_chroot)}\[\033[$COLOUR\]\u@\h\[\033[00m\]:\[\033[01;$PATH_COLOUR\]$(short_pwd)\[\033[00m\] \[\033[01;35m\]$(parse_git_branch)\[\033[00m\]\[\033[$BOLD_RED\]$(git_unadded_new)\[\033[00m\]\[\033[$BOLD_GREEN\]$(git_needs_commit)\[\033[00m\]\[\033[$BOLD_BLUE\]$(git_modified_files)\[\033[00m\]> '

unset color_prompt force_color_prompt

case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=always'
    alias grep='grep --color=always'
    alias fgrep='fgrep --color=always'
    alias egrep='egrep --color=always'
fi

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias less='less -R'
alias emacs='emacs -nw'
# alias git='hub'
alias dist-upgrade='sudo apt-get update && sudo apt-get dist-upgrade && sudo apt-get autoremove && sudo apt-get autoclean'
alias pip-upgrade='pip freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs pip install -U'
# Git
alias ga='git add'
alias gci='git commit'
alias gst='git st'
alias gt='git tag'
alias gps='git push'
alias gpl='git pull'
alias gbr='git branch'
alias gco='git co'
alias grm='git rm'
alias gmv='git mv'
alias gcl='git clone'



if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python
export WORKON_HOME=/home/igniteflow/.virtualenvs
export VIRTUALENVWRAPPER_LOG_DIR="$WORKON_HOME"
export VIRTUALENVWRAPPER_HOOK_DIR="$WORKON_HOME"
alias workoff='deactivate'
source /usr/local/bin/virtualenvwrapper.sh
export PYTHONSTARTUP=~/.pythonrc
export PYTHONSTARTUP=~/.pystartup

# pip bash completion start
_pip_completion()
{
    COMPREPLY=( $( COMP_WORDS="${COMP_WORDS[*]}" \
                   COMP_CWORD=$COMP_CWORD \
                   PIP_AUTO_COMPLETE=1 $1 ) )
}
complete -o default -F _pip_completion pip
# pip bash completion end

function colourless() {
    if [ $# -ne 1 ]
    then
        # assume pipe
        while read -r data
        do
            sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"
        done
    else
        sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g" $1
    fi
}

# external monitor setup
xrandr --output eDP1 --mode 1920x1080 --left-of HDMI1
xrandr --output HDMI1 --mode 1920x1080

# Reset
Color_Off="\[\033[0m\]"       # Text Reset

# Regular Colors
Black="\[\033[0;30m\]"        # Black
Red="\[\033[0;31m\]"          # Red
Green="\[\033[0;32m\]"        # Green
Yellow="\[\033[0;33m\]"       # Yellow
Blue="\[\033[0;34m\]"         # Blue
Purple="\[\033[0;35m\]"       # Purple
Cyan="\[\033[0;36m\]"         # Cyan
White="\[\033[0;37m\]"        # White

# Bold
BBlack="\[\033[1;30m\]"       # Black
BRed="\[\033[1;31m\]"         # Red
BGreen="\[\033[1;32m\]"       # Green
BYellow="\[\033[1;33m\]"      # Yellow
BBlue="\[\033[1;34m\]"        # Blue
BPurple="\[\033[1;35m\]"      # Purple
BCyan="\[\033[1;36m\]"        # Cyan
BWhite="\[\033[1;37m\]"       # White

# Underline
UBlack="\[\033[4;30m\]"       # Black
URed="\[\033[4;31m\]"         # Red
UGreen="\[\033[4;32m\]"       # Green
UYellow="\[\033[4;33m\]"      # Yellow
UBlue="\[\033[4;34m\]"        # Blue
UPurple="\[\033[4;35m\]"      # Purple
UCyan="\[\033[4;36m\]"        # Cyan
UWhite="\[\033[4;37m\]"       # White

# Background
On_Black="\[\033[40m\]"       # Black
On_Red="\[\033[41m\]"         # Red
On_Green="\[\033[42m\]"       # Green
On_Yellow="\[\033[43m\]"      # Yellow
On_Blue="\[\033[44m\]"        # Blue
On_Purple="\[\033[45m\]"      # Purple
On_Cyan="\[\033[46m\]"        # Cyan
On_White="\[\033[47m\]"       # White

# High Intensty
IBlack="\[\033[0;90m\]"       # Black
IRed="\[\033[0;91m\]"         # Red
IGreen="\[\033[0;92m\]"       # Green
IYellow="\[\033[0;93m\]"      # Yellow
IBlue="\[\033[0;94m\]"        # Blue
IPurple="\[\033[0;95m\]"      # Purple
ICyan="\[\033[0;96m\]"        # Cyan
IWhite="\[\033[0;97m\]"       # White

# Bold High Intensty
BIBlack="\[\033[1;90m\]"      # Black
BIRed="\[\033[1;91m\]"        # Red
BIGreen="\[\033[1;92m\]"      # Green
BIYellow="\[\033[1;93m\]"     # Yellow
BIBlue="\[\033[1;94m\]"       # Blue
BIPurple="\[\033[1;95m\]"     # Purple
BICyan="\[\033[1;96m\]"       # Cyan
BIWhite="\[\033[1;97m\]"      # White

# High Intensty backgrounds
On_IBlack="\[\033[0;100m\]"   # Black
On_IRed="\[\033[0;101m\]"     # Red
On_IGreen="\[\033[0;102m\]"   # Green
On_IYellow="\[\033[0;103m\]"  # Yellow
On_IBlue="\[\033[0;104m\]"    # Blue
On_IPurple="\[\033[10;95m\]"  # Purple
On_ICyan="\[\033[0;106m\]"    # Cyan
On_IWhite="\[\033[0;107m\]"   # White

# Various variables you might want for your PS1 prompt instead
Time12h="\T"
Time12a="\@"
PathShort="\w"
PathFull="\W"
NewLine="\n"
Jobs="\j"


# This PS1 snippet was adopted from code for MAC/BSD I saw from: http://allancraig.net/index.php?option=com_content&view=article&id=108:ps1-export-command-for-git&catid=45:general&Itemid=96
# I tweaked it to work on UBUNTU 11.04 & 11.10 plus made it mo' better

export PS1=$IBlack$Time12h$Color_Off'$(git branch &>/dev/null;\
if [ $? -eq 0 ]; then \
  echo "$(echo `git status` | grep "nothing to commit" > /dev/null 2>&1; \
  if [ "$?" -eq "0" ]; then \
    # @4 - Clean repository - nothing to commit
    echo "'$Green'"$(__git_ps1 " (%s)"); \
  else \
    # @5 - Changes to working tree
    echo "'$IRed'"$(__git_ps1 " {%s}"); \
  fi) '$BYellow$PathShort$Color_Off'\$ "; \
else \
  # @2 - Prompt when not in GIT repo
  echo " '$Yellow$PathShort$Color_Off'\$ "; \
fi)'

# add appengine to PATH
export PATH=$HOME/Applications/google_appengine:$PATH

# set VIM as the default editor
export EDITOR=vim

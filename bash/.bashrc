# If not running interactively, don't do anything
#[ -z "$PS1" ] && return

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
    git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(git\:\1) /'
}

function git_unadded_new {
    if git rev-parse --is-inside-work-tree &> /dev/null
    then
        if [[ -z $(git ls-files --other --exclude-standard 2> /dev/null) ]]
        then
            echo ""
        else
            echo "a "
        fi
    fi
}

function git_needs_commit {
    if [[ "git rev-parse --is-inside-work-tree &> /dev/null)" != 'true' ]] && git rev-parse --quiet --verify HEAD &> /dev/null
    then
        git diff-index --cached --quiet --ignore-submodules HEAD 2> /dev/null
        (( $? && $? != 128 )) && echo "c "
    fi
}

function git_modified_files {
    if [[ "git rev-parse --is-inside-work-tree &> /dev/null)" != 'true' ]] && git rev-parse --quiet --verify HEAD &> /dev/null
    then
        git diff --no-ext-diff --ignore-submodules --quiet --exit-code || echo "m "
    fi
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

PS1='\[\033[$TIME_COLOUR\][$(date +%H:%M)]\[\033[00m\] ${debian_chroot:+($debian_chroot)}\[\033[$COLOUR\]\u@\h\[\033[00m\]:\[\033[01;$PATH_COLOUR\]\w\[\033[00m\]\[\033[01;35m\] $(parse_git_branch)\[\033[00m\]\[\033[$BOLD_RED\]$(git_unadded_new)\[\033[00m\]\[\033[$BOLD_GREEN\]$(git_needs_commit)\[\033[00m\]\[\033[$BOLD_BLUE\]$(git_modified_files)\[\033[00m\]\n\[\033[$TIME_COLOUR\]\!:\#\[\033[00m\] $ '

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
#alias git='hub'
alias dist-upgrade='sudo apt-get update && sudo apt-get dist-upgrade && sudo apt-get autoremove && sudo apt-get autoclean'
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
#python
alias pypy1.9='/opt/pypy-1.9/bin/pypy'
alias pypy2.0='/opt/pypy-2.0/bin/pypy'
alias pip-pypy1.9='/opt/pypy-1.9/bin/pip'
alias pip-pypy2.0='/opt/pypy-2.0/bin/pip'
alias ipython-pypy1.9='/opt/pypy-1.9/bin/ipython'
alias ipython-pypy2.0='/opt/pypy-2.0/bin/ipython'

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python
export WORKON_HOME=/home/ptysoe/.virtualenvs
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

function pgp-search() {
  if [ $# -ne 1 ]
  then
    echo "Usage: gpg-search TERM"
  else
    gpg --search-keys --keyserver keyserver.tangentlabs.co.uk $1
  fi
}

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



#function mkvirtualenv() {
#    if [[ $# -ne 2 ]]
#    then
#        echo "Usage: mkvirtualenv PYTHON_VER NAME"
#        exit;
#    fi
#    PY_VER=$1
#    NAME=$2
#    virtualenv -p $PY_VER /home/ptysoe/.virtualenvs/$NAME-$PY_VER
#}

#function _mkvirtualenv() {
#    cur="${COMP_WORDS[COMP_CWORD]}"
#    py="python2.5 python2.6 python2.7 python3.1 python3.2 python3.3 pypy1.9 pypy2.0"
#    COMPREPLY=($(compgen -W "${py}" -- ${cur}))
#}

#complete -F _mkvirtualenv mkvirtualenv

export EDITOR=vim

#export PYTHONPATH=$PYTHONPATH:~/Applications/google_appengine
#export PATH=$PATH:~/Applications/google_appengine

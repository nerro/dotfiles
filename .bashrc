######################################################################
#                                                                    #
# This file contains settings for interactive command processor BASH #
# like path, exports, aliases and command prompt.                    #
#                                                                    #
######################################################################

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS
shopt -s checkwinsize
shopt -s histappend

#========
# COLORS
#========

# reset
color_off='\e[m'

# regular colors
color_black='\e[0;30m'
color_red='\e[0;31m'
color_green='\e[0;32m'
color_yellow='\e[0;33m'
color_blue='\e[0;34m'
color_purple='\e[0;35m'
color_cyan='\e[0;36m'
color_white='\e[0;37m'

# other colors
color_bblack='\e[1;30m'
color_bred='\e[1;31m'
color_bgreen='\e[1;32m'
color_byellow='\e[1;33m'
color_bblue='\e[1;34m'
color_bpurple='\e[1;35m'
color_bcyan='\e[1;36m'
color_bwhite='\e[1;37m'


#=========
# ALIASES
#=========
alias ls='ls --color=auto'
alias ll='ls -l'
alias la='ls -la'
alias lx='ls -lXB'
alias lu='ls -lur'
alias lt='lt -ltr'
alias .='pwd'
alias ..='cd ..'
alias ...='cd ../..'
alias vi='vim'
alias poweroff='sudo systemctl poweroff'
alias reboot='sudo systemctl reboot'


#===============
# ENV & EXPORTS
#===============
export HISTCONTROL=ignoreboth
export HISTSIZE=10000
export HISTFILESIZE=25000
export HISTTIMEFORMAT='[%d.%m.%Y %H:%M:%S] - '
export HISTIGNORE='ls:la:ll'


#======
# PATH
#======
JAVA_BIN=$(which java 2>/dev/null)
if [ -z $JAVA_BIN ]; then
  export JAVA_HOME="/opt/java/jdk1.7"
  PATH=$PATH:$JAVA_HOME/bin
fi

SCALA_BIN=$(which scala 2>/dev/null)
if [ -z $SCALA_BIN ]; then
  export SCALA_HOME="/opt/scala/scala"
  PATH=$PATH:$SCALA_HOME/bin
fi

RVM_BIN=$(which rvm 2>/dev/null)
if [ -z $RVM_BIN ]; then
  # Add RVM to PATH for scripting
  PATH=$PATH:$HOME/.rvm/bin
fi


#================
# COMMAND PROMPT
#================
PS1_GIT_BIN=$(which git 2>/dev/null)
COLUMNS=120

LOCAL_HOSTNAME=$HOSTNAME

function prompt_command() {
  local PS1_GIT=
  local GIT_BRANCH=
  local GIT_DIRTY=
  local PWDNAME=$PWD

  # beautify working directory name
  if [[ "${HOME}" == "${PWD}" ]]; then
    PWDNAME="~"
  elif [[ "${HOME}" == "${PWD:0:${#HOME}}" ]]; then
    PWDNAME="~${PWD:${#HOME}}"
  fi

  # parse git status and get git variables
  if [[ ! -z $PS1_GIT_BIN ]]; then
    # check we are in git repo
    local CUR_DIR=$PWD
    while [[ ! -d "${CUR_DIR}/.git" ]] && [[ ! "${CUR_DIR}" == "/" ]] && [[ ! "${CUR_DIR}" == "~" ]] && [[ ! "${CUR_DIR}" == "" ]]; do CUR_DIR=${CUR_DIR%/*}; done
    if [[ -d "${CUR_DIR}/.git" ]]; then
      # 'git repo for dotfiles' fix: show git status only in home dir and other git repos
      if [[ "${CUR_DIR}" != "${HOME}" ]] || [[ "${PWD}" == "${HOME}" ]]; then
        # get git branch
        GIT_BRANCH=$($PS1_GIT_BIN symbolic-ref HEAD 2>/dev/null)
        if [[ ! -z $GIT_BRANCH ]]; then
          GIT_BRANCH=${GIT_BRANCH#refs/heads/}

          # get git status
          local GIT_STATUS=$($PS1_GIT_BIN status --porcelain 2>/dev/null)
          [[ -n $GIT_STATUS ]] && GIT_DIRTY=1
        fi
      fi
    fi
  fi

  # build black/white prompt for git
  [[ ! -z $GIT_BRANCH ]] && PS1_GIT=" (branch: ${GIT_BRANCH})"

  # calculate prompt length
  local PS1_LENGTH=$((${#USER}+${#LOCAL_HOSTNAME}+${#PWDNAME}+${#PS1_GIT}+3))
  local FILL=

  # if length is greater, then terminal width
  if [[ $PS1_LENGTH -gt $COLUMNS ]]; then
    # strip working directory name
    PWDNAME="...${PWDNAME:$(($PS1_LENGTH-$COLUMNS+3))}"
  else
    # else calculate fillsize
    local fillsize=$(($COLUMNS-$PS1_LENGTH))
    FILL=$color_black
    while [[ $fillsize -gt 0 ]]; do FILL="${FILL}─"; fillsize=$(($fillsize-1)); done
    FILL="${FILL}${color_off}"
  fi

  # build git status for prompt
  if [[ ! -z $GIT_BRANCH ]]; then
    if [[ -z $GIT_DIRTY ]]; then
      PS1_GIT=" (branch: ${color_green}${GIT_BRANCH}${color_off})"
    else
      PS1_GIT=" (branch: ${color_red}${GIT_BRANCH}${color_off})"
    fi
  fi

  # set new color prompt
  PS1="${color_black}${USER}@${LOCAL_HOSTNAME}:${color_off}${color_purple}${PWDNAME}${color_off} ${FILL}${PS1_GIT}\n► "
}

# set propt command
PROMPT_COMMAND=prompt_command
PS1='[\t] \u@\h:\w \$ '


if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

RESET="\[\017\]"
NORMAL="\[\033[0m\]"
RED="\[\033[31;1m\]"
YELLOW="\[\033[33;1m\]"
WHITE="\[\033[37;1m\]"
CYAN="\[\033[0;34m\]"

SMILEY="${WHITE}:)${NORMAL}"
FROWNY="${RED}:(${NORMAL}"

SELECT="if [ \$? = 0 ]; then echo \"${SMILEY}\"; else echo \"${FROWNY}\"; fi"

PS1="${RESET}${CYAN}\u@\h \W${NORMAL} \`${SELECT}\` ${YELLOW}>${NORMAL} "

if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi

alias g='git'
alias god='git rebase -i --root'

alias cp='cp -iv'
alias ls='ls -FG'
alias ll='ls -FGlAhp'
alias mv='mv -iv'
alias rm='rm -iv'
alias mv='mv -iv'

up() { cd $(eval printf '../'%.0s {1..$1}) && pwd; }

cdls() { cd "$1"; ls;}

ex ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1   ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *.deb)       ar x $1      ;;
      *.tar.xz)    tar xf $1    ;;
      *.tar.zst)   unzstd $1    ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

runInOwnNamespace() {
    unshare -c --fork --pid --mount-proc "$1"
}

GOPATH="$HOME/go"
GOBIN="$HOME/go/bin"
PATH="$HOME/go/bin:$PATH"

JAVA_HOME="/usr/lib/jvm/java-8-openjdk"

export Agda_datadir=/home/herulume/Downloads/Agda-nightly/data
PATH=/home/herulume/Downloads/Agda-nightly/bin:${PATH}

if [ -d "$HOME/.cargo/" ]; then
    source "$HOME/.cargo/env"
fi

if [ -d "$HOME/.asdf/" ]; then
    . $HOME/.asdf/asdf.sh
    . $HOME/.asdf/completions/asdf.bash
fi

export PATH

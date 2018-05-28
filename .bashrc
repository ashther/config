# Custom bash prompt via kirsle.net/wizards/ps1.html
export PS1="\[$(tput bold)\]\[$(tput setaf 1)\][\[$(tput setaf 3)\]\u\[$(tput setaf 2)\]@$(ifconfig|grep "inet 192.168.1"|awk '{print $2}'|cut -d . -f4) \[$(tput setaf 4)\]\H \[$(tput setaf 5)\]\W\[$(tput setaf 1)\]]\[$(tput setaf 6)\] \t\[$(tput setaf 7)\] \\$ \[$(tput sgr0)\]"

alias ll="ls -lht"
# cp ~/go/bin/ccat /usr/bin/ccat
alias cat="ccat -G String='green' -G Keyword='red' -G Comment='darkgray' -G Punctuation='brown' -G Plaintext='lightgray'"

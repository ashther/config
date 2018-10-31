# Custom bash prompt via kirsle.net/wizards/ps1.html
export PS1="\[$(tput bold)\]\[$(tput setaf 1)\][\[$(tput setaf 3)\]\u\[$(tput setaf 2)\]@$(ifconfig|grep "inet 192.168.1"|awk '{print $2}'|cut -d . -f4) \[$(tput setaf 4)\]\H \[$(tput setaf 5)\]\W\[$(tput setaf 1)\]]\[$(tput setaf 6)\] \t\[$(tput setaf 7)\] \\$ \[$(tput sgr0)\]"
export BAT_THEME="OneHalfDark"

alias ll="ls -lht"

# wget -O bat.zip https://github.com/sharkdp/bat/releases/download/v0.7.1/bat-v0.7.1-x86_64-unknown-linux-musl.tar.gz
# tar -xvzf bat.zip -C /usr/local
# cd /usr/local && mv bat-v0.7.1-x86_64-unknown-linux-musl bat
alias bat="/usr/local/bat/bat"

alias nts="echo 123456 | sudo -S netstat -antp | grep -v :8787 | grep -v :3306"
alias dog="highlight -O ansi --force"
alias tom="pygmentize -g"
alias dps="docker ps -a"
alias dim="docker images"

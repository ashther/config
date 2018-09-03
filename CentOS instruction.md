### 配置`.bashrc`
```bash
# Custom bash prompt via kirsle.net/wizards/ps1.html
# change the "inet 192.168.1"
export PS1="\[$(tput bold)\]\[$(tput setaf 1)\][\[$(tput setaf 3)\]\u\[$(tput setaf 2)\]@$(ifconfig|grep "inet 192.168.1"|awk '{print $2}'|cut -d . -f4) \[$(tput setaf 4)\]\H \[$(tput setaf 5)\]\W\[$(tput setaf 1)\]]\[$(tput setaf 6)\] \t\[$(tput setaf 7)\] \\$ \[$(tput sgr0)\]"

alias ll="ls -lht"
```
### 添加sudo权限
```bash
$ chmod u+w /etc/sudoers
$ vim /etc/sudoers
# 在root ALL=(ALL) ALL下添加
USERNAME ALL=(ALL) ALL
$ chmod u-w /etc/sudoers
```

### 修改软件源为国内镜像
```bash
# 备份原文件
$ sudo mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak

#CentOS 7
$ sudo wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

# 生成缓存
$ sudo yum makecache
```

### 安装go和ccat
```bash
$ sudo yum install go
$ go get -u github.com/jingweno/ccat # 也可以下载源码解压至PATH路径下

# 替换cat为ccat，在.bashrc末尾加入
alias cat="ccat -G String='green' -G Keyword='red' -G Comment='darkgray' -G Punctuation='brown' -G Plaintext='lightgray'"
```

### 其他常用设置
```bash
# 改系统语言
$ sudo vim /etc/locale.conf # 将zh_CN改为en_US

# 改图形界面为命令行界面
$ sudo systemctl set-default multi-user.target # 重启后生效
# 改为图形界面
$ sudo systemctl set-default graphical.target

# 使用宿主机的shadowsocksR代理
# 在宿主机的ss中选择“允许来自局域网的连接”
# 在虚拟机的/etc/profile文件中添加以下内容
http_proxy=http://username:password@yourproxy:1080/ # 如无密码则为yourproxy:1080
https_proxy=http://username:password@yourproxy:1080/
export http_proxy
export https_proxy
# 重新登录
# 对于yum，还需在/etc/yum.conf中添加
proxy=http://username:password@yourproxy:1080/

# 查看是否安装某包
$ rpm -qa|grep PACKAGE # rpm安装
$ yum list installed|grep PACKAGE # yum安装
```


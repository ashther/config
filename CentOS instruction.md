### 安装CentOS时报unknown chipset错误
1. select operating system and press 'e' to enter the grub
2. select kernel in the list and press 'e' again to enter kernel boot options 
3. add `nomodeset rdblacklist=nouveau` after `quiet`
4. Install the system

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

### 关于安全
向公网开放端口的机器必须考虑安全问题

#### 修改密码
1. root用户使用12位及以上强密码，包括大小写英文、数字、符号；
2. 普通用户可以使用便于记忆的强密码，方便使用sudo；

#### 修改22端口
```bash
vim /etc/ssh/sshd_config
# 暂时先保留22端口，避免新端口出错登陆不了
Port 22
Port 333

# 防火墙放行
firewall-cmd --zone=public --add-port=333/tcp --permanent
firewall-cmd --reload

# 修改SELinux
semanage port -a -t ssh_port_t -p tcp 333 # 添加端口
semanage port -l | grep ssh # 确认

systemctl restart sshd # 重启重新登陆新端口333后注释掉原来的22端口
```

#### 修改3306端口
```bash
vim /etc/my.cnf
# add this under [mysqld] section
port=3307

# 修改SELinux
semanage port -a -t mysqld_port_t -p tcp 3307 # 添加端口
semanage port -l | grep mysql # 确认

systemctl restart mariadb
```

#### 修改数据库用户名和密码
限制root用户只能本地访问，可以远程访问的普通用户使用强密码
```sql
-- 修改能够远程访问的用户USER的密码
set password for 'USER'@'%'=password('NEW-PASSWORD');
flush privileges;
```

#### 防止暴力破解
```bash
yum install fail2ban
vim /etc/fail2ban/jail.local 

# 新建配置如下
# ignoreip白名单，bantime屏蔽时间，findtime时间范围，maxretry最大尝试次数，banaction屏蔽所使用方法
[DEFAULT]
ignoreip = 127.0.0.1/8, 210.26.116.11
bantime  = 86400
findtime = 600
maxretry = 5
banaction = firewallcmd-ipset
action = %(action_mwl)s

systemctl start fail2ban
systemctl enable fail2ban
```

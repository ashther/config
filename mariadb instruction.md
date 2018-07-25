### 安装与启动
```bash
$ sudo yum install mariadb mariadb-server mariadb-devel
$ sudo systemctl start mariadb # 立刻启动
$ sudo systemctl enable mariadb # 随系统启动时启动


# 在centOS系统上可能需要打开3306端口
$ sudo firewall-cmd --zone=public --add-port=3306/tcp --permanent
$ sudo firewall-cmd --reload

# 为初始化账户root添加密码
# 首先要求输入当前用户密码，首次使用为空直接回车，然后一路y就可以了
$ mysql_secure_installation  
```

### 用户管理
```sql
# 'username'@'localhost'
create user 'USERNAME'@'%' identified by 'PASSWORD';

# grant select on...
grant all on *.* to 'USERNAME'@'%';

flush privileges;
```

### 建库
```sql
set names utf8;
CREATE DATABASE mydatabase CHARACTER SET utf8 COLLATE utf8_general_ci;
use mydatabase;
```

### 配置文件
```bash
[mysqld]
collation-server = utf8_general_ci # 中文地区不是utf8_unicode_ci
init-connect='SET NAMES utf8'
character-set-server = utf8
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0
# Settings user and group are ignored when systemd is used.
# If you need to run mysqld under a different user or group,
# customize your systemd unit file for mariadb according to the
# instructions in http://fedoraproject.org/wiki/Systemd

[mysqld_safe]
log-error=/var/log/mariadb/mariadb.log
pid-file=/var/run/mariadb/mariadb.pid

#
# include all files from the config directory
#
!includedir /etc/my.cnf.d

[client]
default-character-set=utf8

[mysql]
default-character-set=utf8
```

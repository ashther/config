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

### trouble shooting
启动mysql的docker容器时，可能会遇到2058错误，需要进入容器并进入mysql`mysql -u root -p`后，执行以下sql
```sql
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';
```

在使用RMySQL向mysql8.0版本插入数据时可能会遇到错误`Error in .local(conn, statement, ...) : 
    could not run statement: The used command is not allowed with this MySQL version`，有两种解决方案
1. 修改配置文件`/etc/mysql/my.cnf`，在`[mysqld]`行下加入`local-infile=1`，重启mysql；
2. 进入mysql后执行`SET GLOBAL local_infile = true;`，确认是否已修改`SHOW GLOBAL VARIABLES LIKE 'local_infile';`，输出应为ON

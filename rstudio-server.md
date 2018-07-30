### [rstudio-server的安装](https://www.rstudio.com/products/rstudio/download-server/)
升级rstudio-server时可直接覆盖安装，但是升级pro版时需要参考[Rstudio官方文档](https://support.rstudio.com/hc/en-us/articles/216079967-Upgrading-RStudio-Server)
```bash
$ wget https://download2.rstudio.org/rstudio-server-rhel-0.99.903-x86_64.rpm
$ sudo yum install --nogpgcheck rstudio-server-rhel-0.99.903-x86_64.rpm

# 在centOS系统上可能需要打开8787端口
# 如果是在虚拟机安装的rstudio server，希望局域网内访问时，除了在虚拟机和宿主机之间建立端口映射外，应打开windows的特定端口：
# To open a port in the Windows firewall for TCP access
# On the Start menu, click Run, type WF.msc, and then click OK.
# In the Windows Firewall with Advanced Security, in the left pane, right-click Inbound Rules, and then click New Rule in the action pane.
# In the Rule Type dialog box, select Port, and then click Next.
# In the Protocol and Ports dialog box, select TCP. Select Specific local ports, and then type the port number of the instance of the Database Engine, such as 1433 for the default instance. Click Next.
# In the Action dialog box, select Allow the connection, and then click Next.
# In the Profile dialog box, select any profiles that describe the computer connection environment when you want to connect to the Database Engine, and then click Next.
# In the Name dialog box, type a name and description for this rule, and then click Finish.
$ sudo firewall-cmd --zone=public --add-port=8787/tcp --permanent
$ sudo firewall-cmd --reload
######################## maybe not working ########################
# $ sudo iptables -I INPUT -p tcp --dport 8787 -j ACCEPT # 有可能防火墙未打开8787端口，需要手动开启
# # 使用虚拟机安装rstudio server后，应配置远程访问虚拟机，可以在VM的虚拟网络编辑器中使用NAT模式，修改VMnet8的设置，添加端口映射。需要注意在网络和共享中心里不要禁用VMnet8！
# $ sudo service iptables save # 永久保存iptables规则，否则重启后规则将重置
# # 如果提示使用systemctl则可能未安装iptables-services
######################## maybe not working ########################

$ sudo rstudio-server stop 
$ sudo rstudio-server start
$ sudo rstudio-server restart

$ sudo rstudio-server active-sessions 
$ sudo rstudio-server suspend-session <pid>
$ sudo rstudio-server suspend-all

$ sudo rstudio-server offline # 会给当前连接用户下线提示
$ sudo rstudio-server online

# 0 6 * * * /sbin/restart rstudio-server >/dev/null 2>&1
```
### [shiny-server的安装](https://www.rstudio.com/products/shiny/download-server/)
```bash
$ wget https://download3.rstudio.org/centos5.9/x86_64/shiny-server-1.4.6.809-rh5-x86_64.rpm
$ sudo yum install --nogpgcheck shiny-server-1.4.6.809-rh5-x86_64.rpm

$ sudo start shiny-server
$ sudo stop shiny-server
$ sudo restart shiny-server # restart模式不会读取/etc/init/shiny-server.conf中的改动

# 0 6 * * * /sbin/restart shiny-server >/dev/null 2>&1
```
### R的安装
#### Linux平台的安装
```bash
$ sudo yum install epel-release
$ sudo yum update
$ sudo yum install R
```

#### cent OS平台上必要包的安装
```bash
$ sudo yum install libcurl-devel
$ sudo yum install openssl-devel
$ sudo yum install libxml2-devel
```

#### Windows平台的安装
选择[镜像](https://cran.r-project.org/mirrors.html)，选择国内镜像比如[清华大学](https://mirrors.tuna.tsinghua.edu.cn/CRAN/)就可以下载安装了

### 用户创建和加入sudoers
```bash
$ sudo adduser apple
$ sudo passwd apple
$ vim /etc/sudoers # 找到 root ALL=(ALL) ALL 在这行下边添加 apple ALL=(ALL) ALL
```
### shiny用户安装shiny等包
多数包可以通过`install.packages('PACKAGE_NAME', repos = 'http://cran.rstudio.com/')`的方式安装，但是有的包如`Rcpp`或者`httpuv`等还是会报无法编译的错，可以先查看`yum list R-\*`是否包含需要安装的包，如果有就直接`yum install PACKAGE_NAME`，此外也可以使用如下办法安装：  
```bash
$ wget http://cran.r-project.org/src/contrib/Rcpp_0.11.1.tar.gz
$ sudo R CMD INSTALL --build Rcpp_0.11.1.tar.gz

$ wget http://cran.r-project.org/src/contrib/httpuv_1.2.3.tar.gz
$ sudo R CMD INSTALL --build httpuv_1.2.3.tar.gz
```
### 关于安装r包能让所有用户使用
```diff
+ 强烈建议使用root用户或者`sudo R`进入R安装各种包，使包能被安装至`/usr/lib64/R/library/`
```

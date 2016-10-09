### [rstudio-server的安装](https://www.rstudio.com/products/rstudio/download-server/)
```bash
$ wget https://download2.rstudio.org/rstudio-server-rhel-0.99.903-x86_64.rpm
$ sudo yum install --nogpgcheck rstudio-server-rhel-0.99.903-x86_64.rpm

$ sudo rstudio-server stop 
$ sudo rstudio-server start
$ sudo rstudio-server restart

$ sudo rstudio-server active-sessions 
$ sudo rstudio-server suspend-session <pid>
$ sudo rstudio-server suspend-all

$ sudo rstudio-server offline # 会给当前连接用户下线提示
$ sudo rstudio-server online

0 6 * * * /sbin/restart rstudio-server >/dev/null 2>&1
```
### [shiny-server的安装](https://www.rstudio.com/products/shiny/download-server/)
```bash
$ wget https://download3.rstudio.org/centos5.9/x86_64/shiny-server-1.4.6.809-rh5-x86_64.rpm
$ sudo yum install --nogpgcheck shiny-server-1.4.6.809-rh5-x86_64.rpm

$ sudo start shiny-server
$ sudo stop shiny-server
$ sudo restart shiny-server # restart模式不会读取/etc/init/shiny-server.conf中的改动

0 6 * * * /sbin/restart shiny-server >/dev/null 2>&1
```
### R的安装
```bash
$ sudo yum install epel-release
$ sudo yum update
$ sudo yum install R
```
### 用户创建和加入sudoers
```bash
$ sudo adduser apple
$ sudo passwd apple
vim /etc/sudoers 找到 root ALL=(ALL) ALL 在这行下边添加 apple ALL=(ALL) ALL
```
### shiny用户安装shiny等包
多数包可以通过`install.packages('PACKAGE_NAME', repos = 'http://cran.rstudio.com/')`的方式安装，但是有的包如`Rcpp`或者`httpuv`等还是会报无法编译的错，可以先查看`yum list R-\*`是否包含需要安装的包，如果有就直接`yum install PACKAGE_NAME`，此外也可以使用如下办法安装：  
```bash
wget http://cran.r-project.org/src/contrib/Rcpp_0.11.1.tar.gz
sudo R CMD INSTALL --build Rcpp_0.11.1.tar.gz

wget http://cran.r-project.org/src/contrib/httpuv_1.2.3.tar.gz
sudo R CMD INSTALL --build httpuv_1.2.3.tar.gz
```

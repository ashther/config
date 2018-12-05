### init
* [官网](https://www.raspberrypi.org/downloads/raspbian/)下载raspbian
* 使用Win32DiskImager将raspbian烧录至TF卡中，如果TF卡不是空的应首先使用SD Formatter格式化
* 在`sudo raspi-config`中设置启动到命令行并打开SSH

### monitoring script
```python
#! /usr/bin/python
# -*- coding: utf-8 -*-

import os

# print('============ temperature ============\n')
temp = os.popen('vcgencmd measure_temp').readlines()
print('\n temp:' + temp[0].replace('temp=', ''))

# print('============== memory ===============\n')
temp = os.popen('free -tmh').readlines()[1].split()
print(' total:' + temp[1] + 
      ' used: ' + temp[2] + 
      ' free: ' + temp[3] + 
      ' avaliable: ' + temp[6] + 
      '\n')

# print('================ cpu ================\n')
temp = os.popen('uptime').readlines()[0].split()[-3:]
print(' load average: ' + ' '.join(temp) + '\n')

# print('================ df =================\n')
temp = os.popen('df / -h').readlines()[1].split()
print(' total: ' + temp[1] + 
      ' used: ' + temp[2] + 
      ' free: ' + temp[3] + 
      ' ratio: ' + temp[4] + 
      '\n')
```

### install R
```bash
# some dependencies
sudo apt-get -y update
sudo apt-get -y install libxml2-dev libssl-dev libcurl4-openssl-dev libssh2-1-dev

sudo echo "deb http://http://mirrors.nics.utk.edu/cran/bin/linux/debian stretch-cran34/" >> /etc/apt/sources.list
sudo cat /etc/apt/sources.list

sudo apt-get -y update
sudo apt-get -y install r-base r-base-dev
```

安装`fs`包时碰到`undefined symbol`问题，参考了(这里)[https://github.com/r-lib/fs/issues/128#issuecomment-435552967]：
```bash
wget https://cran-r.c3sl.ufpr.br/src/contrib/fs_1.2.6.tar.gz
tar zxvf path/to/fs

# modify path/to/fs/src/Makevars
ifeq ($(UNAME), Linux) 
PKG_LIBS += -pthread # Add this line here
OBJECTS +=  bsd/setmode.o bsd/strmode.o bsd/reallocarray.o 
endif 

sudo R
install.packages("/path/to/fs", repos = NULL, type="source")
```

安装`later`包时碰到`undefined symbol`问题，参考了(这里)[https://github.com/r-lib/later/issues/73]：
```bash
git clone https://github.com/r-lib/later.git
sudo apt-get install libboost-atomic-dev #optional if you don't have libboost

# modify later/src/Makevars.in
#comment following line:
#PKG_LIBS = -pthread @libs@
#Paste and replace it for this one:
PKG_LIBS = -pthread -lboost_atomic @libs@ #libs is on lowercase

sudo R
install.packages("/path/to/later", repos = NULL, type="source") 
```

### install shiny-server
#### install cmake
```bash
sudo apt-get -y update

cd ~/Downloads/
wget http://www.cmake.org/files/v2.8/cmake-2.8.11.2.tar.gz
tar xzf cmake-2.8.11.2.tar.gz
cd cmake-2.8.11.2
./configure
make
sudo make install
```

#### build shiny-server from source
主要参考rstudio[官方说明](https://github.com/rstudio/shiny-server/wiki/Building-Shiny-Server-from-Source#installation)
```bash
git clone https://github.com/rstudio/shiny-server.git

cd shiny-server
mkdir tmp
cd tmp

DIR=`pwd`
PATH=$DIR/../bin:$PATH
PYTHON=`which python`

# Check the version of Python. If it's not 2.6.x or 2.7.x, see https://github.com/rstudio/shiny-server/wiki/Building-Shiny-Server-from-Source#frequently-asked-questions.
$PYTHON --version

cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DPYTHON="$PYTHON" ../

make
mkdir ../build

(cd .. && ./bin/npm --python="$PYTHON" install)
(cd .. && ./bin/node ./ext/node/lib/node_modules/npm/node_modules/node-gyp/bin/node-gyp.js --python="$PYTHON" rebuild)
# 在上面这两步的第一步有可能碰到类似exec: ./bin/../ext/node/bin/node: not found的错误，在这种情况下执行以下安装步骤，这个错误也可能导致pandoc安装出错，如果在安装完shiny server之后有关rmarkdown的应用报错，可以通过apt-get install pandoc安装，之后将/usr/bin/pandoc覆盖复制到/usr/local/shiny-server/ext/pandoc/pandoc即可
sed -i '8s/.*/NODE_SHA256=7a2bb6e37615fa45926ac0ad4e5ecda4a98e2956e468dedc337117bfbae0ac68/' ../external/node/install-node.sh
sed -i 's/linux-x64.tar.xz/linux-armv7l.tar.xz/' ../external/node/install-node.sh
(cd .. && ./external/node/install-node.sh)
(cd .. && ./bin/npm --python="${PYTHON}" install --no-optional)
(cd .. && ./bin/npm --python="${PYTHON}" rebuild)

sudo make install
```

#### post-install
```bash
sudo ln -s /usr/local/shiny-server/bin/shiny-server /usr/bin/shiny-server

sudo useradd -r -m shiny

# Create log, config, and application directories
sudo mkdir -p /var/log/shiny-server
sudo mkdir -p /srv/shiny-server
sudo mkdir -p /var/lib/shiny-server
sudo chown shiny /var/log/shiny-server
sudo mkdir -p /etc/shiny-server

sudo cd shiny-server
sudo cp config/default.config /etc/shiny-server/shiny-server.conf
sudo chown shiny +x /etc/shiny-server/shiny-server.conf
# shiny-server的source中自带的shiny-server.service要根据实际情况修改，其中的ExectStart中的shiny-server路径原为/opt/shiny-server/bin/shiny-server，应修改为/usr/bin/shiny-server
sudo cp config/systemd/shiny-server.service /lib/systemd/system/shiny-server.service
sudo chown shiny +x /lib/systemd/system/shiny-server.service

sudo systemctl enable shiny-server.service
```

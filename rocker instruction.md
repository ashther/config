### 安装docker
添加国内源
```bash
$ sudo yum-config-manager \
    --add-repo \
    https://mirrors.ustc.edu.cn/docker-ce/linux/centos/docker-ce.repo
```
### 安装Docker CE
```bash
$ sudo yum makecache fast
$ sudo yum install docker-ce
```
### 启动docker引擎
```bash
$ sudo systemctl enable docker
$ sudo systemctl start docker
```
### 镜像加速
配置国内镜像加速，在`/etc/docker/daemon.json`中加入如下内容
```json
{
  "registry-mirrors": [
    "https://registry.docker-cn.com"
  ]
}
```
### 重启服务
```bash
$ sudo systemctl daemon-reload
$ sudo systemctl restart docker
$ sudo systemctl start docker 
$ sudo systemctl enable docker # 开机启动
```

### 定制R镜像
#### 基础镜像
```bash
$ sudo docker pull rocker/r-ver
```
#### Dockerfile文件
```bash
FROM rocker/tidyverse
# 将R包源文件目录复制到镜像中
COPY for_docker/pkg /pkg
# 将Rserve配置文件复制到镜像中，方便后续运行镜像中调用该配置文件
COPY for_docker/Rserv.conf /etc/Rserv.conf
RUN R -e "\ 
install.packages(c('text2vec', 'luzlogr', 'Rserve', 'tidytext', 'janeaustenr', 'SnowballC', 'tokenizers', 'jiebaR'), type = 'source', contriburl = 'file:///pkg');\
devtools::install_local(path = '/pkg/widyr-master');"
EXPOSE 6311
# 随容器启动Rserve服务
CMD R CMD Rserve.dbg --vanilla --RS-conf /etc/Rserv.conf
```
#### R包离线安装
这里要明确R包离线安装的办法，利用自定义函数
```R
getPackages <- function(packs){
  packages <- unlist(
    tools::package_dependencies(packs, available.packages(),
                                which = c("Depends", "Imports"), recursive = TRUE)
  )
  packages <- union(packs, packages)
  packages[!packages %in% unname(installed.packages()[
    !is.na(installed.packages()[, 'Priority']), 
    'Package'
    ])]
}
```
获取所需包及其依赖包，再利用`download.packages()`下载所有的源文件到本地，然后利用`tools::write_PACKAGES()`在下载的源文件目录中生成必要的文件，如果在win平台使用该函数时一定要指明`type = 'source'`参数，R包源文件以及`write_PACKAGES`产生的文件都应在自定义镜像时复制到基础镜像中去，此外，github上的R包下载到本地后要解压，同时最好在安装github的R包之前先主动安装好其需要的依赖

#### 特定版本R包的安装
Docker镜像中的R环境应与开发环境保持一致，在创建Docker镜像时应指定R包的版本，保证可重复性。在Dockerfile中使用以下示例命令安装R包
```bash
FROM rocker/r-ver
RUN apt-get update && apt-get install -y libssl-dev libcurl4-gnutls-dev libgit2-dev
RUN R -e "\
packages <- c( \
  checkpoint = '0.3.2' \
); \
install.packages('devtools', repos = 'https://mirror.lzu.edu.cn/CRAN/'); \
invisible(lapply(names(packages), function(x) { \
  devtools::install_version( \
    x, packages[x], \
    repos = 'https://mirror.lzu.edu.cn/CRAN/' \
  ) \
})) \
"
```

### 运行镜像
正常启动
```bash
# lib目录包括了各模块R脚本、Rserv_conf.R、log目录、测试db文件等
# 设置了容器内的时区，默认为UTC
$ sudo docker run --rm -e TZ=Asia/Shanghai -p 6311:6311 -v $HOME/lib:/home/rstudio/ -d r-image
```
进入容器进行交互
```bash
$ sudo docker exec -ti {CONTAINER_ID|CONTAINER_NAMES} bash
```
### 其他注意项
在启动镜像时，加载代码、日志目录和Rserve配置文件需要的脚本所在目录作为数据卷`-v /DIRECTORY_INCLUDING_SCRIPT:/home/rstudio`
同时要在Rserve配置文件所需要的脚本Rserv\_conf.R中声明：
```R
LOG_PATH <- '/DIRECTORY_INCLUDING_SCRIPT/log'
WORK_PATH <- '/DIRECTORY_INCLUDING_SCRIPT'
```

### docker compose
二进制包安装
```bash
$ sudo curl -L https://github.com/docker/compose/releases/download/{VERSION}/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
$ sudo chmod +x /usr/local/bin/docker-compose
$ docker-compose --version
```
为了运行服务需要编写`docker-compose.yaml`，该文件应与docker项目处于同一目录下，便于文件内使用相对路径
```yaml
# 启动plumber容器，并利用HaProxy做负载均衡的例子
version: '3'
services:

  utqe-plumber:
    image: api_utqe:plumber
    environment: 
      - TZ=Asia/Shanghai
    volumes:
      - ./utqe-plumber/plumber:/home/rstudio
    expose: 
      - "8002"
    restart: always
      
  lb:
    image: dockercloud/haproxy
    environment:
      - STATS_AUTH="admin:admin" # 页面统计
      - STATS_PORT=1936
    links:
      - utqe-plumber
    ports:
      - "8002:80"
      - "1936:1936"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    depends_on:
      - utqe-plumber
    restart: always
    
```
常用命令
```bash
$ docker-compose -f {PATH OF docker-compose.yaml} up -d --scale utqe-plumber=3
$ docker-compose -f {PATH OF docker-compose.yaml} ps # 查看
$ docker-compose -f {PATH OF docker-compose.yaml} down
```
docker compose随docker开机启动时启动，无需单独设置，但应注意在`docker-compose.yaml`的服务中注明`restart: always`

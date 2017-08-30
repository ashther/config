### 安装docker
使用阿里云的安装脚本
```bash
curl -sSL http://acs-public-mirror.oss-cn-hangzhou.aliyuncs.com/docker-engine/internet | sh -
```
使用阿里云加速镜像的下载速度，可以通过修改`/etc/docker/daemon.json`：
```bash
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://{SOME_PERSONAL_STRING}.mirror.aliyuncs.com"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
```

### 启动docker引擎
```bash
sudo systemctl enable docker
sudo systemctl start docker
```

### 定制R镜像
#### 基础镜像
```bash
sudo docker pull rocker/tidyverse
```
#### Dockerfile文件
```bash
FROM rocker/tidyverse
# 将R包源文件目录复制到镜像中
COPY for_docker/pkg /pkg
# 将Rserve配置文件复制到镜像中，方便后续运行镜像中调用该配置文件
COPY for_docker/Rserv.conf /etc/Rserv.conf
RUN R -e "\ 
install.packages(c('text2vec', 'luzlogr', 'Rserve', 'tidytext', 'janeaustenr', 'SnowballC', 'tokenizers', 'jiebaR'), type = 'source', contriburl = 'file:///home/rstudio/pkg');\
devtools::install_local(path = '/home/rstudio/pkg/widyr-master');"
EXPOSE 6311
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

### 运行镜像
正常启动
```bash
# lib目录包括了各模块R脚本、Rserv_conf.R、log目录、测试db文件等
sudo docker run --rm -p 6311:6311 -v /home/ashther/lib:/home/rstudio/ -d r-image
```
进入容器进行交互
```bash
sudo docker exec -ti {CONTAINER_ID} bash
```
### 其他注意项
在启动镜像时，加载代码、日志目录和Rserve配置文件需要的脚本所在目录作为数据卷
```bash
-v /DIRECTORY_INCLUDING_SCRIPT:/home/rstudio
```
同时要在Rserve配置文件所需要的脚本Rserv\_conf.R中声明：
```bash
LOG_PATH <- '/DIRECTORY_INCLUDING_SCRIPT/log'
WORK_PATH <- '/DIRECTORY_INCLUDING_SCRIPT'
```

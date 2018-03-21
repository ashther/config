以下说明安装keras以及远程开发所需IDE的配置细节

### 安装Anaconda
使用anaconda提供的conda环境来进行后续的tensorflow以及keras的安装。进入anaconda官网[下载页面](https://www.anaconda.com/download/)选择合适的版本下载。运行下载得到的Anaconda2-\*.\*.0-Linux-x86_64.sh即可，但是由于conda更新源的连接较慢，所以有必要先增加conda的国内镜像再安装。
```bash
conda config --add channels 'https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/'
conda config --set show_channel_urls yes
```

### 安装tensorflow和keras
创建conda环境
```bash
conda create -n tensorflow python=3.6
source activate tensorflow # 退出为source deactivate
pip install --ignore-installed --upgrade # pip也存在更新源连接慢的问题，安装时加上参数--index https://pypi.tuna.tsinghua.edu.cn/simple
pip install --ignore-installed --upgrade https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-1.6.0-cp36-cp36m-linux_x86_64.whl #注意这里要选择跟该conda环境对应python版本的tensorflow
pip install keras
```
tensorflow1.6版本可能存在bug，导致在环境内报`Illegal instruction (core dumped)`错误，安装1.5版本可以解决这个问题`pip install tensorflow==1.5`

### 配置jupyter notebook
使用jupyter notebook作为远程开发调试的IDE
```bash
jupyter notebook --generate-config #会提示在~/.jupyter/下生成配置文件
jupyter notebook password #在~/.jupyter/下生成密码文件
```
在配置文件内做以下修改
```python
c.NotebookApp.ip = '*'
c.NotebookApp.password = u'密码文件中的sha...'
c.NotebookApp.open_browser = False
c.NotebookApp.port = 8888 #指定端口
```
安装`nb_conda`包`conda install nb_conda`可以让jupyter在不同kernel中切换
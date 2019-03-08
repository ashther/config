# R docker镜像
选用CentOS7为基础镜像，这是为了在后续安装thrift和rhbase中减少麻烦。

### Dockerfile
```bash
FROM centos
ENV R_VERSION=3.5.2
RUN yum install -y  epel-release \
  && yum update -y \
  && yum install -y java-1.7.0-openjdk perl make gcc-gfortran zlib-devel pcre-devel libcurl-devel readline-devel libXt-devel gcc-c++ glibc-headers bzip2-devel liblzma xz-devel \
  && curl -O https://mirror.lzu.edu.cn/CRAN/src/base/R-3/R-${R_VERSION}.tar.gz \
  && tar -xf R-${R_VERSION}.tar.gz \
  && cd R-${R_VERSION} \
  && ./configure --enable-R-shlib --enable-memory-profiling --with-readline --with-blas --with-tcltk --disable-nls --with-recommended-packages \
  && make \
  && make install \
  && yum clean all
CMD ["R"]
```
```bash
docker build -t r-env-slim .
```

# rhbase docer镜像
### Dockerfile
```bash
FROM r-env-slim
WORKDIR /usr/src/app
ENV TZ=Asia/Shanghai
RUN yum install -y  epel-release \
  && yum update -y \
  && yum install -y libgit2-devel openssl-devel thrift thrift-devel \
  && sed -i 's/^includedir.*include$/&\/thrift/g' /usr/lib64/pkgconfig/thrift.pc \
  && curl -O https://raw.githubusercontent.com/RevolutionAnalytics/rhbase/master/build/rhbase_1.2.1.tar.gz \
  && R CMD INSTALL rhbase_1.2.1.tar.gz \
  && yum clean all
CMD ["R"]
```

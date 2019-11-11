在centos上碰到由于libc等文件导致的Segmentation fault问题时：
```sh
ldconfig -l -v /lib64/libc-2.17.so
LD_PRELOAD=/usr/lib64/libc-2.17.so ln -sf /lib64/libc-2.17.so /lib64/libc.so.6
```

或者在使用yum安装时不更新glibc文件
```sh
yum install [PACKAGENAME] --exclude=glibc*
```

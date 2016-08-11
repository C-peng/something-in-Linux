caffe的简单跑动

1.使用git下载caffe

git clone https://github.com/xxx/test.git ##以https方式克隆到本地，可以读写


2.进入caffe-master文件夹

    cp Makefile.config.example Makefile.config

   生成一个配置文件Makefile.config，根据自己配置的环境更改配置文件

   然后进行编译 

             make all -j64

   然后进行测试判断编译是否成功

			make test  -j64

            make runtest -j64

3.如果没有错误则caffe已经安装成功

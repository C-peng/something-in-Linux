1.安装ubuntu14.04
==
（没有图片了，凭着自己的记忆写的）

（1）刻录系统到U盘

（2）启动机器按F12从U盘启动

（3）选择安装Ubuntu，勾选安装第三方软件库，选择安装位置的时候选择something else进行分区

（4）先选择‘-’将分区清空，然后给200M给boot以ext4格式，给1000M给swap，其余的全给主目录，然后一直继续下去，至于为什么这样分区经验而已

（5）装好后选择重启，什么时候拔U盘是一个问题 ，一直被人说我拔的不是时候，有点后遗症了，等电脑黑了再拔吧

2.配置Ubuntu14.04
==

（1）配置root密码
--
    sudo passwd root   
    [sudo] password for you:		---> 输入你的密码，不回显   
    Enter new UNIX password: 		---> 设置root 密码  
    Retype new UNIX password: 		---> 重复  


（2）网络和IP配置
--

修改配置文件sudo vi /etc/network/interfaces

root@ubuntu:~# sudo vi /etc/network/interfaces
    
    auto eth0  	#设置自动启动eth0接口
    
    iface eth0 inet static 	#配置静态IP
    
    address 172.16.18.78   	#IP地址
    
    netmask 255.255.255.0 		#子网掩码
    
    gateway 172.16.18.1	#默认网关


（3）修改DNS
--

sudo vi /etc/resolvconf/resolv.conf.d/base

    nameserver 8.8.8.8   

dns配置可以使用google的dns 8.8.8.8或者重庆电信的dns地址61.128.128.68

重启网络，使配置生效

    sudo /etc/init.d/networking restart

个人在配置后一直不成功，重启后就可以了，很诡异。。。

可以通过ping baidu.com判断网络是否连通

3.安装ssh和vnc远程桌面
==

（1）安装ssh服务
--

sudo apt-get install openssh-server会出现无法找到安装包的错误，解决办法是

     sudo apt-get update 

     sudo apt-get upgrade

假如要重新启动的话使用sudo service ssh start

（2）vnc的安装和配置
--


	apt-get install vnc4server          -->安装vncserver 
    vncserver –geometry 1920x1080 :2     	-->启动vnc服务器端
第一次启动vncserver需要输入密码并验证，上面启动vncserver后面加的参数-geometry是设置远程连接时候分辨率大小（根据你本机显示器分辨率而定）。在Ubuntu 14.04版本下，由于此版本的Ubuntu和vnc软件的兼容性不够好，使用vnc远程连接时会出现显示问题。通过以下几步来解决。

1）安装gnome

     sudo apt-get install gnome-panel gnome-settings-daemon metacity nautilus gnome-terminal

2）修改vncserver对各个用户的默认配置~/.vnc/xstartup如下：


    #!/bin/sh
    
    # Uncomment the following two lines for normal desktop: 
    #unset SESSION_MANAGER
    #exec /etc/X11/xinit/xinitrc
    
    gnome-session --session=gnome-classic &
    [ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup
     [ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
    xsetroot -solid grey
    vncconfig -iconic &
    x-terminal-emulator -geometry 80x24+10+10 -ls -title "$VNCDESKTOP Desktop" &
    #x-window-manager &					-->在配置文件中注释掉这一行。
    
    gnome-session &						
    gnome-panel &
    gnome-settings-daemon &
    metacity &
    nautilus -n &

我建议改完后重启



# 4.安装NVIDIA显卡驱动 #

## （1）前期工作  ##

需要弄清楚电脑是什么型号的显卡，进入[http://www.nvidia.cn/Download/index.aspx?lang=cn](http://www.nvidia.cn/Download/index.aspx?lang=cn)下载对应的显卡驱动文件，也就是.sh文件。

## （2）进行安装 ##

1）终端编辑需要屏蔽第三方显卡的文件：

 	sudo gedit/etc/modprobe.d/blacklist.conf

2）在blacklist.conf中添加如下内容：（注意大小写）

    blacklist vga16fb
    blacklist nouveau
    blacklist rivafb
    blacklist nvidiafb
    blacklist rivatv
    
3）接下来删除自带的nvidia驱动

    sudo apt-get --purge remove nvidia-*
    sudo apt-get –-purge remove xserver-xorg-video-nouveau

4）重启电脑，使用Ctrl+Alt+F1快捷键进入字符终端

    sudo service lightdm stop
    sh NVIDIA-Linux-x86_64-352.21.run

安装完后记得重启。

NVIDIA显卡驱动安装过程参考网址： [http://wenku.baidu.com/view/9635c296daef5ef7ba0d3cce.htm](http://wenku.baidu.com/view/9635c296daef5ef7ba0d3cce.htm)


5）是否安装成功

    nvidia-smi  显示显卡情况


# 5.安装cuda 7.5 #


## （1）前期工作  ##
进入[https://developer.nvidia.com/cuda-downloads](https://developer.nvidia.com/cuda-downloads)下载相应的cuda

## （2）进行安装 ##

1）安装必要的库（我也不知道那些库是干什么的，是参照前辈弄的）


    sudo apt-get install freeglut3-dev build-essential libx11-dev libxmu-dev libxi-dev  libglu1-mesa libglu1-mesa-dev

2）使用Ctrl + Alt +F1 进入 TTY1 控制台，先关闭X-window服务lightdm ，然后再安装cuda

    sudo service lightdm stop  
    sudo sh cuda_5.5.xx_linux_32_rhel5.x.run  
    Do you accept the previously read EULA? (accept/decline/quit):accept  
    Install NVIDIA Accelerated Graphics Driver for Linux-x86_64 319.37? ((y)es/(n)o/(q)uit):no  					-->这里选的是no，剩下来的选项都选择yes

3）安装完后需要配置环境变量，打开bashrc进行编辑

    sudo vi /etc/bash.bashrc 			-->在文件的最后加上下面两行：
    export PATH=/usr/local/cuda-7.5/bin:$PATH  
    export LD_LIBRARY_PATH=/usr/local/cuda-7.5/lib64:$LD_LIBRARY_PATH 
    保存退出，并执行：
    source /etc/bash.bashrc

4）验证cuda7.5是否正确安装


编译cuda sample，整个过程大概5分钟左右，没提示错误的话请耐心等待。

    cd /usr/local/cuda-7.5/samples
    sudo make -j128


全部编译完成后， 进入 samples/bin/x86_64/linux/release, sudo下运行deviceQuery

 	sudo ./deviceQuery


如果出现显卡信息，则显卡驱动及cuda7.5都安装成功。

	nvcc –V							-->查看cuda版本

# 6.安装opencv2.4.11 #

##（1）安装依赖包 ##

sudo apt-get install build-essential libgtk2.0-dev libjpeg-dev libtiff5-dev libjasper-dev libopenexr-dev cmake python-dev python-numpy python-tk libtbb-dev libeigen2-dev yasm libfaac-dev libopencore-amrnb-dev libopencore-amrwb-dev libtheora-dev libvorbis-dev libxvidcore-dev libx264-dev libqt4-dev libqt4-opengl-dev sphinx-common texlive-latex-extra libv4l-dev libdc1394-22-dev libavcodec-dev libavformat-dev

##（2）安装opencv ##

    unzip opencv2.4.9.zip 
    cd  opencv2.4.9 
    cmake  -D CUDA_ARCH_BIN="3.5"  CMakeLists.txt  
    make –j128 
    sudo make install

在编译的时候可能会报错如下：

    /usr/bin/ld: error: cannot find -lcufft
    /usr/bin/ld: error: cannot find -lnpps
    /usr/bin/ld: error: cannot find -lnppi
    /usr/bin/ld: error: cannot find -lnppc

这是缺少符号链接造成的，解决方法如下：make a symbolic link to libcuda where ld is searching it

    sudo ln -s /usr/local/cuda/lib64/libnpps.so /usr/lib/libnpps.so    
    sudo ln -s /usr/local/cuda/lib64/libnppi.so /usr/lib/libnppi.so    
    sudo ln -s /usr/local/cuda/lib64/libnppc.so /usr/lib/libnppc.so    
    sudo ln -s /usr/local/cuda/lib64/libcufft.so /usr/lib/libcufft.so  
    sudo ln -s /usr/local/cuda/lib64/libcudart.so /usr/lib/libcudart.so 
    sudo ldconfig 

##（3）opencv配置 ##

    sudo vim /etc/ld.so.conf.d/opencv.conf
    /usr/local/lib 
    保存之后执行配置
    sudo ldconfig

##（4）环境变量配置 ##


    sudo vim /etc/bash.bashrc				（代码位置随意，添加到最后也行）
    PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/lib/pkgconfig
    export PKG_CONFIG_PATH
	保存（esc:wq)  之后执行
	source ~/.bashrc


##（5）测试opencv安装是否成功 ##

    cd   OpenCV-2.4.11/samples/c 
    chmod +x  * 
    build_all.sh
    ./build_all.sh
    编译结束之后执行	
     ./facedetect cascade="/usr/local/share/OpenCV/haarcascades/haarcascade_frontalface_alt.xml" --scale=1.5 lena.jpg 
   如果安装成功的话，lena脸上会有一个蓝色的圈


# 7.安装caffe #

## （1）依赖包的安装 ##

按照官网上面的安装即可[http://caffe.berkeleyvision.org/install_apt.html](http://caffe.berkeleyvision.org/install_apt.html)

## （2）编译caffe ##

    cp Makefile.config.example Makefile.config
    # Adjust Makefile.config 				-->更改配置文件路径
    make all
    make test
    make runtest


## （3）中间可能会遇到找不到libcudart.so.7.5的问题 ##

    sudo ln -s /usr/local/cuda/lib64/libcudart.so /usr/lib/libcudart.so.7.5

# 8.MATLAB安装 #

## (1)挂载MATLAB镜像 ##

    sudo mount xx.iso /mnt -o loop

## (2)安装MATLAB ##

    cd /mnt
    sudo ./install

选择“Use a File Installation Key”，并点击Next，下一步选择“Yes”，并点击Next
注册码填写12345-67890-12345-67890，并点击Next.

## (3)激活MATLAB ##


安装结束前，会要求输入License文件
选择Crack文件夹中的license_405329_R2014a.lic
将Crack/Linux文件夹中的libmwservices.so覆盖至安装目录：

	sudo cp Linux/libmwservices.so /usr/local/MATLAB/R2014a/bin/glnxa64
安装完成。

参考网站：[http://blog.csdn.net/ws_20100/article/details/48859951](http://blog.csdn.net/ws_20100/article/details/48859951)


# 9.cuda和驱动的卸载 #

## 卸载 cuda toolkit ##

cuda默认安装在/etc/local/cuda-7.0下,用下面的命令卸


    sudo /usr/local/cuda-7.0/bin/uninstall_cuda_7.0.pl

## 卸载nvidia驱动 ##

    sudo /usr/bin/nvidia-uninstall




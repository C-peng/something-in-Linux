## 1.faster-rcnn各层的计算过程 ##

参见下面的网站：

[http://blog.csdn.net/sloanqin/article/details/51545125](http://blog.csdn.net/sloanqin/article/details/51545125)

[http://blog.csdn.net/XZZPPP/article/details/51582810](http://blog.csdn.net/XZZPPP/article/details/51582810)

## 2.faster-rcnn文献的中文翻译 ##

参见下面的网站：[http://www.2cto.com/kf/201604/503750.html](http://www.2cto.com/kf/201604/503750.html)

## 3.用自己的数据集做成VOC2007格式 ##

具体过程参见：

[http://blog.csdn.net/sinat_30071459/article/details/50723212](http://blog.csdn.net/sinat_30071459/article/details/50723212)

[http://blog.csdn.net/sharon686/article/details/52056199](http://blog.csdn.net/sharon686/article/details/52056199)

具体代码参见：[https://github.com/C-peng/learning-MATLAB/tree/master/VOC%E6%95%B0%E6%8D%AE%E9%9B%86%E7%94%9F%E6%88%90](https://github.com/C-peng/learning-MATLAB/tree/master/VOC%E6%95%B0%E6%8D%AE%E9%9B%86%E7%94%9F%E6%88%90)

## 4.Faster-RCNN+ZF用自己的数据集训练模型(Matlab版本) ##

参见博客：
[http://blog.csdn.net/sinat_30071459/article/details/50546891](http://blog.csdn.net/sinat_30071459/article/details/50546891)

这篇博客写的不错，按照他的流程可以跑起来。

我是在Ubuntu下跑的会与作者有一些不一样的地方，在这里记录下。

首先在官网[https://github.com/ShaoqingRen/faster_rcnn](https://github.com/ShaoqingRen/faster_rcnn)上下载faster-rcnn，需要在它的external文件夹下添加caffe文件，具体做法我就不细说了。

再有	Run fetch_data/fetch_model_ZF.m to download an ImageNet-pre-trained ZF net.可能无法下载，建议复制里面的链接在外面下载。下载完后记得修改solve文件的第一行，它的第一行是windows下的路径。

然后是下载voc2007devkit，下载地址为：[http://pjreddie.com/projects/pascal-voc-dataset-mirror/](http://pjreddie.com/projects/pascal-voc-dataset-mirror/)，将它放入database里面，在将你的数据集换名为voc2007放在它里面。

最后运行experiments/script_faster_rcnn_VOC2007_ZF.m进行训练。
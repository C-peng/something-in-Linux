# caffe学习笔记 #

Caffe -----------Convolution Architecture For Feature Embedding (Extraction)

## 1.caffe的文件结构 ##

下载caffe后，caffe文件夹下的文件目录结构如下图：

![](http://img.blog.csdn.net/20160107090227464?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQv/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)

这里，最重要的三个文件夹就是include, tools, src。在源码解读中会对里面的文件代码一一介绍，这里给出src文件的结构：

![](http://img.blog.csdn.net/20160107090630061?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQv/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)

src中的每个.cpp文件对应include文件中的头文件。在编译完成后，会生成build文件夹。

## 2.caffe中的proto ##

Protobuf是一种可以实现内存与外存交换的协议接口。在查阅了很多资料后，给我的感觉就好像是Java里面操控数据库的接口函数一样，可以对数据库进行处理。在这里举个例子。protobuf使用前，先编写proto文件，这是描述我们需要配置参数的数据结构。这个例子里面的proto如下：
	
	// See README.txt for information and build instructions.  
	  
	package tutorial;  
	  
	option java_package = "com.example.tutorial";  
	option java_outer_classname = "AddressBookProtos";  
	  
	message Person {  
	  required string name = 1;  
	  required int32 id = 2;        // Unique ID number for this person.  
	  optional string email = 3;  
	  
	  enum PhoneType {  
	    MOBILE = 0;  
	    HOME = 1;  
	    WORK = 2;  
	  }  
	  
	  message PhoneNumber {  
	    required string number = 1;  
	    optional PhoneType type = 2 [default = HOME];  
	  }  
	  
	  repeated PhoneNumber phone = 4;  
	}  
	  
	// Our address book file is just one of these.  
	message AddressBook {  
	  repeated Person person = 1;  
	} 


message Person{...}定义了一个需要传输的参数结构体，可见包括这么几个单元：name（string类型）、id（int32类型）、email（string类型）、phone（PhoneNumber类型，嵌套在Person内的类）。前面标记为“required”是必须有值的，而“optional“则为可选项，”repeated“表示后面单元为相同类型的一组向量。

有了如上定义，我们可以用protobuf工具生成接口代码，命令如下：

    protoc --cpp_out=.  addressbook.proto

运行后生成了两个文件：addressbook.pb.cc 和addressbook.pb.h。

只需要调用addressbook.pb.h中声明的tutorial::AddressBook类、Person类中的接口（add_person(), add_phone(), set_number(), set_email()等）就能操作相应的参数。

## 3.caffe源码解析之Blob ##

caffe可以分为三层：Blob、Layer、Net。Blob是一个四维的数组，用于存储数据，包括输入数据、输出数据、权值等等；Layer层则是神经网络中具体的各层结构，主要是计算的作用，在根据配置文件初始化结构后，前向计算结果，反向更新参数，都是它要做的，而它的输入和输出都是Blob数据；Net的话，就是多个Layer组合而成的有向无环图结构，也就是具体的网络了。

	#include "caffe/common.hpp"
	#include "caffe/proto/caffe.pb.h"
	#include "caffe/syncedmem.hpp"
	#include "caffe/util/math_functions.hpp"

从blob.hpp包含的四个头文件入手，其中caffe.pb.h是google protocol buffer根据caffe.proto自动生成的，可以到src/caffe/proto/caffe.proto里看下caffe里面用到的各个数据的定义，比如BlobProto，Datum，NetParameter等。

对blob的理解还要结合caffe.proto里面BlobProto的定义：

	message BlobProto {
	   optional int32 num = 1 [default = 0];
	   optional int32 channels = 2 [default = 0];
	   optional int32 height = 3 [default = 0];
	   optional int32 width = 4 [default = 0];
	   repeated float data = 5 [packed = true];
	   repeated float diff = 6 [packed = true];
	}

数据及其导数以blobs的形式在层间流动

	（1）data，前向传播所用到的数据
	（2）diff，反向传播所用到的数据
	（3）shape，解释data和diff的shape数据

代码的注释和阅读参见[http://blog.csdn.net/junmuzi/article/details/51890036](http://blog.csdn.net/junmuzi/article/details/51890036)


由源代码中可以注意到Blob有个成员变量：vector shape_ 
其作用：

对于图像数据，shape可以定义为4维的数组(Num, Channels, Height, Width)或(n, k, h, w)，所以Blob数据维度为n*k*h*w，Blob是row-major保存的，因此在(n, k, h, w)位置的值物理位置为((n * K + k) * H + h) * W + w。其中Number是数据的batch size，对于256张图片为一个training batch的ImageNet来说n = 256;Channel是特征维度，如RGB图像k = 3

对于全连接网络，使用2D blobs (shape (N, D))，然后调用InnerProductLayer

对于参数，维度根据该层的类型和配置来确定。对于有3个输入96个输出的卷积层，Filter核 11 x 11，则blob为96 x 3 x 11 x 11. 对于全连接层，1000个输出，1024个输入，则blob为1000 x 1024.

## 4.caffe源码解析之layer ##

Caffe十分强调网络的层次性，数据输入，卷积，非线性变换（ReLU等），网络连接，损失函数计算等操作都由一个Layer来实现。layer是网络的基本单元，由此派生出各种层类。创建一个caffe模型只需要定义一个prototxt文件即可。也可以通过修改layer或增加自己layer来实现自己的模型。

层和层参数定义在src/caffe/proto/caffe.proto 文件中。编译之后产生.pb.cc 和一个pb.h的文件。在neuron_layers.hpp、data_layer.hpp、vision_layers.hpp、common_layers.hpp、loss_layers.hpp这5大类层头文件中都有调用，可以把prototxt中每层的配置参数读入到配置网络的每一层的程序中。

![](http://img.blog.csdn.net/20150812103118473?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQv/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)

layer.hpp 抽象基类介绍

layer.hpp是所有layer相关的头文件，是抽象出来的基类，其他5大类都是在它基础上继承得到。

**layer中主要有三个参数：** （1）layer_param_ 是protobuf文件中存储的layer参数; （2）blobs_ 存储layer的参数，在程序中用的；（3）param_propagate_down_   bool类型用来表示是否计算各个blob参数的diff，即传播误差。

**layer中三个主要函数：**SetUp()根据实际的参数设置进行实现，对各种类型的参数初始化；Forward()和Backward()对应前向计算和反向更新，输入统一都是bottom，输出为top，其中Backward里面propagate_down参数，用来表示该Layer是否反向传播参数。

从图中可以得到layer主要有5大类组成，下边对5大类先简单介绍一下：

（1）数据层

 Data层为数据输入层，头文件定义src/caffe/include/caffe/data_layer.hpp中，作为网络的最底层，主要实现数据输入和格式的转换。

（2）神经元层

 Neuron层为元素级别运算层，头文件定义在src/caffe/include/caffe/neuron_layers.hpp中，其派生类主要是元素级别的运算（比如Dropout运算，激活函数ReLu，Sigmoid等）

（3）特征表达层 

Vision层为图像卷积相关层，头文件定义在src/caffe/include/caffe/vision_layers.hpp 中，像convolusion、pooling、LRN都在里面，按官方文档的说法，是可以输出图像的，这个要看具体实现代码了。里面有个im2col的实现。

 （4）网络连接层

Common层为网络连接层，头文件定义在src/caffe/include/caffe/common_layer.hpp中。Caffe提供了单个层或多个层的连接，并在这个头文件中声明。包括了常用的全连接层InnerProductLayer类，

 （5）损失函数层

Loss层为损失函数层，头文件定义在src/caffe/include/caffe/loss_layers.hpp中。前面的data layer和common layer都是中间计算层，虽然会涉及到反向传播，但传播的源头来自于loss_layer，即网络的最终端。这一层因为要计算误差，所以输入都是2个blob，输出1个blob。

 
 总之，data负责输入，vision负责卷积相关的计算，neuron和common负责中间部分的数据计算，而loss是最后一部分，负责计算反向传播的误差。具体的实现都在src/caffe/layers里面。


**Layer与Blob的关系**

如图，名为conv1的Layer 的输入是名为data的bottom blob，其输出是名为conv1的top blob。

   ![](http://img.blog.csdn.net/20160407142944884)

其protobuff定义如下，一个layer有一个到多个的top和bottom，其对应于blob

	layer {  
	      name: "conv1"  
	      type: "Convolution"  
	      bottom: "data"  
	      top: "conv1"  
	     ....  
	    }


##   5.caffe的数据层及参数 ##

参见网站[http://www.cnblogs.com/denny402/p/5070928.html](http://www.cnblogs.com/denny402/p/5070928.html)


妈的，不想写了，，其余的参见

[http://caffe.berkeleyvision.org/tutorial/layers.html](http://caffe.berkeleyvision.org/tutorial/layers.html)（官网）

[http://blog.csdn.net/mduanfire/article/details/51412616](http://blog.csdn.net/mduanfire/article/details/51412616)(推荐)

[http://blog.csdn.net/column/details/caffe-source-clue.html](http://blog.csdn.net/column/details/caffe-source-clue.html)

## 6.caffe的运行接口 ##

caffe的运行提供三种接口：c++接口（命令行）、python接口和matlab接口。

caffe的c++主程序（caffe.cpp)放在根目录下的tools文件夹内, 当然还有一些其它的功能文件，如：convert_imageset.cpp, train_net.cpp, test_net.cpp等也放在这个文件夹内。经过编译后，这些文件都被编译成了可执行文件，放在了 ./build/tools/ 文件夹内。因此我们要执行caffe程序，都需要加 ./build/tools/ 前缀。

参见网站：[http://caffe.berkeleyvision.org/tutorial/interfaces.html](http://caffe.berkeleyvision.org/tutorial/interfaces.html)

## 7.caffe的Fine-tuning （调整）##

参见网站：

[http://caffe.berkeleyvision.org/gathered/examples/finetune_flickr_style.html](http://caffe.berkeleyvision.org/gathered/examples/finetune_flickr_style.html)（官网）

[http://www.cnblogs.com/dupuleng/articles/4312129.html](http://www.cnblogs.com/dupuleng/articles/4312129.html)


## 8.caffe训练自己的数据 ##

参见网站：

[http://caffe.berkeleyvision.org/gathered/examples/imagenet.html](http://caffe.berkeleyvision.org/gathered/examples/imagenet.html)
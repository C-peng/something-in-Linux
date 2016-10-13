# GOTURN的学习笔记 #

GOTURN: Generic Object Tracking Using Regression Networks

single target tracking

given a bounding box label of an object in the first frame of the video

这篇文章提出了一种基于深度学习的目标跟踪算法，有以下几个特点： 

1）快，100fps，比之前大多数采用深度学习的跟踪算法都快。 

2）基于线下训练，不需要在线的学习。 

3）测试目标可以不同于线下训练的数据集，当然，如果训练集里包含同样的类别，跟踪精度会有一定程度的提高。

这个算法需要两帧图像作为输入，使用前一帧的图像和目标检测框（扩展区域）、当前帧图像和同样区域，根据已训练好的深度神经网络，预测当前帧的目标所在位置。

缺点是对于一些遮挡和重叠的情况，会出现跟丢的情况（白色矩形框为ground truth, 红色矩形框为跟踪结果）。
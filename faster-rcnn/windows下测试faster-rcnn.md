1.将自己在linux下训练出来的 ` output/faster_rcnn_final/faster_rcnn_VOC2007_ZF `  文件下的5个文件拷贝到windows下`\test\test_faster_rcnn\model`中，可以直接覆盖，里面的mean.txt文件是需要的

2.如果有错误将别人的detection_test.prototxt文件拷过来覆盖掉自己的

3.将测试数据拷到test_faster-rcnn下，注意命名的问题

4.在vs运行ClouwWalkEpsilon.sln即可
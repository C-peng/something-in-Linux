matlab编程
==
1.在matlab里如何获得一个矩阵的行数或列数
--
比如矩阵A=[1,2,3;2,3,4]

行数为size(A,1)=2

列数size(A,2)=3
2.matlab中怎样提取矩阵里的某一个元素
--
既可以用数组名跟圆括号，行号，列号表示，又可以用一个参数表示。注意一个参数表示时，MATLAB是列优先的，千万别弄错。例如：A=[1,2,3;4,5,6;7,8,9]; 则A（2，1）=4。千万别写成A[2,1]!  如果用一维表示是：A(2)=4, 千万别写成A(4)!   不信你可以上机试试。

3.简单示例
---
```matlab
[name score x1 y1 x2 y2]= textread('F:\张达敏给我传的资料\faster-rcnn\faster_rcnn-master\cw2.txt','%d %f %f %f %f %f');
data=[score x1 y1 x2 y2];

fid = fopen('new.txt','w');

num=1;
a=name(1,1);
data_new=data(1,:);

for n=1:size(name)-1;
	
	if(a==name(n+1,1))
	    num=num+1;
		data_new=[data_new;data(n+1,:)];
    else
        fprintf(fid,'%d\n%d\n',a,num);
		for i=1:size(data_new,1)
          fprintf(fid,'%f %f %f %f %f\n',  data_new(i,2),data_new(i,3),data_new(i,4)-data_new(i,2),data_new(i,5)-data_new(i,3), data_new(i,1));
		end
		a=name(n+1,1);
		num=1;
        data_new=data(n+1,:);
	end
end

fprintf(fid,'%d\n%d\n',a,num);
for i=1:size(data_new,1)
    fprintf(fid,'%f %f %f %f %f\n',  data_new(i,2),data_new(i,3),data_new(i,4)-data_new(i,2),data_new(i,5)-data_new(i,3), data_new(i,1));
end
	 
fclose(fid);

```
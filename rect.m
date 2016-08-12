clear,clc

img = imread('493678_r.jpg');
figure(1);
imshow(img);
para = textread('1.txt');
x = double(para(:,1));
y = para(:,2);
width = para(:,3)-para(:,1);
height = para(:,4)-para(:,2);
for ii = 1:length(para)
    if width >0
        rectangle('Position',[para(ii,1),para(ii,2),width(ii),height(ii)],'EdgeColor','r');
    else
        width = abs(width);
        
        rectangle('Position',[para(ii,3),para(ii,2),width(ii),height(ii)],'EdgeColor','b');
   end
   
end
close all;


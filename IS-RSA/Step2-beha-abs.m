%% edited by lixiang
%%用于一个txt或者excel文件，将行为数据求abs的矩阵，取得左下角,之后拉成一列，之后保存在txt文档中；
clear;
filename = 'SAS.txt'; 
rawDatax = readtable(filename);   
x=table2array(rawDatax);
[row, ~] = size(x);
YY=zeros(row,row);
for i=1:length(YY)
for j=1:length(YY)
YY(i,j)=abs(x(i,:)-x(j,:));
end
end

for ii=1:length(YY)
for jj=1:length(YY)
if ii<=jj
YY(ii,jj)=99999;
end
end
end
S=YY(find(YY<9999));
writematrix(S,"result.txt");
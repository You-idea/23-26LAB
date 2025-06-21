%% edited by lixiang
%%用于遍寻整个文件夹，将所有的脑袋数据求1-corr的矩阵，取得左下角，之后拉成一列，之后保存在txt文档中；
clear;
clc;
folder_path ='\BAI_parcel_txt';
files=dir(fullfile(folder_path, '*.txt'));
[row, ~] = size(files);
brain_values = cell(1, row);
brain_values_name = cell(1, row);

for k = 1 : row
file_path=fullfile(folder_path,files(k).name);
rawData=readtable(file_path);
rawDatay=table2array(rawData);
rawDatay(1:3, :) = [];
y=rawDatay';
R=1-corr(y,'Type', 'Pearson');
% 将矩阵拉成一行
R_1=tril(R);
for i=1:length(R_1)
for j=1:length(R_1)
if i<=j
R_1(i,j)=99999;
end
end
end
R_2=R_1(find(R_1<2));

rawname = {files(k).name};
[~, name, ~] = fileparts(rawname);
R_3 = [name;num2cell(R_2)];
brain_values{k} = R_2;
brain_values_name{k} = R_3;
end

all_data_name = horzcat(brain_values_name{:});
data_names = {files.name}; 
all_data = horzcat(brain_values{:});

save('brain_list.mat',"data_names");
save('all_brain.mat', 'all_data');


output_file = '\all_brain.txt';
fid = fopen(output_file, 'wt');
[row, col] = size(all_data_name);
for a = 1:col
    fprintf(fid, '%s', data_names{1, a});
end
fprintf(fid, '\n'); 
for b = 1:row-1
    for i = 1:col
        fprintf(fid, ' %f', all_data(b, i)); 
    end
    fprintf(fid, '\n'); 
end

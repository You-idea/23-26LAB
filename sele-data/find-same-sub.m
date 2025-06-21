%% edited by lixiang
%%用于对比有问卷的被试编号和服务器中有Reho的被试编号；
%%可以输出两者均有的，或者有问卷但是没有Reho的，以便于数据删除；
clear;
clc;

fileID1 = fopen('BAI.txt', 'r');
C1 = textscan(fileID1, '%s', 'Delimiter', '\n');
fclose(fileID1);


strings1 = C1{1};
processed_strings1 = cell(length(strings1), 1);
for i = 1:length(strings1)
    str = strings1{i};
    processed_str1 = extractAfter(str, 'B');
    processed_strings1{i} = processed_str1;
end
processed_matrix1 = string(processed_strings1);
fileID2 = fopen('Reho-raw-list.txt', 'r');
C2 = textscan(fileID2, '%s', 'Delimiter', '\n');
fclose(fileID2);
strings2 = C2{1};
processed_strings2 = cell(length(strings2), 1);
for i = 1:length(strings2)
    str = strings2{i};
    startindex = strfind(str, '-') + 1;
    startIndex = min(startindex);
    endindex = strfind(str, '_') - 1; 
    endIndex = min(endindex);
    processed_str2 = extractBetween(str, startIndex, endIndex);
    processed_strings2{i} = processed_str2;
end

processed_matrix2 = string(processed_strings2);
unique_elements1 = setdiff(processed_matrix1, processed_matrix2);
common_str = intersect(processed_matrix1, processed_matrix2);


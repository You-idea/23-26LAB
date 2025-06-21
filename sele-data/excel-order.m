%% edited by lixiang
%%读取一个多个sheet的excel，使之数据按照指定顺序排列。
%%要保证B中对应A中的只有一个；
clc;
clear;

outPath = '\ne_item_3.mat';
filePath = '被试顺序.xlsx';
[num, txt, raw] = xlsread(filePath);
A = raw(2:end,1);
filename = "消极心理与行为_item表-补充-2.xlsx";
[status, sheets] = xlsfinfo(filename);
numSheets = length(sheets);

for k = 1:numSheets
[numeric_data, text_data, raw_data] = xlsread(filename, sheets{k});
B = raw_data(2:end,:);
secondColumn = B(:, 2);
C = cell(size(A, 1), size(B, 2));
D = {};

for i = 1:length(A)
    idx = strcmp(A{i}, secondColumn);
    if any(idx) 
       C(i, :) = B(idx, :); 
    else
       [C{i, :}] = deal(NaN);
    end
end
D = [raw_data(1,:);C];
raw = [raw, D];
end
save(outPath,"raw")
xlswrite('ne_item_3.xlsx', raw);
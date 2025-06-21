%% edited by lixiang
%%从78个脑区中挑选需要进一步做协变量的脑袋的数据；

clear
clc

filename = 'BDI-78脑区-19.xlsx';
A = readcell(filename);
load ("brain_list.mat")
load ("all_brain.mat")

[row, col] = size(brain_names); 
matching_indices = []; 
matching_indices_J = []; 
match_name_list = [];

for i = 1:row
    for j = 1:col
        if ismember(brain_names{i,j}, A) 
            matching_indices{end+1} = [i, j];
            matching_indices_J{end+1} = j;
        end
    end
end

matching_indices_J = cell2mat(matching_indices_J);


for k = 1:length(matching_indices_J)
    a = matching_indices_J(k);
    match_brain_data(:,k) = all_brain_data(:,a);
    match_name_list {k} =  brain_names{1,a}
end

save ('brain_data_match_78-19.mat', 'match_brain_data')
save ('brain_list_match_78-19.mat','match_name_list')
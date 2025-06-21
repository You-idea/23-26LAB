%%置换检验画图
clear;
clc;

folder_path = 'Permutation-置换检验\result_face';
files = dir(fullfile(folder_path, '*_r_per.mat'));
file_R_path = fullfile(folder_path, 'R.mat');
load(file_R_path);

conf_level = 0.99;  
z_score = norminv((1 + conf_level) / 2, 0, 1);
figure;

for i = 1:numel(files)
    file_name = files(i).name;
    file_path = fullfile(folder_path, file_name);
    
    load(file_path);
    dataRow = r_per;
    targetValue = R(i,1);
    mu = mean(dataRow);  
    sigma = std(dataRow); 
    lower_bound = mu - z_score * sigma;  
    upper_bound = mu + z_score * sigma;  

    subplot(4, 2, i);
    histogram(dataRow, 'Normalization', 'pdf'); 
    hold on;
    yl = ylim; 
    plot([targetValue targetValue], yl, 'r--', 'LineWidth', 2); 
    plot([upper_bound upper_bound], yl, 'g--', 'LineWidth', 2);

    xlabel('Value');
    ylabel('Probability Density');
    title('Distribution of Data with Target Value Marker');
    legend('Data Distribution', 'Target Value');
end
print('distribution_plot', '-djpeg', '-r300');
hold off;

%% edited by lixiang
%% 计算中介效应无协变量；
clear;
clc;

filenameX = 'ZBAI-93.xlsx'; 
filenameY = 'ZSAS-bai-93.xlsx';
X = xlsread(filenameX);
Y = xlsread(filenameY);
[~, X_name, ~] = fileparts(filenameX);
[~, Y_name, ~] = fileparts(filenameY);
folder_path ='parcel_txt';
files=dir(fullfile(folder_path, '*.txt'));
[row, ~] = size(files);

outputFile = 'mediation_results_Zraw.txt';
fileID = fopen(outputFile, 'w');

for i=1:row
    file_path=fullfile(folder_path,files(i).name);
    [~, M_name, ~] = fileparts(files(i).name);
    rawData=readtable(file_path);
    brain=table2array(rawData);
    M=brain;

mdl1 = fitlm([X],M,'linear');
mdl2 = fitlm([X M], Y, 'linear');
mdl3 = fitlm([X], Y, 'linear');

beta_XY = mdl2.Coefficients.Estimate(2);
p_beta_XY = mdl2.Coefficients.pValue(2); 
beta_XM = mdl1.Coefficients.Estimate(2); 
p_beta_XM = mdl1.Coefficients.pValue(2); 
beta_MY = mdl2.Coefficients.Estimate(3);
p_beta_MY = mdl2.Coefficients.pValue(3); 
indirect_effect = beta_XM * beta_MY; 
total_effect = indirect_effect + beta_XY;
p_XY = mdl3.Coefficients.pValue(2); 

std_beta_XY = mdl2.Coefficients.Estimate(2) * std(X) / std(Y);
std_beta_XM = mdl1.Coefficients.Estimate(2) * std(X) / std(M);
std_beta_MY = mdl2.Coefficients.Estimate(3) * std(M) / std(Y);
std_XY = mdl3.Coefficients.Estimate(2) * std(X) / std(Y);

bootfun = @(idx) fitlm(X(idx),M(idx)).Coefficients.Estimate(2) * fitlm([X(idx) M(idx)], Y(idx)).Coefficients.Estimate(3);
[ci, bootIndirect] = bootci(1000, bootfun, 1:length(X));

if ci(1) <= 0 && ci(2) >= 0
        significance = '不显著';
    else
        significance = '显著';
end

P = [p_beta_XM, p_beta_MY, p_beta_XY, p_XY]; 
N = cell(1, 4);
for j=1:4
    PP=P(j);
    if PP < 0.001
         N{j}= '***';
    elseif 0.001 <= PP && PP < 0.01
        N{j}= '**';
    elseif 0.01 <= PP && PP < 0.05
        N{j}= '*';
    elseif PP >= 0.05
        N{j}= '!';
    else
        N{j}= '';
    end
end

fprintf(fileID, 'Results for brain region %s:\n', M_name);
fprintf(fileID, 'X Y M ');
fprintf(fileID, '中介是否显著: %s \n', significance);
fprintf(fileID, '%s %s %s\n', filenameX, filenameY, M_name);
fprintf(fileID, 'a  p b  p \n');
fprintf(fileID, '%f %s %f %f %s %f \n', beta_XM, N{1} , p_beta_XM, beta_MY, N{2} , p_beta_MY);
fprintf(fileID, '%f %s %f %f %s %f \n', std_beta_XM, N{1} , p_beta_XM, std_beta_MY, N{2} , p_beta_MY);
fprintf(fileID, 'direff p  toteff p  \n');
fprintf(fileID, '%f %s %f %f %s %f \n', beta_XY, N{3} , p_beta_XY, total_effect, N{4} , p_XY);
fprintf(fileID, '95%% Bootstrap CI: [%f, %f] \n', ci(1), ci(2));
fprintf(fileID, '\n');

disp(i);

end

fclose(fileID);



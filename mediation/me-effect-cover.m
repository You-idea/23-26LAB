%% edited by lixiang
%% 计算中介效应；带协变量！
clear;
clc;

folderPaths = {'face/GPT', 'face/BDI', 'face/BAI','reho/GPT', 'reho/BDI', 'reho/BAI'}; 
for n = 1:length(folderPaths)
    folderPath = folderPaths{n};

filePath = ['me\' folderPath '\raw\beha-raw.xlsx']; 
[beha_num, beha_txt, ~] = xlsread(filePath);
beha=beha_num;
filePath = ['me\' folderPath '\raw\covar.xlsx'];
[covar_num, covar_txt, raw] = xlsread(filePath);
covar=covar_num;
[~,colcovar] = size(covar);

X=beha(:,1);
Y=beha(:,2);
filenameX=char(beha_txt{1,1});
filenameY=char(beha_txt{1,2});

folder_path=['me\' folderPath '\raw\38_86_txt'];
files = dir(fullfile(folder_path, '*.txt'));
[col_brain,~] = size(files);
brain_name = {files.name};

outputFile =['me\' folderPath '\raw\mediation_results.txt'];
fileID = fopen(outputFile, 'w');

for i=1:col_brain
    file_path=fullfile(folder_path,files(i).name);
    rawData=readtable(file_path);
    M=table2array(rawData);

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
[ci, bootIndirect] = bootci(500, bootfun, 1:length(X)); 

if ci(1) <= 0 && ci(2) >= 0
        significance = '不显著';
    else
        significance = '显著';
end

P = [p_beta_XM, p_beta_MY, p_beta_XY, p_XY]; 
N = cell(1, 4); 
for k=1:4
    PP=P(k);
    if PP < 0.001
         N{k}= '***';
    elseif 0.001 <= PP && PP < 0.01
        N{k}= '**';
    elseif 0.01 <= PP && PP < 0.05
        N{k}= '*';
    elseif PP >= 0.05
        N{k}= '!';
    else
        N{k}= '';
    end
end

fprintf(fileID, 'Results for brain region %s:\n', brain_name{i});
fprintf(fileID, 'X Y M ');
fprintf(fileID, '中介是否显著: %s \n', significance);
fprintf(fileID, '%s %s %s\n', filenameX, filenameY, brain_name{i});
fprintf(fileID, 'a  p b  p \n');
fprintf(fileID, '%f %s %f %f %s %f \n', beta_XM, N{1} , p_beta_XM, beta_MY, N{2} , p_beta_MY);
fprintf(fileID, '%f %s %f %f %s %f \n', std_beta_XM, N{1} , p_beta_XM, std_beta_MY, N{2} , p_beta_MY);
fprintf(fileID, 'indeff direff p  toteff p  \n');
fprintf(fileID, '%f %f %s %f %f %s %f \n', indirect_effect, beta_XY, N{3} , p_beta_XY, total_effect, N{4} , p_XY);
fprintf(fileID, '95%% Bootstrap CI: [%f, %f] \n', ci(1), ci(2));
fprintf(fileID, '\n');
end
fclose(fileID);

outputFile = ['me\' folderPath '\raw\covar_mediation_results.txt'];
fileID = fopen(outputFile, 'w');

for i=1:col_brain
    file_path=fullfile(folder_path,files(i).name);
    rawData=readtable(file_path);
    M=table2array(rawData);

mdl1 = fitlm([X covar],M,'linear');
mdl2 = fitlm([X covar M], Y, 'linear');
mdl3 = fitlm([X covar], Y, 'linear');

beta_XY = mdl2.Coefficients.Estimate(2); 
p_beta_XY = mdl2.Coefficients.pValue(2); 
beta_XM = mdl1.Coefficients.Estimate(2); 
p_beta_XM = mdl1.Coefficients.pValue(2); 
beta_MY = mdl2.Coefficients.Estimate(colcovar+3);
p_beta_MY = mdl2.Coefficients.pValue(colcovar+3); 
indirect_effect = beta_XM * beta_MY;
total_effect_check = indirect_effect + beta_XY;
total_effect = mdl3.Coefficients.Estimate(2); 
p_XY = mdl3.Coefficients.pValue(2); 
std_beta_XY = mdl2.Coefficients.Estimate(2) * std(X) / std(Y);
std_beta_XM = mdl1.Coefficients.Estimate(2) * std(X) / std(M); 
std_beta_MY = mdl2.Coefficients.Estimate(colcovar+3) * std(M) / std(Y);
std_XY = mdl3.Coefficients.Estimate(2) * std(X) / std(Y);

bootfun = @(idx) fitlm(X(idx),M(idx)).Coefficients.Estimate(2) * fitlm([X(idx) M(idx)], Y(idx)).Coefficients.Estimate(3);
[ci, bootIndirect] = bootci(500, bootfun, 1:length(X));

if ci(1) <= 0 && ci(2) >= 0
        significance = '不显著';
    else
        significance = '显著';
end

P = [p_beta_XM, p_beta_MY, p_beta_XY, p_XY];
N = cell(1, 4); 
for k=1:4
    PP=P(k);
    if PP < 0.001
         N{k}= '***';
    elseif 0.001 <= PP && PP < 0.01
        N{k}= '**';
    elseif 0.01 <= PP && PP < 0.05
        N{k}= '*';
    elseif PP >= 0.05
        N{k}= '!';
    else
        N{k}= '';
    end
end

fprintf(fileID, 'Results for brain region %s:\n', brain_name{i});
fprintf(fileID, 'X Y M ');
fprintf(fileID, '中介是否显著: %s \n', significance);
fprintf(fileID, '%s %s %s\n', filenameX, filenameY, brain_name{i});
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
end

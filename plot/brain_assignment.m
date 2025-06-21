%% code for mapping2brain
%% edited by gewei
%被给脑袋赋值
clc;
clear;

rsa=xlsread('reho-is-rsa-abs-72-covar.xlsx');
[row, col] = size(rsa);
atlas=load_nii('whole_brain-200.nii.gz');
atlas_img=single(atlas.img);
r2brain_risk=atlas_img;

for i=1:row
    r_risk=rsa(i,2);
    if r_risk~=0
        r2brain_risk(find(r2brain_risk==rsa_index))=r_risk;
    end
end

r2brain_risk(find(r2brain_risk>=1))=0;
atlas.img=r2brain_risk;
save_nii(atlas,'reho-is-rsa-abs-covar.nii.gz');

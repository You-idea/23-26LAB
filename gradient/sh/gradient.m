function gradient(fliepath)
data_dir =fliepath;
script_dir = '//script/';
addpath('/scripts_function'); 
addpath('/spm12');

cd([data_dir,'data']);
list = dir;
list(1:2) = [];

for i = 1:length(list)
    gunzip(list(i).name,[data_dir, 'data_nii']);
end

cd([data_dir,'data_nii']);
list = dir;
list(1:2) = [];
for i = 1:length(list)
    x_reslice([script_dir,'Reslice_group_mask.nii'],list(i).name,4);
end

sourceFolder = [data_dir,'/data_nii/'];
destinationFolder = [data_dir,'/Resliced/'];
files = dir(fullfile(sourceFolder, 'r*.nii'));

for i = 1:length(files)
    rFile = files(i);
    rFileName = rFile.name;
    expression = 'rsub-(\d+)_';
    tokens = regexp(rFileName, expression, 'tokens');
    str = tokens{1}{1};
    targetSubFolder = fullfile(destinationFolder, str);
    mkdir(targetSubFolder);
    sourceFilePath = fullfile(sourceFolder, rFileName);
    movefile(sourceFilePath, targetSubFolder);
end

cd([data_dir,'Resliced']);
list = dir;
list(1:2) = [];

for i = 1:length(list)
    tic
    cd([data_dir,'Resliced/',list(i).name]);
    filename = dir('*.nii');
    M = x_gen_matrix_voxel([script_dir,'Reslice_group_mask.nii'],filename.name);
    n = length(M);
    M_spar = M;
    tmp = sort(M);
    tmp = M - repmat(tmp(round(n*0.9),:),n,1);
    M_spar(tmp<0) = 0;
    M_spar = M_spar';
    
    M_cos = 1 - squareform(pdist(M_spar,'cosine'));
    M_normalized = 1 - acos(M_cos)/pi;
    [embedding,result] = x_compute_diffusion_map(M_normalized,0.5,30); 
    
    ind_dir = [data_dir,'Gradient_SameLength/'];
    mkdir(ind_dir);
    filename = [ind_dir,'/gradient.mat'];
    x_parsave(filename,embedding,result);
    toc
end

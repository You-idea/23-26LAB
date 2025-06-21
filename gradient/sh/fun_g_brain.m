function fun_g_brain(fliepath)
data_dir = fliepath;
output_dir = fullfile(data_dir, 'gradient_nii_gz');
script_dir = '/script/';
addpath('/scripts_function'); 
addpath('scripts_function/spm12'); 

%% arrange emb

G_dir = fullfile(data_dir, 'Gradient_SameLength');
cd (G_dir)
list = dir;
list(1:2) = [];
n_sub = length(list);

parfor i = 1:n_sub
    file_path = fullfile(data_dir, 'Gradient_SameLength', list(i).name, 'gradient.mat');
    data = load(file_path);
    emb_all{i} = data.embedding;
    res_all{i} = data.result;    
end

[realigned, xfms] = mica_iterativeAlignment(emb_all,100);
realigned = real(realigned); 
xfms = cellfun(@real,xfms,'UniformOutput',false); 

gradient_emb = cell(30,1);
parfor i = 1:30
    gradient_emb{i} = squeeze(realigned(:,i,:));
end

% calculate order sequence 
seq = zeros(n_sub,30);
for i = 1:n_sub
    tmp = abs(xfms{i});
    [~,I] = sort(tmp,'descend');
    seq_tmp = zeros(5,1);
    seq_tmp(1) = I(1);
    for j = 2:30
        for k = 1:30
            if isempty(find(seq_tmp == I(k,j), 1))
                seq_tmp(j) = I(k,j);
                break;
            end
        end
    end
    seq(i,:) = seq_tmp;
end

% calculate explaination rate
exprate = zeros(n_sub,30);
for i = 1:n_sub
    tmp = res_all{i}.lambdas./sum(res_all{i}.lambdas);
    exprate(i,:) = tmp(seq(i,:));
end


% reorder gradient according to explaination ratio 
exprate_mean = mean(exprate); 
[~,I] = sort(exprate_mean,'descend');
gradient_emb_reordered = cell(30,1);
for i = 1:30
    gradient_emb_reordered{i} = gradient_emb{I(i)}; 
end

gradient_emb_correct = cell(3,1);
for i = 1:3
    gradient_emb_correct{i} = gradient_emb_reordered{i};
end

G_dir = fullfile(data_dir, 'Gradient_SameLength');
cd (G_dir)

list = dir;
list(1:2) = [];
n_sub = length(list);
hdr_mask = spm_vol([script_dir, 'Reslice_group_mask.nii']);
vol_mask = spm_read_vols(hdr_mask);
hdr = hdr_mask;
hdr.dt(1) = 64;
ind = find(vol_mask);
for k = 1:3
    first_element = gradient_emb_correct{k}; 
    for j = 1:n_sub
        for i = 1:size(first_element, 2) 
            vol = zeros(hdr.dim);
            vol(ind) = first_element(:, i); 
	    output_path = fullfile(output_dir, list(i).name);
	    mkdir(output_path); 
            hdr.fname = fullfile(output_dir, list(i).name, ['g_', num2str(k), '.nii']);
            spm_write_vol(hdr, vol); 
            gzip(hdr.fname);
        end
    end
end

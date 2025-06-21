%% edited by lixiang
%% 批次融合
input = 'stats';
output = 'GPT_T1/';

load([output,'All_sub_info.mat']);
sub_info = E;
filename = fullfile(input,'GM_mod_merg.nii.gz');
img = niftiread(filename);
info = niftiinfo(filename);
voxel_size = info.PixelDimensions;
mask_filename = fullfile(input, 'GM_mask.nii.gz');
mask = niftiread(mask_filename);
[dim1, dim2, dim3, num_subjects] = size(img);
data_matrix = [];

for subj_idx = 1:num_subjects
    subj_img = img(:,:,:,subj_idx);
    valid_values = subj_img(mask > 0);
    data_matrix = [data_matrix; valid_values'];
end

save(fullfile(output,'GM_mod_merg_3.mat') ,'data_matrix');
disp 'nii.gz->mat succeed!'

batch = cell2mat(sub_info(2:end,2));
mod = cell2mat(sub_info(2:end,[4 5 6 7]));

data_matrix_correct = combat(data_matrix',batch',mod, 1);
save (fullfile(output,'combat_3_par.mat') ,'data_matrix_correct')
reconstructed_img = zeros(dim1, dim2, dim3, num_subjects, 'like', img);

for subj_idx = 1:num_subjects
    subj_data = data_matrix_correct(:,subj_idx);
    [mask_x, mask_y, mask_z] = ind2sub([dim1, dim2, dim3], find(mask > 0));
    for i = 1:length(mask_x)
        x = mask_x(i);
        y = mask_y(i);
        z = mask_z(i);
        reconstructed_img(x, y, z, subj_idx) = subj_data(i);
    end
end

output_filename = fullfile(output, 'reconstructed.nii');
niftiwrite(reconstructed_img, output_filename,info);
gzip(output_filename, fullfile(output));
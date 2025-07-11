#提取某个脑图中最大值的坐标
import os
import glob
import nibabel as nib
import numpy as np
from scipy.io import savemat

base_path = '/tmp_rs/rs_data'
output_path = '/rs_data/results.mat'

results = []

for sub_folder in glob.glob(os.path.join(base_path, 'sub*')):
    subnum = sub_folder.split('/')[-1][4:8]
    analysis_folder = os.path.join(sub_folder, 'analysis')
    nifti_file = os.path.join(analysis_folder, 'rest_mask_4_right.nii.gz')
    img = nib.load(nifti_file)
    data = img.get_fdata()

    max_value = np.max(data)
    max_coords_vo = np.unravel_index(np.argmax(data), data.shape)
    max_coords_co = (90 - 2 * max_coords_vo[0], -126 + 2 * max_coords_vo[1], -72 + 2 * max_coords_vo[2])
    results.append([subnum, max_value, max_coords_vo, max_coords_co])
    print(f'subnum: {subnum}')

results_array = np.array(results, dtype=object)
savemat(output_path, {'results': results_array})

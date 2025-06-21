# 在脑图中圈一个长方体出来
# 这个代码切出来的和原始脑图的大小相同

import nibabel as nib
import numpy as np

input_image_path = 'thresh_accuracy_zstat23.nii.gz'
output_mask_path = 'roi.nii.gz'

img = nib.load(input_image_path)
data = img.get_fdata()
data_shape = img.shape
affine = img.affine

# 定义正方体ROI的坐标和边长
x_start, y_start, z_start = 60, 34, 50
x_length = 8
y_length = 5
z_length = 7

masked_data = np.zeros(data_shape, dtype=data.dtype)

x_end = min(x_start + x_length, data_shape[0])
y_end = min(y_start + y_length, data_shape[1])
z_end = min(z_start + z_length, data_shape[2])

masked_data[x_start:x_end, y_start:y_end, z_start:z_end] = data[x_start:x_end, y_start:y_end, z_start:z_end]
masked_img = nib.Nifti1Image(masked_data, affine)
nib.save(masked_img, output_mask_path)

print(f"生成的掩模图像已保存到: {output_mask_path}")

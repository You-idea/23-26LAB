# 因为_13将保留所有结果的results删除了，所以增加一个读取所有结果并将所有结果保存在同一个大文件的脚本

import os
import numpy as np
import scipy.io


def load_and_concatenate_mat_files(directory_path):
    results = []

    # 获取所有 .mat 文件名并按数字排序
    file_list = [f for f in os.listdir(directory_path) if f.endswith('result_subs_r_p.mat')]
    # 列出所有 .mat 文件
    file_list.sort(key=lambda x: int(x.split('_')[0]))
    # 按文件名中的数字部分排序文件列表。
    # os.path.splitext(x)[0] 获取文件名（不包括扩展名），然后 int() 转换为整数用于排序。

    # 遍历排序后的文件名
    for filename in file_list:
        file_path = os.path.join(directory_path, filename)
        mat_data = scipy.io.loadmat(file_path).get('result_subs_r_p')
        results.append(mat_data)
    results_subs_rs_ps = np.hstack(results)
    return results_subs_rs_ps

directory_path = 'E:/personal/Documents/Python/HPS/7-8/script_9_result_4'  # 替换为实际路径
results_subs_rs_ps = load_and_concatenate_mat_files(directory_path)

# 保存拼接后的数据
output_path = os.path.join(directory_path, 'results_subs_rs_ps.mat')
scipy.io.savemat(output_path, {'results_subs_rs_ps': results_subs_rs_ps})

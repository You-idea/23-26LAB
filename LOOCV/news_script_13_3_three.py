# 因为_13将保留所有结果的results删除了，所以增加一个读取所有结果并将所有结果保存在同一个大文件的脚本
# 我感觉拼成426*4000可能时间会有点久，所以改善一下：分块处理
# 还有其他方式：使用内存映射文件（memory-mapped files）、多核 CPU的Python 的 multiprocessing、将文件存为scv格式或者 HDF5 文件
# 在_two的基础上进行优化 ，增加了求平均数的部分

# 记得检查输入和输出的地址，以及组块数量

import os
import re
import numpy as np
import scipy.io

def load_and_concatenate_mat_files(directory_path, chunk_size = 100):
    results_r_p = []
    results_r_mean = []
    # 获取所有 .mat 文件名并按数字排序
    file_list = [f for f in os.listdir(directory_path) if f.endswith('result_subs_r_p.mat')]
    # 列出所有 .mat 文件
    file_list.sort(key=lambda x: int(x.split('_')[0]))
    # 按文件名中的数字部分排序文件列表。
    # os.path.splitext(x)[0] 获取文件名（不包括扩展名），然后 int() 转换为整数用于排序。
    total_files = len(file_list)

    # 处理分块数据
    for i in range(0, total_files, chunk_size):
        chunk_files = file_list[i:i + chunk_size]
        chunk_r_p = []
        rs_chunk_mean = []
        print(f'当前组块为：< {i + chunk_size}/{len(file_list)}')

        for filename in chunk_files:
            file_path = os.path.join(directory_path, filename)
            file_number = int(re.search(r'(\d+)', filename).group())
            mat_r_p = scipy.io.loadmat(file_path).get('result_subs_r_p')
            # r_mean = np.mean(mat_r_p[:, 2])
            r_mean = np.mean(np.abs(mat_r_p[:, 2]))
            # rs_chunk_mean.append({'file_number': file_number, 'r_mean': r_mean}) # 会放在一个格里
            rs_chunk_mean.append([file_number,r_mean]) # 是chunk个

            chunk_r_p.append(mat_r_p)
            chunk_result_r_p = np.hstack(chunk_r_p)

            chunk_result_r_mean = np.array(rs_chunk_mean)

        results_r_p.append(chunk_result_r_p)
        results_r_mean.append(chunk_result_r_mean)
    results_subs_rs_ps = np.hstack(results_r_p)
    results_subs_rs_mean = np.vstack(results_r_mean)
    return results_subs_rs_ps, results_subs_rs_mean


directory_path = 'E:/personal/Documents/Python/HPS/7-8/script_13_result/result_tota'  # 替换为实际路径
# directory_path = '/home/tjnu_fmri/wangqiang/lixiang/tmp_HPS/python_13_2_mood/result_tota'  # 替换为实际路径
output_path = 'E:/personal/Documents/Python/HPS/7-8/script_13_result/P_1000_abs_mean_results'
# output_path = '/home/tjnu_fmri/wangqiang/lixiang/tmp_HPS/python_13_2_mood/result_tota/P_1000_results'
results_subs_rs_ps, results_subs_rs_mean = load_and_concatenate_mat_files(directory_path)

# 保存拼接后的数据
output_path_1 = os.path.join(output_path, 'results_subs_rs_ps.mat')
output_path_2 = os.path.join(output_path, 'results_subs_abs_rs_mean.mat') # 注意修改！
scipy.io.savemat(output_path_1, {'results_subs_rs_ps': results_subs_rs_ps})
scipy.io.savemat(output_path_2, {'results_subs_rs_mean': results_subs_rs_mean})

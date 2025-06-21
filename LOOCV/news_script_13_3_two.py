# 因为_13将保留所有结果的results删除了，所以增加一个读取所有结果并将所有结果保存在同一个大文件的脚本
# 我感觉拼成426*4000可能时间会有点久，所以改善一下：分块处理
# 还有其他方式：使用内存映射文件（memory-mapped files）、多核 CPU的Python 的 multiprocessing、将文件存为scv格式或者 HDF5 文件

# 本脚本还没有试过，因为我没有那么多的文件，我试运行得到的文件只有5个

import os
import numpy as np
import scipy.io


def load_and_concatenate_mat_files(directory_path, chunk_size=100):
    results = []

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
        chunk_data = []
        print(f'当前组块为：< {i + chunk_size}/{len(file_list)}')

        for filename in chunk_files:
            file_path = os.path.join(directory_path, filename)
            mat_data = scipy.io.loadmat(file_path).get('result_subs_r_p')
            chunk_data.append(mat_data)
            chunk_result = np.hstack(chunk_data)
            results.append(chunk_result)
        results_subs_rs_ps = np.hstack(results)
        return results_subs_rs_ps

directory_path = 'E:/personal/Documents/Python/HPS/7-8/script_9_result_4'  # 替换为实际路径
results_subs_rs_ps = load_and_concatenate_mat_files(directory_path)

# 保存拼接后的数据
output_path = os.path.join(directory_path, 'results_subs_rs_ps.mat')
scipy.io.savemat(output_path, {'results_subs_rs_ps': results_subs_rs_ps})

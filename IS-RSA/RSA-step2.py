###表征相似性的代码
###2024.12.18

import os
import numpy as np
import pandas as pd
from scipy.stats import pearsonr
import scipy.io as sio

main_folder = 'txt/txt_2/'
outdatapath = '12-29_mask_2/'

beha_data = sio.loadmat(os.path.join(outdatapath, 'beha_data_py.mat'))
beha_data = beha_data.get('beha_data', None)
beha_data = beha_data.flatten()
# print(beha_data.shape)

sub_folders = [f for f in os.listdir(main_folder) if os.path.isdir(os.path.join(main_folder, f))]

def calculate_correlation(y):
    R = 1 - np.corrcoef(y)
    R_1 = np.tril(R)
    R_1[np.triu_indices_from(R_1, 0)] = 99999
    R_1 = R_1.T
    return R_1[R_1 < 2]

for sub_folder in sub_folders:
    folder_path = os.path.join(main_folder, sub_folder)
    files = [f for f in os.listdir(folder_path) if f.endswith('.txt')]
    # print(sub_folder)
    # print(len(files))

    all_brain_data = np.empty((284635, 0))
    brain_values_name = []
    sub_name_r = []

    for file_name in files:
        # print(file_name)
        file_path = os.path.join(folder_path, file_name)
        if os.path.exists(file_path) and os.path.getsize(file_path) > 0:
            try:
                raw_data = pd.read_table(file_path, header=None, sep=r'\s+')
                raw_data = raw_data.iloc[3:, :]
            except Exception as e:
                print(f"读取文件 {file_name} 时发生错误: {e}")
        else:
            print(f"文件 {file_name} 为空，已跳过。")
        if raw_data.shape[1] <= 30:
            print(f"Skipping {file_name} as it has {raw_data.shape[1]} columns.")
            continue
        R_2 = calculate_correlation(raw_data.values)  # 计算相关性
        sub_name_r.append(file_name)

        R_2 = np.array(R_2).reshape(-1, 1)
        print(R_2.shape)
        all_brain_data = np.hstack((all_brain_data, R_2))
        print(sub_folder,file_name)

    sub_name_r_list = ([[''.join(row)] for row in sub_name_r])
    rows = len(sub_name_r_list)
    columns = len(sub_name_r_list[0]) if sub_name_r_list else 0
    print("行数:", rows)
    print("列数:", columns)
    sub_name_r_combined = np.array([''.join(row).strip() for row in sub_name_r])
    sub_name_r = sub_name_r_combined.reshape(-1, 1)
    print(sub_name_r.shape)
    sio.savemat(os.path.join(outdatapath, f'{sub_folder}_brain_list.mat'), {'brain_list': files})
    sio.savemat(os.path.join(outdatapath, f'{sub_folder}_all_brain_data.mat'), {'all_brain_data': all_brain_data})

    r_values = []
    p_values = []
    if beha_data is not None:
        print(all_brain_data.shape)
        for i in range(all_brain_data.shape[1]):
            r, p = pearsonr(beha_data, all_brain_data[:, i])  # 对每一列计算相关系数
            r_values.append(r)
            p_values.append(p)
        r_values = np.array(r_values).reshape(-1, 1)
        p_values = np.array(p_values).reshape(-1, 1) 
        rsps = np.hstack([r_values, p_values])
        sio.savemat(os.path.join(outdatapath, f'{sub_folder}_rs.mat'), {'r_values': r_values})
        sio.savemat(os.path.join(outdatapath, f'{sub_folder}_ps.mat'), {'p_values': p_values})
        sio.savemat(os.path.join(outdatapath, f'{sub_folder}_rsps.mat'), {'rsps': rsps})
        txt_file_path = os.path.join(outdatapath, f'{sub_folder}_subname.txt')
        with open(txt_file_path, 'w') as f:
            for row in sub_name_r:
                f.write(' '.join(row) + '\n')
        txt_file_path_list = os.path.join(outdatapath, f'{sub_folder}_subname_list.txt')
        with open(txt_file_path_list, 'w') as f:
            for row in sub_name_r_list:
                f.write(' '.join(row) + '\n')

    else:
        print(f"Warning: 'beha_data' not found in GPT.mat for {sub_folder}, skipping RSA calculation.")

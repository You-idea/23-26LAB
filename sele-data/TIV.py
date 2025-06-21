# 提取fresurfer中的TIV
import os
import re

def read_aseg_stats_and_save(input_dir, output_file):
    for root, dirs, files in os.walk(input_dir):
        if 'aseg.stats' in files:
            aseg_stats_path = os.path.join(root, 'aseg.stats')
            match = re.search(r'sub-\d+', aseg_stats_path)
            try:
                with open(aseg_stats_path, 'r') as f:
                    lines = f.readlines()
                matching_lines = [line for line in lines if "Estimated Total Intracranial Volume" in line]
                if matching_lines:
                    with open(output_file, 'a') as out_file:
                        out_file.write(f"Path: {match.group()}")
                        for line in matching_lines:
                            out_file.write(f"{line}")

                    print(f"Processed: {aseg_stats_path}")
            except Exception as e:
                print(f"Error reading {aseg_stats_path}: {e}")





# 输入目录（需要根据你的实际情况更改路径）
# input_directory = 'H:/freesurfer' #例子
input_directory = 'G:/freesurfer_lx_tmp/freesurfer_ZGD_2'

# 输出的txt文件路径
# output_txt_file = 'H:/freesurfer/TIV.txt' #例子
output_txt_file = 'G:/freesurfer_lx_tmp/TIV_freesurfer_ZGD_2.txt'

# 调用函数进行处理
read_aseg_stats_and_save(input_directory, output_txt_file)
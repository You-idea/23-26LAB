#用来将静息态的结果分成Alff,Bold和reho的
import os
import shutil

base_path = r"\ex_2" #25.04.11
entries = os.listdir(base_path)
print(entries[0])
entries = [entries[0]]
for dir_name in entries:
    print(dir_name)
    file_path = os.path.join(base_path, dir_name)
    source_folder = os.path.join(base_path, dir_name, 'xcpd', )#25.04.11
    file_names = [file for file in os.listdir(source_folder)
                  if file.startswith('sub-') and os.path.isdir(os.path.join(source_folder, file))]
    print(file_names)

    for sub_name in file_names:
        sub_path = os.path.join(source_folder, sub_name, 'func')
        # print(sub_path)
        sub_files = [file for file in os.listdir(sub_path) if file.endswith('.nii.gz')]
        # print(sub_files)
        for file_name in sub_files:
            parts = file_name.split('_')
            runnum = parts[2]
            A = parts[-1].split('.')[0]
            B = '_'.join(parts[3:-1])

            if A in ['reho', 'alff', 'bold']:
                if "smooth" in B.lower():
                    target_folder = os.path.join(file_path, A,'smooth', runnum)
                else:
                    target_folder = os.path.join(file_path, A,'no_smooth', runnum)

                if not os.path.exists(target_folder):
                    os.makedirs(target_folder)
                source_file = os.path.join(sub_path, file_name)
                target_file = os.path.join(target_folder, file_name)
                shutil.copy(source_file, target_file)
                print(f"文件 {file_name} 已成功复制")
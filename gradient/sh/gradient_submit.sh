#!/bin/bash

ID=\$1
cd /gradient_NS_Bold_SUB13/data || exit

find $(pwd) -mindepth 2 -maxdepth 2 -type d -printf "%p/\n" > pathlist.txt

#find . -type d -name "smooth" -o -name "nosmooth" -path ".//gradient_NS_Bold_*" > g_brain/pathlist.txt
# find "$(pwd)" -mindepth 1 -maxdepth 2 -type d \( -name "data" -o -name "nosmooth" \) > g_brain/pathlist.txt

while IFS= read -r fliepath; do
    # 构造正确的路径
    echo ""
    echo "Running $fliepath"
    echo ""
    if [ -d "$fliepath" ]; then
        # echo "Hi"
        sbatch gradient.sh "$fliepath"
    else
        echo "Directory $fliepath does not exist."
    fi
done < pathlist.txt


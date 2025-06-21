#!/bin/bash
#ID=$1
#cd /gradient_NS_Bold/ || exit
#find . -type d \( -name "smooth" -o -name "nosmooth" \) -path "./gradient_NS_Bold_*" > g_brain/pathlist.txt

#cd g_brain || exit

#for fliepath in `cat pathlist.txt` 
#do
#echo ""
#echo "Running $fliepath"
#echo ""
#sbatch fun_g_brain.sh ${fliepath}
#done


ID=\$1
cd gradient_NS_Bold/ || exit

# find . -type d -name "smooth" -o -name "nosmooth" -path ".//gradient_NS_Bold_*" > g_brain/pathlist.txt

# find "$(pwd)" -mindepth 1 -maxdepth 2 -type d \( -name "smooth" -o -name "nosmooth" \) > g_brain/pathlist.txt

cd g_brain || exit
while IFS= read -r fliepath; do
    target_dir="${fliepath}/Gradient_SameLength"
    echo ""
    echo "Running $target_dir"
    echo ""
    if [ -d "$target_dir" ]; then
        sbatch fun_g_brain.sh "$fliepath"
    else
        echo "Directory $target_dir does not exist."
    fi
done < pathlist_01_smooth.txt

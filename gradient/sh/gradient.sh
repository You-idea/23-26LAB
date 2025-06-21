#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=20G
#SBATCH -p q_fat_c
#SBATCH --qos=high_c
#SBATCH -o /report/job.%j.out
#SBATCH -e /report/job.%j.error.txt
module load singularity/3.7.0
module load MATLAB/R2022a
fliepath=$1
matlab -batch "gradient_beinao('$fliepath')"


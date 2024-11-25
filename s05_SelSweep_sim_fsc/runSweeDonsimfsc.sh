#!/bin/bash
#SBATCH --mem=50G
#SBATCH --cpus-per-task=10
#SBATCH --time=2-00:00:00
#SBATCH --nodes=1
#SBATCH --array=1
#SBATCH -A almond_dw_snp
#SBATCH --partition=long

config=list_populations.txt
# Extract the sample name for the current $SLURM_ARRAY_TASK_ID
motif=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $2}' $config)

mkdir ../results/$motif
cd ../results/$motif

path=/shared/projects/almond_dw_snp


module load vcftools

export PATH=$path/tools/sweed:$PATH

for i in $(seq 147 500)
do

    filepath=$path/4_FastSimCoal/results/fastsimcoal2/simulations_2/$motif/vcf/test_1_${i}.vcf.gz

    vcftools --gzvcf $filepath \
        --recode --recode-INFO-all \
        --out test_1_${i}


    SweeD-P \
        -name ${motif}.${i}.1k \
        -input test_1_${i}.recode.vcf \
        -length 25000000 \
        -grid 25000 \
        -threads 10 

    rm test_1_${i}.recode.vcf

done


#!/bin/bash
#SBATCH --mem=50G
#SBATCH --cpus-per-task=10
#SBATCH --time=1-00:00:00
#SBATCH --nodes=1
#SBATCH --array=1-7
#SBATCH -A almond_dw_snp

config=list_populations.txt
# Extract the sample name for the current $SLURM_ARRAY_TASK_ID
motif=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $2}' $config)

mkdir ../results/$motif
cd ../results/$motif

path=/shared/projects/almond_dw_snp


module load vcftools
module load gcc/11.2.0 

export PATH="/shared/ifbstor1/projects/almond_dw_snp/tools/omegaplus.NOGIT.":$PATH

for i in $(seq 1 500)
do

    filepath=$path/4_FastSimCoal/results/fastsimcoal2/simulations_2/$motif/vcf/test_1_${i}.vcf.gz

    vcftools --gzvcf $filepath \
        --recode --recode-INFO-all \
        --out test_1_${i}


    OmegaPlus-M \
        -name ${motif}.${i}.1k \
        -input test_1_${i}.recode.vcf \
        -length 25000000 \
        -grid 25000 \
        -threads 10 \
        -seed $(( ( RANDOM % 1000000 )  + 1 )) \
        -minsnps 5 \
        -minwin 500 \
        -maxwin 2000

    rm test_1_${i}.recode.vcf

done


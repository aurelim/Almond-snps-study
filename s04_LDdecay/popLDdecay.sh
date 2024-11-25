#!/bin/bash
#SBATCH --job-name=popLDdecay
#SBATCH --mem=100G
#SBATCH --time=1-00:00:00

source msmc_params.sh 
initialize_global_variables

# $path/conda/envs/popLDdecay/PopLDdecay/bin/PopLDdecay \
#     -InVCF $vcf.syn.vcf.gz \
#     -OutStat $vcf.syn.popLD.out \
#     -OutType 1

cd $path/6_MSMC2/results/Almond_tree_pixy

POP=Porientalis

for chr in Pd02 Pd03 Pd04 Pd05 Pd06 Pd07 Pd08
do

$path/conda/envs/popLDdecay/PopLDdecay/bin/PopLDdecay \
    -InVCF ${chr}_AllSites.filtered.vcf.gz \
    -OutStat $path/6_MSMC2/results/Almond_tree_PopLDdecay/$chr.$POP.popLD.out \
    -SubPop $path/6_MSMC2/scripts/${POP}_sample_list.txt \
    -OutType 1

done

# gzip -d $path/6_MSMC2/results/Almond_tree_PopLDdecay/*.stat.gz
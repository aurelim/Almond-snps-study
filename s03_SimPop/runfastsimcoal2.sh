#!/bin/bash
#SBATCH --job-name=fsc2
#SBATCH --mem=50g
#SBATCH --time=1-00:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=2
#SBATCH --array=1-7
#SBATCH -A almond_dw_snp
#SBATCH --partition=fast

config=list_populations.txt
# Extract the sample name for the current $SLURM_ARRAY_TASK_ID
motif=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $2}' $config)

module load fastsimcoal2/27093
module load bcftools/1.16
module load vcftools/0.1.16

source activate /shared/projects/almond_dw_snp/.conda

path=/shared/projects/almond_dw_snp/4_FastSimCoal

mkdir -p $path/results/fastsimcoal2/simulations_2/$motif/
mkdir -p $path/results/fastsimcoal2/simulations_2/$motif/vcf
cd $path/results/fastsimcoal2/simulations_2/$motif/
cp $path/results/Almond_tree_projMin/output/fastsimcoal2/${motif}_DAFpop0.obs .
cp $path/scripts/test.par .

fsc27093 --ifile test.par -m --dnatosnp 1000000 --numsims 500 -I -G -g -k 1000000

for i in $(seq 1 500)
do
    python3 $path/scripts/genotype2vcf.py $path/results/fastsimcoal2/simulations_2/$motif/test/test_1_${i}.cleaned.gen $path/results/fastsimcoal2/simulations_2/$motif/vcf/test_1_${i}.vcf

    bgzip $path/results/fastsimcoal2/simulations_2/$motif/vcf/test_1_${i}.vcf
    tabix -p vcf $path/results/fastsimcoal2/simulations_2/$motif/vcf/test_1_${i}.vcf.gz

done

# rm $path/results/fastsimcoal2/$motif/test/*.arp

#!/bin/bash
#SBATCH --job-name=eSFS
#SBATCH --mem=500g
#SBATCH --time=1-00:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH -A tips_snps_svs_fruittrees
#SBATCH --partition=fast
#SBATCH -e easysfs.err
#SBATCH -o easysfs.out

module load bcftools
module load python/3.7
module load conda 
CONDA_ROOT=/shared/software/miniconda/
source $CONDA_ROOT/etc/profile.d/conda.sh

conda activate /shared/projects/tips_snps_svs_fruittrees/conda/envs/easySFS

# Prepare input vcf
path=/shared/projects/tips_snps_svs_fruittrees/10_projetSNPalmonds/2_VariantCalling

path2=/shared/projects/tips_snps_svs_fruittrees/10_projetSNPalmonds/4_FastSimCoal

for motif in Almond_tree_Pdulcis_C_Asia Almond_tree_Pdulcis_Euro_1 Almond_tree_Pdulcis_Euro_2 Almond_tree_Pdulcis_N_Amer Almond_tree_Pfenzliana Almond_tree_Porientalis Almond_tree_Pspinosissima
do

bcftools concat -o $path2/data/$motif.beaglephased.biallelic.vcf.gz \
    -O z $path/results/$motif/Pd01.beaglephased.biallelic.vcf.gz \
    $path/results/$motif/Pd02.beaglephased.biallelic.vcf.gz \
    $path/results/$motif/Pd03.beaglephased.biallelic.vcf.gz \
    $path/results/$motif/Pd04.beaglephased.biallelic.vcf.gz \
    $path/results/$motif/Pd05.beaglephased.biallelic.vcf.gz \
    $path/results/$motif/Pd06.beaglephased.biallelic.vcf.gz \
    $path/results/$motif/Pd07.beaglephased.biallelic.vcf.gz \
    $path/results/$motif/Pd08.beaglephased.biallelic.vcf.gz
tabix -p vcf $path2/data/$motif.beaglephased.biallelic.vcf.gz
done 

bcftools merge $path2/data/Almond_tree_Pdulcis_C_Asia.beaglephased.biallelic.vcf.gz \
    $path2/data/Almond_tree_Pdulcis_Euro_1.beaglephased.biallelic.vcf.gz \
    $path2/data/Almond_tree_Pdulcis_Euro_2.beaglephased.biallelic.vcf.gz \
    $path2/data/Almond_tree_Pdulcis_N_Amer.beaglephased.biallelic.vcf.gz \
    $path2/data/Almond_tree_Pfenzliana.beaglephased.biallelic.vcf.gz \
    $path2/data/Almond_tree_Porientalis.beaglephased.biallelic.vcf.gz \
    $path2/data/Almond_tree_Pspinosissima.beaglephased.biallelic.vcf.gz \
    -o $path2/data/Almond_tree.beaglephased.biallelic.vcf.gz



VCF=$path2/data/Almond_tree.beaglephased.biallelic.vcf.gz
pop=$path2/scripts/liste_samples.txt

easySFS_dir=/shared/projects/tips_snps_svs_fruittrees/conda/envs/easySFS/easySFS

cd $path2/results/Almond_tree_projMin

python3 $easySFS_dir/easySFS.py -i $VCF -p $pop --ploidy 2 --unfolded -f --proj 17,11,10,10,12,9,6 -v

# C Asia : 34
# Euro_1 : 22
# Euro_2 : 20
# N_Amer : 20
# P fenzliana : 24
# P orientalis : 18
# P spinosissima : 12
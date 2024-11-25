#!/bin/bash
#SBATCH --job-name=s01
#SBATCH --mem=20g
#SBATCH --time=1-00:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH -A almond_dw_snp

module load bcftools/1.16
module load vcftools/0.1.16

source /shared/ifbstor1/projects/almond_dw_snp/parameters.sh
initialize_global_variables

path=/shared/projects/almond_dw_snp
ref_fasta=$path/0_data/pdulcis26.chromosomes.fasta
config=chr_list.txt
chr=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $2}' $config)


cd ../results


# bcftools concat $(for chr in Pd01 Pd02 Pd03 Pd04 Pd05 Pd06 Pd07 Pd08; do echo "${chr}_AllSites.vcf.gz"; done) -o "Almond_tree_AllSites.vcf.gz"

# bcftools concat $(for chr in Pd01 Pd02 Pd03 Pd04 Pd05 Pd06 Pd07 Pd08; do echo "${chr}_AllSites.filtered.vcf.gz"; done) -o "Almond_tree_AllSites.filtered.vcf.gz"

# bcftools concat $(for chr in Pd01 Pd02 Pd03 Pd04 Pd05 Pd06 Pd07 Pd08; do echo "${chr}_AllSites.filtered.dist500.vcf.gz"; done) -o "Almond_tree_AllSites.filtered.dist500.vcf.gz"

tabix -p vcf Almond_tree_AllSites.vcf.gz
tabix -p vcf Almond_tree_AllSites.filtered.vcf.gz
tabix -p vcf Almond_tree_AllSites.filtered.dist500.vcf.gz

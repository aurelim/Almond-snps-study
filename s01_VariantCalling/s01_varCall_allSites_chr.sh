#!/bin/bash
#SBATCH --job-name=varCall
#SBATCH --mem=500G
#SBATCH --time=1-00:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH -A almond_dw_snp
#SBATCH --array=7-8

module load bcftools/1.16
module load vcftools/0.1.16

source /shared/ifbstor1/projects/almond_dw_snp/parameters.sh
initialize_global_variables

path=/shared/projects/almond_dw_snp
ref_fasta=$path/0_data/pdulcis26.chromosomes.fasta
config=chr_list.txt
chr=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $2}' $config)


cd ../results

bcftools mpileup -f $ref_fasta -b $path/2_VariantCalling/scripts/bam_list.txt -r $chr | bcftools call -m -V indels -Oz -a GQ -o ${chr}_AllSites.vcf.gz

vcftools --gzvcf ${chr}_AllSites.vcf.gz \
    --remove-indels \
    --max-missing 0.8 \
    --minDP 10 \
    --maxDP 500 \
    --recode --stdout | bgzip -c > ${chr}_AllSites.filtered.vcf.gz
tabix -p vcf ${chr}_AllSites.filtered.vcf.gz

vcftools --gzvcf ${chr}_AllSites.filtered.vcf.gz \
    --thin 500 \
    --recode --stdout | bgzip -c > ${chr}_AllSites.filtered.dist500.vcf.gz
tabix -p vcf ${chr}_AllSites.filtered.dist500.vcf.gz



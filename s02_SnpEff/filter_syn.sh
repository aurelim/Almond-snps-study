#!/bin/bash
#SBATCH --job-name=filter_syn
#SBATCH -A tips_snps_svs_fruittrees
#SBATCH --nodes=2
#SBATCH --cpus-per-task=5
#SBATCH --mem=20G

module load bcftools

path=/shared/projects/almond_dw_snp

vcf=$path/2_VariantCalling/results/Almond_tree_AllSites

# bcftools filter -i 'INFO/ANN ~ "synonymous_variant"' $vcf.filtered.ann.vcf.gz -o $vcf.filtered.syn.vcf.gz
# bcftools annotate -x INFO $vcf.filtered.syn.vcf.gz -o $vcf.filtered.syn.noannot.vcf.gz

bcftools filter -i 'INFO/ANN ~ "synonymous_variant"' $vcf.filtered.dist500.ann.vcf.gz -o $vcf.filtered.dist500.syn.vcf.gz
bcftools annotate -x INFO $vcf.filtered.dist500.syn.vcf.gz -o $vcf.filtered.dist500.syn.noannot.vcf.gz

#!/bin/bash
#SBATCH --job-name=snpEff_ann
#SBATCH -A tips_snps_svs_fruittrees
#SBATCH --nodes=2
#SBATCH --cpus-per-task=5
#SBATCH --mem=20G

module load gffread/0.12.7
module load snpeff/5.2

path=/shared/projects/almond_dw_snp

snpEff_dir=/shared/home/amesnil/snpEff

fasta=$path/0_data/pdulcis26.chromosomes.fasta
gff=$path/0_data/Prudul26A.chromosomes.gff3
proteins=$path/0_data/Prudul26A.pep.fa
cds=$path/0_data/Prudul26A.cds.fa
genome=Texas
species=Pdulcis

mkdir -p $path/5_snpEff/results
cd $path/5_snpEff/results

mkdir data
mkdir data/genomes
mkdir data/$genome

cp $fasta data/genomes/${genome}.fa
cp $gff data/$genome/genes.gff
cp $proteins data/$genome/protein.fa
cp $cds data/$genome/cds.fa

echo -e "# $species genome, version $genome\n$genome.genome : $species" > snpEff.config

snpEff build -gff3 -c snpEff.config $genome -v

snpEff ann -v $genome $path/2_VariantCalling/results/Almond_tree_AllSites.vcf.gz > $path/2_VariantCalling/results/Almond_tree_AllSites.ann.vcf.gz

snpEff ann -v $genome $path/2_VariantCalling/results/Almond_tree_AllSites.filtered.vcf.gz > $path/2_VariantCalling/results/Almond_tree_AllSites.filtered.ann.vcf.gz

snpEff ann -v $genome $path/2_VariantCalling/results/Almond_tree_AllSites.filtered.dist500.vcf.gz > $path/2_VariantCalling/results/Almond_tree_AllSites.filtered.dist500.ann.vcf.gz

#!/bin/bash
#SBATCH --job-name=trans_geno
#SBATCH --mem=10G
#SBATCH --nodes=1
#SBATCH --cpus-per-task=2
#SBATCH -A almond_dw_snp

python transform_genotype.py
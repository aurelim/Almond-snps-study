#!/bin/bash
#SBATCH -c 4
#SBATCH --mem=500G
#SBATCH -A almond_dw_snp

module load r/4.4.1

for i in 1k 10k
do

    Rscript plot_stats_sweed.R $i
done
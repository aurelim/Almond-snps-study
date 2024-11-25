#!/bin/bash
#SBATCH --job-name=scikit-allel
#SBATCH --mem=100g
#SBATCH --time=1-00:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=48
#SBATCH -A almond_dw_snp
#SBATCH --partition=fast

module load conda

source activate /shared/projects/almond_dw_snp/.conda

python --version

python scikit-allel_fsc_sim.py 48

for i in {1..500}
do
    for pop in Pdulcis_C_Asia Pdulcis_Euro_1 Pdulcis_Euro_2 Pdulcis_N_Amer Pfenzliana Porientalis Pspinosissima
    do

        badFILE=/shared/projects/almond_dw_snp/4_FastSimCoal/results/fastsimcoal2/simulations_2/Almond_tree_${pop}/test/test_1_${i}.gen
        goodFILE=/shared/projects/almond_dw_snp/4_FastSimCoal/results/fastsimcoal2/simulations_2/Almond_tree_${pop}/test/test_1_${i}.cleaned.gen
        if test -f "$goodFILE"; then
        rm $badFILE
        fi
    done
done

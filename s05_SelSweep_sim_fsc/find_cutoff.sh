#!/bin/bash
#SBATCH --job-name=cutoff
#SBATCH --mem=200g
#SBATCH --time=1-00:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH -A almond_dw_snp
#SBATCH --partition=fast

for pop in Pdulcis_C_Asia Pdulcis_Euro_1 Pdulcis_Euro_2 Pdulcis_N_Amer Pfenzliana Porientalis Pspinosissima
do
    popi=Almond_tree_${pop}

    for i in 1k 10k
    do
        python findFDRcutoff_SweeD.py $popi $i
        python findFDRcutoff_Omega.py $popi $i
        python findFDRcutoff_RAiSD.py $popi $i
        
        
    done

done
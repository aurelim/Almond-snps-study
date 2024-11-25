#!/bin/bash
#SBATCH --job-name=raisd
#SBATCH --mem=50g
#SBATCH --time=1-00:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --array=1-2,4-7
#SBATCH -A almond_dw_snp
#SBATCH --partition=fast

config=list_populations.txt
# Extract the sample name for the current $SLURM_ARRAY_TASK_ID
motif=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $2}' $config)

path=/shared/projects/almond_dw_snp


module load vcftools
module load r/4.3.1
module load gcc/11.2.0 

export LD_LIBRARY_PATH=$path/tools/RAiSD/raisd-master/gsl/lib:$LD_LIBRARY_PATH
export LIBRARY_PATH=$path/tools/RAiSD/raisd-master/gsl/lib:$LIBRARY_PATH
export PATH=$path/tools/RAiSD/raisd-master/bin/release:$PATH

out_path=../results/$motif
mkdir $out_path
cd $out_path
window_size=86

for i in $(seq 1 500)
do

    if [[ -f temp_pipe.vcf ]]; then
        rm temp_pipe.vcf
    fi

    zcat $path/4_FastSimCoal/results/fastsimcoal2/simulations_2/$motif/vcf/test_1_${i}.vcf.gz > temp_pipe.vcf 
    RAiSD -n ${motif}.${i}.$window_size \
          -I temp_pipe.vcf \
          -R -s -D -w $window_size -M 3 -y 2 -k 0.05 -f

done

# -w	Provides the window size (integer value). The default value is 50 (empirically determined).
# -c	Provides the slack for the SFS edges to be used for the calculation of mu_SFS. The default value is 1 (singletons and S-1 snp class, where S is the sample size).
# -G	Provides the grid size to specify the total number of evaluation points across the data. When used, RAiSD reports mu statistic scores at equidistant locations between the first and last SNPs.

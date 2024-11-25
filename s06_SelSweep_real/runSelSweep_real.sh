#!/bin/bash
#SBATCH --nodes=1
#SBATCH -c 4
#SBATCH --mem=50G
#SBATCH --time=2-00:00:00
#SBATCH -A almond_dw_snp
#SBATCH --array=1-7
#SBATCH --partition=long

module load vcftools/0.1.16
module load bcftools

config=list_populations.txt
# Extract the sample name for the current $SLURM_ARRAY_TASK_ID
motif=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $2}' $config)

path=/shared/projects/almond_dw_snp

export PATH="/shared/projects/almond_dw_snp/tools/omegaplus.NOGIT.":$PATH
export LD_LIBRARY_PATH=$path/tools/RAiSD/raisd-master/gsl/lib:$LD_LIBRARY_PATH
export LIBRARY_PATH=$path/tools/RAiSD/raisd-master/gsl/lib:$LIBRARY_PATH
export PATH=$path/tools/RAiSD/raisd-master/bin/release:$PATH
export PATH=$path/tools/sweed:$PATH

mkdir ../results/$motif
cd ../results/$motif

###### before SS #######
#chr(Pd)   #length		#grid_10k	#grid_1k	#grid_200   #grid_50
#Pd01		43996934	4400		43997        219985     879938
#Pd02		26138581	2614		26139		 130693     522771
#Pd03		24073526	2407     	24074		 120368     481470
#Pd04		24375383	2438        24375        121877     487507
#Pd05		18233718	1823        18234        91169      364674
#Pd06		29596931	2960        29597        147985     591938
#Pd07		21340587	2134        21341        106703     426811
#Pd08		20428636	2043        20429		 102143     408572

# declare -A chr_grids=( ["Pd01"]="4400 43997 219985 879938" ["Pd02"]="2614 26139 130693 522771" ["Pd03"]="2407 24074 120368 481470" ["Pd04"]="2438 24375 121877 487507" ["Pd05"]="1823 18234 91169 364674" ["Pd06"]="2960 29597 147985 591938" ["Pd07"]="2134 21341 106703 426811" ["Pd08"]="2043 20429 102143 408572" )
declare -A chr_grids=( ["Pd01"]="4400 43997" ["Pd02"]="2614 26139" ["Pd03"]="2407 24074" ["Pd04"]="2438 24375" ["Pd05"]="1823 18234" ["Pd06"]="2960 29597" ["Pd07"]="2134 21341" ["Pd08"]="2043 20429" )
 
for chr in Pd01 Pd02 Pd03 Pd04 Pd05 Pd06 Pd07 Pd08
do

    # vcftools --gzvcf "$path/2_VariantCalling/results/$motif/${chr}.beaglephased.biallelic.masked.vcf.gz" \
    #     --recode --recode-INFO-all \
    #     --out "$path/2_VariantCalling/results/$motif/ss_${chr}"

    # vcftools --vcf $path/2_VariantCalling/results/$motif/ss_${chr}.noadmixed.recode.vcf \
    #     --hap-r2 --ld-window-bp 500 \
    #     --out $path/2_VariantCalling/results/$motif/ss_${chr}.noadmixed.dist500

    vcftools --vcf $path/2_VariantCalling/results/$motif/ss_${chr}.noadmixed.recode.vcf \
        --thin 500 \
        --recode --recode-INFO-all \
        --out $path/2_VariantCalling/results/$motif/ss_${chr}.noadmixed.dist500
    
    for grid in ${chr_grids[$chr]}
    do
        echo $grid
        
        OmegaPlus-M \
        -name ${motif}.${chr}.${grid}.dist500.real_dataset \
        -input $path/2_VariantCalling/results/$motif/ss_${chr}.noadmixed.dist500.recode.vcf \
        -grid $grid \
        -threads 10 \
        -seed $(( ( RANDOM % 1000000 )  + 1 )) \
        -minsnps 5 \
        -minwin 500 \
        -maxwin 2000

        SweeD-P \
        -name ${motif}.${chr}.${grid}.dist500.real_dataset \
        -input $path/2_VariantCalling/results/$motif/ss_${chr}.noadmixed.dist500.recode.vcf \
        -grid $grid \
        -threads 10
    done

    # for window_size in 10 50 86
    for window_size in 86
    do

        RAiSD -n ${motif}_${chr}.${window_size}snp.dist500.real_dataset \
                -I $path/2_VariantCalling/results/$motif/ss_${chr}.noadmixed.dist500.recode.vcf \
                -R -s -D -w $window_size -M 3 -y 2 -k 0.05 -f

    done


done


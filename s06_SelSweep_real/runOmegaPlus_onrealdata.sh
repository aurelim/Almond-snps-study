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

mkdir ../results/$motif
cd ../results/$motif

###### before SS #######
#chr(Pd)   #length		#grid_10k	#grid_1k	#grid_200
#Pd01		43996934	4400		43997        219985
#Pd02		26138581	2614		26139		 130693
#Pd03		24073526	2407     	24074		 120368
#Pd04		24375383	2438        24375        121877
#Pd05		18233718	1823        18234        91169
#Pd06		29596931	2960        29597        147985
#Pd07		21340587	2134        21341        106703
#Pd08		20428636	2043        20429		 102143

declare -A chr_grids=( ["Pd01"]="4400 43997 219985" ["Pd02"]="2614 26139 130693" ["Pd03"]="2407 24074 120368" ["Pd04"]="2438 24375 121877" ["Pd05"]="1823 18234 91169" ["Pd06"]="2960 29597 147985" ["Pd07"]="2134 21341 106703" ["Pd08"]="2043 20429 102143" )

 
for chr in Pd01 Pd02 Pd03 Pd04 Pd05 Pd06 Pd07 Pd08
do

    # 1/ Process vcf

    FILE=$path/2_VariantCalling/results/$motif/${chr}.beaglephased.biallelic.masked.vcf.gz
    if [ -f $FILE ]; then
        echo "$FILE exists"
    else
        echo $FILE does not exists 

        bcftools view -T ^$path/2_VariantCalling/results/$motif/output_genmap/$prefix.genmap.mask.bed \
            $path/2_VariantCalling/results/$motif/${chr}.beaglephased.biallelic.vcf.gz \
            -o $FILE
    fi



    vcftools --gzvcf $FILE \
        --recode --recode-INFO-all \
        --out "$path/2_VariantCalling/results/$motif/ss_${chr}"

    
    for grid in ${chr_grids[$chr]}
    do
        echo $grid
        
        OmegaPlus-M \
        -name ${motif}.${chr}.${grid} \
        -input $path/2_VariantCalling/results/$motif/ss_${chr}.recode.vcf \
        -grid $grid \
        -threads 10 \
        -seed $(( ( RANDOM % 1000000 )  + 1 )) \
        -minsnps 5 \
        -minwin 500 \
        -maxwin 2000

    done
done


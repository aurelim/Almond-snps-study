#!/bin/bash
#SBATCH -c 4
#SBATCH --mem=50G
#SBATCH --array=1-7
#SBATCH -A almond_dw_snp

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


mkdir ../results/$motif
cd ../results/$motif


for chr in Pd01 Pd02 Pd03 Pd04 Pd05 Pd06 Pd07 Pd08
do

# mkfifo temp_pipe.vcf

      # FILE=$path/2_VariantCalling/results/$motif/${chr}.beaglephased.biallelic.masked.vcf.gz
  
      # if [ -f $FILE ]; then
      #       echo "$FILE exists"
      # else
      #       echo $FILE does not exists 

      #       bcftools view -T ^$path/2_VariantCalling/results/$motif/output_genmap/$prefix.genmap.mask.bed \
      #             $path/2_VariantCalling/results/$motif/${chr}.beaglephased.biallelic.vcf.gz \
      #             -o $path/2_VariantCalling/results/$motif/${chr}.beaglephased.biallelic.masked.vcf.gz
      # fi



      zcat $path/2_VariantCalling/results/$motif/${chr}.beaglephased.biallelic.masked.vcf.gz > temp_pipe.vcf 
      
      RAiSD -n ${motif}_${chr}.50bp.real_dataset \
            -I temp_pipe.vcf \
            -R -s -D -w 50 -M 3 -y 2 -k 0.05 -f
      
      rm temp_pipe.vcf

done

# -L Provides the size of the region in basepairs for ms files. See -B option for vcf files.
# -B Provides the chromosome size in basepairs (first INTEGER) and SNPs (second INTEGER) for vcf files that contain a single chromosome. 
# If -B is not provided, or the input vcf file contains multiple chromosomes, RAiSD will determine the respective values by parsing 
# each chromosome in its entirety before processing, which will lead to slightly longer overall execution time.


# -R Includes additional information in the report file(s), i.e., window start and end, and the mu-statistic factors 
# for variation, SFS, and LD.
# -f Overwrites existing run files under the same run ID.
# -k Provides the false positive rate (e.g., 0.05) to report the corresponding reported score after sorting the reported locations 
# for all the datasets in the input file.
# -s Generates a separate report file per set.
# -t Removes the set separator symbol from the report(s).
# -P Generates four plots (for the three mu-statistic factors and the final score) in one PDF file per set of SNPs 
# in the input file using Rscript (activates -s, -t, and -R).
# -A Provides a probability value to be used for the quantile function in R and generates a Manhattan plot for the final 
# mu-statistic score using Rscript (activates -s, -t, and -R).
# -M	Indicates the missing-data handling strategy (0: discards SNP (default), 1: imputes N per SNP, 2: represents N through a mask, 3: ignores allele pairs with N).
# -y	Provides the ploidy (integer value), used to correctly represent missing data.
# -D	Generates a site report, e.g., total, discarded, imputed etc.
		
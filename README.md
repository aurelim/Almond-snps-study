# Almonds-selective-sweeps

Variant calling using P. dulcis Texas V2 as reference. 
SNPs were called on 75 individuals, from 4 P. dulcis (crop) populations and wild species : P. fenzliana, P. orientalis, P. spinosissima. 
Variants effects were predicted using snpEff (https://pcingola.github.io/SnpEff/).

To determine selective sweep signatures cutoff, neutraly evolving populations were generated using fastsimcoal2 (https://cmpg.unibe.ch/software/fastsimcoal27/). 
Genetic diversity on simulated and real data were compared. Pi values were computed using scikit-allel (https://github.com/cggh/scikit-allel).
On real data, non synonymous variants were removed from the vcf file, and a minimum distance of 500 bp between SNPs was applied to avoid linkage disequilibrium effects. 

OmegaPlus (https://cme.h-its.org/exelixis/web/software/omegaplus/index.html), RAiSD (https://github.com/alachins/raisd) and SweeD (https://cme.h-its.org/exelixis/web/software/sweed/) were used to calculate omega, mu and selective sweep likelihood values on 2 sizes of windows : a small one covering 1 kb or 10 SNPs depending on the tool used and a big one covering 10 kb or 86 SNPs. 
Values were sorted to identify the 95% FDR value. 

OmegaPlus calcul the Ω score detecting correlations disequilibrium linkage around selective sweep sites. This method is sensitive to specific pattern of LD but also in absence of strong selective sweep. 

RAiSD compute the µ statistic which is based on a combination of multiple sweep signatures (diversity, mutation rate, disequilibrium linkage) with a smaller weight of LD than OmegaPlus. 

SweeD can calculate the theoretical SFS (site frequency spectrum) of a given demographic model and implements a CLR (composite likelihood ratio) test. 


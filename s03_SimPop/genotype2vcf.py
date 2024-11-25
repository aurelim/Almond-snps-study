import pandas as pd
import sys

file = sys.argv[1]
output = sys.argv[2]

# Charger les données du fichier CSV
df = pd.read_csv(file, sep='\t')

# Créer un fichier VCF
with open(output, 'w') as vcf:
    # Écrire l'en-tête VCF
    vcf.write("##fileformat=VCFv4.2\n")
    vcf.write("##source=fsc2GenotypeToVCF\n")
    vcf.write("#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\t" + "\t".join(df.columns[4:]) + "\n")
    
    # Parcourir chaque ligne du dataframe et la convertir en format VCF
    for index, row in df.iterrows():
        chrom = row['Chrom']
        pos = row['Pos']
        id_ = '.'  # Pas d'ID spécifié dans vos données
        ref = row['Anc_all']
        alt = row['Der_all']
        qual = '.'
        filt = '.'
        info = '.'
        format_ = 'GT'  # Format des génotypes
        
        # Convertir les valeurs de génotype pour chaque échantillon
        genotypes = []
        for value in row[4:]:
            if value == 0:
                genotypes.append("0/0")
            elif value == 1:
                genotypes.append("0/1")
            elif value == 2:
                genotypes.append("1/1")
            else:
                genotypes.append("./.")  # Valeur manquante ou autre
                
        # Écrire la ligne VCF
        vcf.write(f"{chrom}\t{pos}\t{id_}\t{ref}\t{alt}\t{qual}\t{filt}\t{info}\t{format_}\t" + "\t".join(genotypes) + "\n")

print(f"Conversion terminée ! Le fichier VCF est généré sous le nom {output}")

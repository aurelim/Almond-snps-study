import sys
import re

# Définir un encodage des nucléotides en fonction des chiffres
nucleotide_encoding = {
    '0': 'A',  # Correspond à A
    '1': 'C',  # Correspond à C
    '2': 'G',  # Correspond à G
    '3': 'T'   # Correspond à T
}

def parse_arp(arp_file):
    """
    Cette fonction lit un fichier .arp et extrait les positions et les génotypes
    """
    with open(arp_file, 'r') as file:
        lines = file.readlines()

    positions = {}  # Dictionnaire pour stocker les positions polymorphes par chromosome
    samples = {}  # Dictionnaire pour stocker les génotypes par échantillon
    current_chromosome = None
    reading_positions = False
    reading_samples = False

    for line in lines:
        line = line.strip()
        
        # Détecter les positions des SNPs par chromosome
        chrom_match = re.match(r'# (\d+) polymorphic positions on chromosome (\d+)', line)
        if chrom_match:
            current_chromosome = int(chrom_match.group(2))
            positions[current_chromosome] = []
            reading_positions = True
            continue
        
        # Lire les positions jusqu'à la prochaine ligne
        if reading_positions and line.startswith('#'):
            pos_list = [int(p.strip()) for p in line[1:].split(',') if p.strip()]
            positions[current_chromosome].extend(pos_list)
            continue

        # Début des données d'échantillons
        if line.startswith('SampleName'):
            reading_positions = False
            reading_samples = True
            continue

        # Lire les données des échantillons
        if reading_samples:
            if re.match(r'\d+_\d+\s+1\s+\d+', line):
                parts = line.split()
                sample_name = parts[0]
                sample_genotype = parts[2]
                samples[sample_name] = sample_genotype

    return positions, samples


def write_vcf(vcf_file, positions, samples):
    """
    Cette fonction écrit un fichier VCF basé sur les positions et les génotypes extraites,
    en utilisant 1_1 comme référence.
    """
    with open(vcf_file, 'w') as file:
        # En-têtes du fichier VCF
        file.write("##fileformat=VCFv4.2\n")
        file.write("#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\t" +
                   "\t".join(samples.keys()) + "\n")

        # Utiliser l'échantillon 1_1 comme génotype de référence
        reference_sample = samples['1_1']

        # Parcourir tous les chromosomes et positions, incluant les non-polymorphes
        for chrom, pos_list in positions.items():
            max_pos = max(pos_list)  # Dernière position connue pour ce chromosome
            for pos in range(1, max_pos + 1):  # Inclure toutes les positions, y compris non variables
                if pos in pos_list:
                    # Position variable
                    i = pos_list.index(pos)
                    ref_allele_1 = reference_sample[i * 2]  # Allèle 1 de 1_1
                    ref_allele_2 = reference_sample[i * 2 + 1]  # Allèle 2 de 1_1

                    ref_allele_1 = nucleotide_encoding[ref_allele_1]
                    ref_allele_2 = nucleotide_encoding[ref_allele_2]
                    ref = ref_allele_1

                    alt_set = set()
                    genotypes = []
                    for sample_name, genotype in samples.items():
                        allele1 = genotype[i * 2]
                        allele2 = genotype[i * 2 + 1]
                        nuc1 = nucleotide_encoding[allele1]
                        nuc2 = nucleotide_encoding[allele2]

                        if nuc1 != ref:
                            alt_set.add(nuc1)
                        if nuc2 != ref:
                            alt_set.add(nuc2)

                        geno = f"{0 if nuc1 == ref else 1}|{0 if nuc2 == ref else 1}"
                        genotypes.append(geno)

                    alt = ",".join(alt_set) if alt_set else "."
                else:
                    # Position non variable, même allèle pour tous
                    ref = nucleotide_encoding[reference_sample[0]]
                    alt = "."
                    genotypes = ["0|0"] * len(samples)

                file.write(f"{chrom}\t{pos}\t.\t{ref}\t{alt}\t.\t.\t.\tGT\t" +
                           "\t".join(genotypes) + "\n")

# Utilisation avec arguments de ligne de commande
if len(sys.argv) != 3:
    print("Utilisation : python script.py <fichier_arp> <fichier_vcf>")
    sys.exit(1)

arp_file = sys.argv[1]
vcf_file = sys.argv[2]

positions, samples = parse_arp(arp_file)  # Extraire les positions et génotypes du fichier .arp
write_vcf(vcf_file, positions, samples)  # Écrire les données dans un fichier .vcf

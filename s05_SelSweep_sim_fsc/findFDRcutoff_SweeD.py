import os
import sys

# By Xilong CHEN
# Create date: 2022-08-02
# Contact: chen_xilong@outlook.com

# Adjusted by Yuqi
# 2024-09-04

# Usage: python findFDRcutoff_SweeD.py pop window_size
pop = sys.argv[1]
folder = "s08.find_FPRcutoff_SweeD"
workdir = "../results"

# Créer le dossier si nécessaire
os.makedirs(os.path.join(workdir, folder), exist_ok=True)

cutoff = 0.05  # FPR at 95%
cutoff_op = 1 - cutoff
window_size = sys.argv[2]

# Fonction pour traiter chaque section
def process_section(section):
    # Remove section headers and filter out empty lines and header lines
    section = [line for line in section if not line.startswith("//") and line.strip() and not line.startswith("Position")]
    if len(section) > 0:
        # Read the section into a list of lists
        data = [line.split() for line in section]
        # Extract the 2nd column (likelihood) and convert to float
        stat_values = [float(row[1]) for row in data if len(row) > 2]  # Ensure there are at least 3 columns
        return stat_values
    return []


all_max_stats_values = []

# Lire et traiter les 500 fichiers
for re in range(1, 150):
    file_path = f"{workdir}/{pop}/SweeD_Report.{pop}.{re}.{window_size}"
    
    # Ouvrir le fichier
    with open(file_path, 'r') as file:
        lines = file.readlines()
        
    sections = []
    current_section = []
    for line in lines:
        if line.startswith("//"):
            sections.append(current_section)
            current_section = []
        current_section.append(line)
    if current_section:
        sections.append(current_section)

    all_stats_values = []

    for section in sections:
        all_stats_values.extend(process_section(section))

    # Get the maximum stat value
    max_stat = max(all_stats_values)
    all_max_stats_values.append(max_stat)

    print(f"Traitement de {file_path} - Max likelihood: {max_stat}")


# Trier toutes les valeurs oméga collectées en ordre décroissant
all_max_stats_values.sort(reverse=True)

# Supprimer les valeurs de la liste pour atteindre le seuil cutoff_op
num_to_remove = int(len(all_max_stats_values) * cutoff_op) - 1
all_max_stats_values = all_max_stats_values[:-num_to_remove]
# Generate new list of elements containing the original elements except the last num_to_remove elements
# We keep only the top 5% of the values

# Récupérer la dernière valeur comme seuil
stat_cutoff = all_max_stats_values[-1] if all_max_stats_values else None

# Écrire le résultat dans un fichier
output_path = os.path.join(workdir, folder, f"{pop}.FPRcutoff.{window_size}.txt")
with open(output_path, 'w') as ouc:
    ouc.write(f"stat_cutoff {pop}\n")
    if stat_cutoff is not None:
        ouc.write(f"{stat_cutoff}\n")

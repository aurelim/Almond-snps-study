import os
import sys

# By Xilong CHEN
# Create date: 2022-08-02
# Contact: chen_xilong@outlook.com

# Adjusted by Yuqi
# 2024-09-04

pop = sys.argv[1]
folder = "s08.find_FPRcutoff_RAiSD"
workdir = "../results"

# Créer le dossier si nécessaire
os.makedirs(os.path.join(workdir, folder), exist_ok=True)

cutoff = 0.05  # FPR at 95%
cutoff_op = 1 - cutoff
window_size = sys.argv[2]

raisd = []

# Lire et traiter les 500 fichiers
for re in range(1, 501):
    for chr in range(1, 9):
        file_path = f"{workdir}/{pop}/RAiSD_Report.{pop}.{re}.{window_size}.{chr}"
    
        # Ouvrir le fichier
        with open(file_path, 'r') as inOm:
            # Lire et ignorer la première ligne
            next(inOm)

            # Lire les autres lignes
            for block in inOm.read().split("\n//"):
                block = block.strip()
                if not block:
                    continue

                lines = block.split("\n")
                nu = lines.pop(0)  # Retirer la première ligne
                raisd_re = []

                # Traiter chaque ligne restante
                for line in lines:
                    parts = line.split("\t")
                    if len(parts) >= 2:
                        po, mu = parts[0], float(parts[6])
                        raisd_re.append(mu)

                # Trier les valeurs oméga en ordre décroissant et récupérer la première
                raisd_re.sort(reverse=True)
                if raisd_re:
                    raisd.append(raisd_re[0])

# Trier toutes les valeurs oméga collectées en ordre décroissant
raisd.sort(reverse=True)

# Supprimer les valeurs de la liste pour atteindre le seuil cutoff_op
num_to_remove = int(len(raisd) * cutoff_op) - 1
raisd = raisd[:-num_to_remove]

# Récupérer la dernière valeur comme seuil
raisd_cutoff = raisd[-1] if raisd else None

# Écrire le résultat dans un fichier
output_path = os.path.join(workdir, folder, f"{pop}.FPRcutoff.{window_size}.txt")
with open(output_path, 'w') as ouc:
    ouc.write(f"raisd_cutoff {pop}\n")
    if raisd_cutoff is not None:
        ouc.write(f"{raisd_cutoff}\n")

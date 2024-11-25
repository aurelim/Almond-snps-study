import os

# Dossier contenant les fichiers de génotypes
input_folders_pop = "/shared/projects/almond_dw_snp/4_FastSimCoal/results/fastsimcoal2"
input_folder = "/shared/projects/almond_dw_snp/4_FastSimCoal/results/fastsimcoal2/Almond_tree_Pspinosissima/test"

for i in range(1, 1001):  # Assumant que vos fichiers vont de 1 à 100
    
    filename = "test_1_" + str(i)
    input_file_path = os.path.join(input_folder, filename + ".gen")
    output_file_path = os.path.join(input_folder, filename + ".cleaned.gen")
    
    with open(input_file_path, 'r') as infile, open(output_file_path, 'w') as outfile:
        for line in infile:
            cleaned_line = line.rstrip()  
            outfile.write(cleaned_line + '\n')  
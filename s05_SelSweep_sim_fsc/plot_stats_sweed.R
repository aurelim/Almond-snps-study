library(tidyverse)
library(data.table)
library(ggstatsplot)

args <- commandArgs(trailingOnly = TRUE)

# Vérifier les arguments et les utiliser
if (length(args) < 1) {
  stop("Il faut au moins un argument")
}

window_size <- args[1]

cat("Window size is : ", window_size, "\n")


path = "../results/"
liste_Rep = sample(1:200, 100, replace = F)
liste_pop = c("Almond_tree_Pdulcis_C_Asia", "Almond_tree_Pdulcis_Euro_1", "Almond_tree_Pdulcis_Euro_2", "Almond_tree_Pdulcis_N_Amer", "Almond_tree_Pfenzliana", "Almond_tree_Porientalis", "Almond_tree_Pspinosissima")
liste_idx = expand.grid(liste_pop, liste_Rep)

res = do.call(rbind, lapply(1:nrow(liste_idx), function(i) {
  pop = liste_idx$Var1[i]
  rep = liste_idx$Var2[i]

  file = paste0(path, pop, "/SweeD_Report.", pop,".", rep, ".", window_size)
  tmp = readLines(file)
  tmp2 = tmp[!grepl("^//", tmp)]
  tmp3 = tmp2[grepl("^Position", tmp2)]

  data <- read.table(text = paste(tmp2, collapse = "\n"), header = FALSE) %>% 
    mutate(stat = as.numeric(V2)) %>%
    mutate(population = pop)
}))


sampled_data <- res %>%
  group_by(population) %>%
  slice_sample(n = 5000)


p = sampled_data %>% 
  ggplot(aes(x = population, y = stat, color = population))+
  # geom_jitter(position = position_dodge(width = 0.1))+
  geom_boxplot()+
  scale_color_manual(values = c('Almond_tree_Pdulcis_C_Asia' = '#8d5bb3',
                                'Almond_tree_Pdulcis_Euro_1' = '#47c5f3',
                                'Almond_tree_Pdulcis_Euro_2' = '#ffbb86',
                                'Almond_tree_Pdulcis_N_Amer' = '#cb3636',
                                'Almond_tree_Pfenzliana' = '#ffe38b',
                                'Almond_tree_Porientalis' = '#283f75',
                                'Almond_tree_Pspinosissima' = '#7b9e64'))+
  ylab("selective sweep likelihood")+
  # scale_y_log10()+
  theme_ggstatsplot()+
  theme(legend.position = "none", axis.text.x = element_text(angle = 90))

ggsave(
  paste0("../results/distri_alpha.", window_size, ".png"),
  plot = p,
  width = 10,
  height = 20,
  units = "cm",
)

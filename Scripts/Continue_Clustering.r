#Library
.libPaths("/PHShome/mom41/R/x86_64-pc-linux-gnu-library/3.4/")
#library(dplyr)
#library(Rtsne)
#library(umap)
#library(harmony)
library(Rphenograph)
library(RColorBrewer)
library(ggplot2)
library(viridis)

#Reload data
load("dat.RData")
load("id_set_match.RData")
load("dat_harm.RData")
load("dat_graph.RData")
load("graph_key.RData")
#load("dat_clust.RData")
load("dat_tsne.RData")
load("dat_umap.RData")

#Visualise
colourset <- colors(distinct = T)
colourset <- colourset[-grep("gray|white", colourset)]

my_pch ="."

plot_tsne <- data.frame(X = dat_tsne$Y[,1],
                        Y = dat_tsne$Y[,2],
                        ID = rownames(dat_tsne$Y)) 

plot_tsne <- merge(plot_tsne, graph_key, by.x = "ID", by.y = 1)
colnames(plot_tsne)[ncol(plot_tsne)] <- "Cluster"

plot_tsne <- merge(plot_tsne, id_set_match, by = "ID")

plot_tsne$Cluster <- as.factor(plot_tsne$Cluster)

plot_umap <- data.frame(X = dat_umap$layout[,1],
                        Y = dat_umap$layout[,2],
                        ID = rownames(dat_umap$layout))

plot_umap <- merge(plot_umap, graph_key, by.x = "ID", by.y = 1)
colnames(plot_umap)[ncol(plot_umap)] <- "Cluster"

plot_umap <- merge(plot_umap, id_set_match, by = "ID")

plot_umap$Cluster <- as.factor(plot_umap$Cluster)

pdf(file = "embedding_plots.pdf")
#TSNE
plot_tsne <- plot_tsne[sample.int(nrow(plot_tsne)),]

ggplot(plot_tsne, aes(x = X, y = Y, colour = Set)) +
  geom_point(pch = my_pch,
             size = 2) +
  theme_classic() +
  scale_colour_viridis(discrete = T) +
  labs(title = "tSNE embedding post-Harmony",
       subtitle = "Showing degree of Harmony",
       x = "",
       y = "")

ggplot(plot_tsne, aes(x = X, y = Y, colour = Cluster)) +
  geom_point(pch = my_pch,
             size = 2) +
  theme_classic() +
  scale_colour_manual(values = colourset) +
  theme(legend.position = "none") +
  labs(title = "tSNE embedding post-Harmony",
       subtitle = paste0("Showing kNN clustering (N = ", length(unique(plot_tsne$Cluster)), ")"),
       x = "",
       y = "")

#UMAP
plot_umap <- plot_umap[sample.int(nrow(plot_umap)),]

ggplot(plot_umap, aes(x = X, y = Y, colour = Set)) +
  geom_point(pch = my_pch,
             size = 2) +
  theme_classic() +
  scale_colour_viridis(discrete = T) +
  labs(title = "Umap embedding post-Harmony",
       subtitle = "Showing degree of Harmony",
       x = "",
       y = "")

ggplot(plot_umap, aes(x = X, y = Y, colour = Cluster)) +
  geom_point(pch = my_pch,
             size = 2) +
  theme_classic() +
  scale_colour_manual(values = colourset) +
  theme(legend.position = "none") +
  labs(title = "Umap embedding post-Harmony",
       subtitle = paste0("Showing kNN clustering (N = ", length(unique(plot_umap$Cluster)), ")"),
       x = "",
       y = "")
dev.off()
















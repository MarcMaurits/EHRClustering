#library
.libPaths("/PHShome/mom41/R/x86_64-pc-linux-gnu-library/3.6/")
library(ggplot2)
library(viridis)
library(ggrepel)
library(grid)
library(gridExtra)
library(dplyr)
library(reshape2)
library(Rphenograph)
library(lisi)
library(Matrix)
library(glmnet)
library(caret)

source("Scripts/Functions.R")

set.seed(162534)

#data
load("R_saves/dat_clust.RData")
load("R_saves/id_set_match.RData")
load("R_saves/dat_em.RData")
load("R_saves/dat_bg.RData")
load("R_saves/dat_tsne.RData")
load("R_saves/dat_uc.RData")
load("R_saves/plot_lisi.RData")
load("R_saves/phecodes_complete.RData")
load("R_saves/plot_lisi_raw.RData")
load("R_saves/set_cols.RData")
load("R_saves/dat_harm.RData")
load("R_saves/top10_EN_abs.RData")
load("R_saves/dat_umap.RData")
load("R_saves/graph_key.RData")

#prep
dat_clust$PheCode <- as.factor(dat_clust$PheCode)
dat_clust$Cluster <- as.factor(dat_clust$Cluster)

Top = 10

dat_excl <- lapply(levels(dat_clust$Cluster), function(x){
  tmp <- dat_uc[dat_uc$Cluster == x,]
  table(tmp$PheCode)/length(unique(tmp$ID))
})

dat_excl <- lapply(1:length(dat_excl), function(x){
  dat_excl[[x]][order(dat_excl[[x]], decreasing = T)][1:Top]
})

dat_excl <- lapply(1:length(dat_excl), function(x){
  data.frame(Code = names(dat_excl[[x]]),
             Weight = 1 - (1/length(dat_excl[[x]]))*(0:(length(dat_excl[[x]]) - 1)))
})

dat_excl <- do.call("rbind", dat_excl)

excl_codes <- sapply(unique(dat_excl$Code), function(x){
  sum(dat_excl[dat_excl$Code == x, "Weight"])
})

names(excl_codes) <- unique(dat_excl$Code)

excl_codes <- excl_codes[excl_codes >= length(levels(dat_clust$Cluster))*(1-((Top - 1)/Top))]

hist_lisi <- data.frame(LISI = c(plot_lisi$Set, plot_lisi_raw$Set), Stage = rep(c("Post", "Pre"), times = c(nrow(plot_lisi), nrow(plot_lisi_raw))))

plot_umap <- data.frame(X = dat_umap$layout[,1],
                        Y = dat_umap$layout[,2],
                        ID = rownames(dat_umap$layout))

plot_umap <- merge(plot_umap, graph_key, by.x = "ID", by.y = 1)
colnames(plot_umap)[ncol(plot_umap)] <- "Cluster"

plot_umap <- merge(plot_umap, id_set_match, by = "ID")

plot_umap$Cluster <- as.factor(plot_umap$Cluster)

subkey <- createSubClustering(dat_clust, 63, dat_harm, type = "knn")

dat_sub <- merge(dat_clust, subkey, by = "ID", all.x = F)

dat_sub <- dat_sub[,-which(colnames(dat_sub) == "Cluster")]

colnames(dat_sub)[which(colnames(dat_sub) == "SubCluster")] <- "Cluster"

dat_sub$PheCode <- as.factor(dat_sub$PheCode)
dat_sub$Cluster <- as.factor(dat_sub$Cluster)

dat_sub_uc <- unique(dat_sub[,c("ID", "PheCode", "Cluster")])

dat_sub_em <- lapply(unique(id_set_match$Set), function(x){
    lapply(unique(dat_sub$Cluster), function(y){
      tmp <- dat_sub_uc[dat_sub_uc$Cluster == y,]
      tmp <- tmp[tmp$ID %in% id_set_match[id_set_match$Set == x, "ID"],]
      table(tmp$PheCode)/length(unique(tmp$ID))
    })
  })
  names(dat_sub_em) <- unique(id_set_match$Set)
  invisible(lapply(1:length(dat_sub_em), function(x){
    names(dat_sub_em[[x]]) <<- unique(dat_sub$Cluster) 
  })
  )
  
dat_sub_bg <- unique(dat_sub_uc[,c("ID", "PheCode")])
dat_sub_bg <- table(dat_sub_bg$PheCode)/length(unique(dat_sub_bg$ID))


SubEN <- calculateSubEN(dat_clust, subkey)

save(SubEN, file = "/PHShome/mom41/Clustering/plots_paper/SubEN.RData")

colourset <- colors(distinct = T)
colourset <- colourset[-grep("gray|white", colourset)]

#plots
pdf("/PHShome/mom41/Clustering/plots_paper/umap.pdf", width = 10)
ggplot(plot_umap, aes(x = X, y = Y, colour = Cluster)) +
  geom_point(pch = ".",
             size = 2) +
  theme_classic() +
  scale_colour_manual(values = colourset) +
  theme(legend.position = "none") +
  labs(title = "Umap embedding post-Harmony",
       subtitle = paste0("Showing kNN clustering (N = ", length(unique(plot_umap$Cluster)), ")"),
       x = "",
       y = "")
dev.off()

pdf("/PHShome/mom41/Clustering/plots_paper/clusterset.pdf", width = 10)
createClusterSetProp(dat_clust, id_set_match)
dev.off()

pdf("/PHShome/mom41/Clustering/plots_paper/clustersetflip.pdf", width = 10)
createClusterSetProp(dat_clust, id_set_match, flip = T)
dev.off()

pdf("/PHShome/mom41/Clustering/plots_paper/phespecs_filtered.pdf", width = 10)
invisible(createPheSpec_multi(N = 12, Clusters = c("15", "74", "63", "30", "65", "69", "70", "91", "103"), Dat = dat_clust, EM = dat_em, Sets = id_set_match, BG = dat_bg, Tsne = dat_tsne, Filter = names(excl_codes), Top = top10))
dev.off()

pdf("/PHShome/mom41/Clustering/plots_paper/prevrank.pdf", width = 10)
createPrevalenceVolcano("339", EM = dat_em, BG = dat_bg, UC = dat_uc)
dev.off()

pdf("/PHShome/mom41/Clustering/plots_paper/peaks.pdf", width = 10)
calculateCodePeaks(dat_clust, 30, filter_codes = names(excl_codes))
dev.off()

pdf("/PHShome/mom41/Clustering/plots_paper/lisi.pdf", width = 10)
ggplot(plot_lisi_raw, aes(x = X, y = Y, colour = Set)) +
	geom_point(size = 1) +
	theme_classic() +
	scale_colour_viridis(option = "magma",
                       limits = c(1,12)) +
	labs(title = "Set LISI pre-Harmony",
		 x = "",
		 y = "")
		 
ggplot(plot_lisi, aes(x = X, y = Y, colour = Set)) +
	geom_point(size = 1) +
	theme_classic() +
	scale_colour_viridis(option = "magma",
                       limits = c(1,12)) +
	labs(title = "Set LISI post-Harmony",
		 x = "",
		 y = "")
      
ggplot(hist_lisi, aes(x = LISI, colour = Stage)) +
  geom_density(size = 1.5) +
  scale_colour_manual(values = c("purple4",
                                 "orangered3"),
                      name = "Stage",
                      labels = c("Post-Harmony",
                                 "Pre-Harmony")) +
  theme_classic() +
  theme(text = element_text(face = "bold",
                              size = 15,
                              colour = "black"),
          line = element_line(colour = "black"),
          axis.text = element_text(colour = "black")) +
  labs(title = "LISI density pre- and post-Harmony",
       x = "LISI",
       y = "Density")
dev.off()
    
#pdf("/PHShome/mom41/Clustering/plots_paper/sub.pdf", width = 10)
#visualiseSubClustering(dat_tsne, subkey, full = T)
#visualiseSubClustering(dat_tsne, subkey)

#invisible(createPheSpec_multi(N = length(levels(dat_sub$Cluster)), Clusters = levels(dat_sub$Cluster), Dat = dat_sub, EM = dat_sub_em, Sets = id_set_match, BG = dat_sub_bg, Tsne = dat_tsne, Top = SubEN))
#dev.off()

pdf("/PHShome/mom41/Clustering/plots_paper/sub_filtered.pdf", width = 10)
visualiseSubClustering(dat_tsne, subkey, full = T)
visualiseSubClustering(dat_tsne, subkey)

invisible(createPheSpec_multi(N = length(levels(dat_sub$Cluster)), Clusters = levels(dat_sub$Cluster), Dat = dat_sub, EM = dat_sub_em, Sets = id_set_match, BG = dat_sub_bg, Tsne = dat_tsne, Filter = names(excl_codes), Top = SubEN))
dev.off()

pdf("/PHShome/mom41/Clustering/plots_paper/phespecs_all.pdf", width = 10)
invisible(createPheSpec_multi(N = length(levels(dat_clust$Cluster)), Clusters = levels(dat_clust$Cluster), Dat = dat_clust, EM = dat_em, Sets = id_set_match, BG = dat_bg, Tsne = dat_tsne, Filter = names(excl_codes), Top = top10, redpos = T))
dev.off()


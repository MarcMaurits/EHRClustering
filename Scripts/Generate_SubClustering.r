.libPaths("/PHShome/mom41/R/x86_64-pc-linux-gnu-library/3.6/")
library(ggplot2)
library(Rphenograph)
library(gridExtra)
library(ggrepel)
library(grid)
library(reshape2)
library(viridis)
library(dplyr)

source("Functions.R")

load("/PHShome/mom41/Clustering/dat_harm.RData")
load("/PHShome/mom41/Clustering/dat_clust.RData")
load("/PHShome/mom41/Clustering/dat_tsne.RData")
load("/PHShome/mom41/Clustering/id_set_match.RData")
load("/PHShome/mom41/Clustering/phecodes_complete.RData")

subkey <- createSubClustering(dat_clust, 63, dat_harm, type = "kmeans", k = 3)

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

pdf(file = "/PHShome/mom41/Clustering/subclustering_63_kmeans_3.pdf", width = 10)

visualiseSubClustering(dat_tsne, subkey, full = T)
visualiseSubClustering(dat_tsne, subkey)

invisible(createPheSpec_multi(N = length(levels(dat_sub$Cluster)), Clusters = levels(dat_sub$Cluster), Dat = dat_sub, EM = dat_sub_em, Sets = id_set_match, BG = dat_sub_bg, Tsne = dat_tsne))

dev.off()
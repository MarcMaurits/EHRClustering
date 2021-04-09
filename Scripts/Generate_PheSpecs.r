.libPaths("/PHShome/mom41/R/x86_64-pc-linux-gnu-library/3.6/")
library(ggplot2)
library(gridExtra)
library(ggrepel)
library(grid)
library(reshape2)
library(viridis)
library(dplyr)
library(png)

load("/PHShome/mom41/Clustering/top10_EN.RData")

source("Functions.R")

load("/PHShome/mom41/Clustering/phecodes_complete.RData")

dat <- get(load("/PHShome/mom41/Clustering/dat_clust.RData"))

load("id_set_match.RData")
load("dat_tsne.RData")

dat$PheCode <- as.factor(dat$PheCode)
dat$Cluster <- as.factor(dat$Cluster)

if(file.exists("dat_uc.RData")){
  load("dat_uc.RData")
} else {
  dat_uc <- unique(dat[,c("ID", "PheCode", "Cluster")])
  save(dat_uc, file = "dat_uc.RData")
}

if(file.exists("dat_em.RData")){
 load("dat_em.RData")
} else {
  dat_em <- lapply(unique(id_set_match$Set), function(x){
    lapply(unique(dat$Cluster), function(y){
      tmp <- dat_uc[dat_uc$Cluster == y,]
      tmp <- tmp[tmp$ID %in% id_set_match[id_set_match$Set == x, "ID"],]
      table(tmp$PheCode)/length(unique(tmp$ID))
    })
  })
  names(dat_em) <- unique(id_set_match$Set)
  invisible(lapply(1:length(dat_em), function(x){
    names(dat_em[[x]]) <<- unique(dat$Cluster) 
  })
  )
  save(dat_em, file = "dat_em.RData")
}

if(file.exists("dat_bg.RData")){
  load("dat_bg.RData")
} else {
  dat_bg <- unique(dat_uc[,c("ID", "PheCode")])
  dat_bg <- table(dat_bg$PheCode)/length(unique(dat_bg$ID))
  save(dat_bg, file = "dat_bg.RData")
}

#Try a visual filtering
Top = 10

dat_excl <- lapply(levels(dat$Cluster), function(x){
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

excl_codes <- excl_codes[excl_codes >= length(levels(dat$Cluster))*(1-((Top - 1)/Top))]

pdf(file = paste0("/PHShome/mom41/Clustering/", format(Sys.Date(), "%Y%m%d"), "_phespecs.pdf"), width = 10)
invisible(createPheSpec_multi(N = length(levels(dat$Cluster)), Clusters = levels(dat$Cluster), Dat = dat, EM = dat_em, Sets = id_set_match, BG = dat_bg, Tsne = dat_tsne))
dev.off()


pdf(file = paste0("/PHShome/mom41/Clustering/development_phespec.pdf"), width = 10)
invisible(createPheSpec_multi(N = 1, Clusters = 74, Dat = dat, EM = dat_em, Sets = id_set_match, Tsne = dat_tsne, BG = dat_bg, Filter = names(excl_codes), Tops = top10))
dev.off()

pdf(file = paste0("/PHShome/mom41/Clustering/", "headache_prevrank_phespecs.pdf"), width = 10, useDingbats = F)
invisible(createPheSpec_multi(N = 10, Clusters = c("30", "65", "69", "70", "91", "103"), Dat = dat, EM = dat_em, Sets = id_set_match, BG = dat_bg, Tsne = dat_tsne))
dev.off()

#png version
invisible(createPheSpec_png(N = 1, Clusters = 20, Dat = dat, EM = dat_em, Sets = id_set_match, Tsne = dat_tsne, BG = dat_bg, Name = "TST"))

invisible(createPheSpec_png(N = length(levels(dat$Cluster)), Clusters = levels(dat$Cluster), Dat = dat, EM = dat_em, Sets = id_set_match, BG = dat_bg, Tsne = dat_tsne, Name = "png_phespecs"))

#Test
pdf(file = paste0("/PHShome/mom41/Clustering/TEST.pdf"), width = 10)
invisible(createPheSpec_multi(N = 1, Clusters = 20, Dat = dat, EM = dat_em, Sets = id_set_match, Tsne = dat_tsne, BG = dat_bg))
dev.off()


#Filtered EN_Top version
pdf(file = "/PHShome/mom41/Clustering/phespecs_filtered_entops.pdf", width = 10)
invisible(createPheSpec_multi(N = length(levels(dat$Cluster)), Clusters = levels(dat$Cluster), Dat = dat, EM = dat_em, Sets = id_set_match, Tsne = dat_tsne, BG = dat_bg, Filter = names(excl_codes), Tops = top10))
dev.off()

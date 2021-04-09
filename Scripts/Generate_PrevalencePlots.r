.libPaths("/PHShome/mom41/R/x86_64-pc-linux-gnu-library/3.6/")
library(ggplot2)
library(ggrepel)

source("Functions.R")

load("/PHShome/mom41/Clustering/dat_em.RData")
load("/PHShome/mom41/Clustering/dat_bg.RData")
load("/PHShome/mom41/Clustering/set_cols.RData")
load("/PHShome/mom41/Clustering/dat_uc.RData")

pdf("headache_prevalence.pdf", width = 10)

createPrevalenceVolcano("339", EM = dat_em, BG = dat_bg, UC = dat_uc)

lapply(names(dat_em), function(x){
  createPrevalenceVolcano("339", EM = dat_em, Set = x, BG = dat_bg)
})

dev.off()

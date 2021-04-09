.libPaths("/PHShome/mom41/R/x86_64-pc-linux-gnu-library/3.6/")
library(ggplot2)
library(reshape2)
library(grid)
library(gridExtra)
library(viridis)

source("/PHShome/mom41/Clustering/Functions.R")

load("/PHShome/mom41/Clustering/dat_clust.RData")
load("/PHShome/mom41/Clustering/id_set_match.RData")
load("/PHShome/mom41/Clustering/phecodes_complete.RData")
load("/PHShome/mom41/Clustering/dat_uc.RData")

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

#calculateCodePeaks(dat_clust, 20, "Marshfield", id_set_match)


#pdf(file = "headache_peaks.pdf", width = 10)
#calculateCodePeaks(dat_clust, 30)
#calculateCodePeaks(dat_clust, 65)
#calculateCodePeaks(dat_clust, 69)
#calculateCodePeaks(dat_clust, 70)
#calculateCodePeaks(dat_clust, 91)
#calculateCodePeaks(dat_clust, 103)
#dev.off()

pdf(file = "/PHShome/mom41/Clustering/peaks.pdf", width = 10)
lapply(levels(dat_clust$Cluster), function(x){
  calculateCodePeaks(dat_clust, x, filter_codes = names(excl_codes))
})
dev.off()

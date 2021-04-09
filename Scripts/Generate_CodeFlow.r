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

p1 <- calculateCodeFlow(dat_clust, 20, "Marshfield", id_set_match)
p2 <- calculateCodeFlow(dat_clust, 20, "Marshfield", id_set_match, singles = T)

p1
p1 + facet_wrap(~Phenotype) + theme(legend.position = "none")

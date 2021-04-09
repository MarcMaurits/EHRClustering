#library
.libPaths("/PHShome/mom41/R/x86_64-pc-linux-gnu-library/3.6/")

source("/PHShome/mom41/Clustering/Functions.R")

#data
load("/PHShome/mom41/Clustering/dat_clust.RData")
load("/PHShome/mom41/Clustering/id_set_match.RData")

clusterset <- createClusterSetProp(dat_clust, id_set_match, flip = F)

setcluster <- createClusterSetProp(dat_clust, id_set_match, flip = F)
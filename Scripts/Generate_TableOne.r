.libPaths("/PHShome/mom41/R/x86_64-pc-linux-gnu-library/3.6/")

source("/PHShome/mom41/Clustering/Functions.R")

load("/PHShome/mom41/Clustering/dat.RData")
load("/PHShome/mom41/Clustering/id_set_match.RData")

dat_dem <- read.csv("/PHShome/mom41/EMERGE_201907_DEMO_GWAS_3.csv")

dat_table <- createTableOne(dat, dat_dem, id_set_match)

.libPaths("/PHShome/mom41/R/x86_64-pc-linux-gnu-library/3.6/")
library(ggplot2)
library(ggnetwork)
library(network)
library(sna)

source("/PHShome/mom41/Clustering/Functions.R")

load("/PHShome/mom41/Clustering/dat_clust.RData")
load("/PHShome/mom41/Clustering/id_set_match.RData")


n <- tstFunction(dat_clust, 20, "Marshfield", id_set_match, plot=F)

n <- network(n, matrix.type = "edgelist", ignore.eval = F) 

ggplot(ggnetwork(n, layout = "fruchtermanreingold"), aes(x = x, y = y, xend = xend, yend = yend)) +
  geom_edges(color = "grey50") +
  geom_nodes(color = "purple4") +
  geom_edgetext(aes(label = round(Prb, 2)), col = "black") +
  geom_nodetext(aes(label = vertex.names)) +
  theme_blank()

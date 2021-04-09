#library
.libPaths("/PHShome/mom41/R/x86_64-pc-linux-gnu-library/3.6/")
library(ggnetwork)
library(network)
library(ggplot2)

#data
#load("cor_dif_filtered.RData")
#load("dat_clust.RData")
load("phecodes_complete.RData")
#load("/PHShome/mom41/Clustering/dat_uc.RData")

#construct
#if(file.exists("/PHShome/mom41/Clustering/top10s.RData")){
#  load("/PHShome/mom41/Clustering/top10s.RData")
#} else {
#  load("dat_clust.RData")
#  dat_clust$PheCode <- as.factor(dat_clust$PheCode)

#  Top = 10

#  dat_excl <- lapply(levels(dat_clust$Cluster), function(x){
#    tmp <- dat_uc[dat_uc$Cluster == x,]
#    table(tmp$PheCode)/length(unique(tmp$ID))
#  })

#  dat_excl <- lapply(1:length(dat_excl), function(x){
#    dat_excl[[x]][order(dat_excl[[x]], decreasing = T)][1:Top]
#  })

#  dat_excl <- lapply(1:length(dat_excl), function(x){
#    data.frame(Code = names(dat_excl[[x]]),
#               Weight = 1 - (1/length(dat_excl[[x]]))*(0:(length(dat_excl[[x]]) - 1)))
#  })

#  dat_excl <- do.call("rbind", dat_excl)

#  excl_codes <- sapply(unique(dat_excl$Code), function(x){
#    sum(dat_excl[dat_excl$Code == x, "Weight"])
#  })

#  names(excl_codes) <- unique(dat_excl$Code)

#  excl_codes <- excl_codes[excl_codes >= length(levels(dat_clust$Cluster))*(1-((Top - 1)/Top))]

#  tops <- lapply(levels(dat_clust$Cluster), function(x){
#    tmp <- dat_clust[dat_clust$Cluster == x,]
#    size <- length(unique(tmp$ID))
#    tmp_u <- unique(tmp[,c("ID", "PheCode")])
#    res <- table(tmp_u$PheCode)/size
#    res <- res[order(res, decreasing = T)]
#    res <- res[!names(res) %in% names(excl_codes)]
#    names(res[1:10])
#  })
#  names(tops) <- levels(dat_clust$Cluster)

#  save(tops, file = "/PHShome/mom41/Clustering/top10s.RData")
#}

#dat_net_prep <- lapply(cor_dif_filtered, function(x) x[x$value >= quantile(x$value, 0.95),])

#dat_net_prep <- lapply(dat_net_prep, function(x) x[!x$value == 0,])

#dat_net <- lapply(seq_along(dat_net_prep), function(x){
#  z <- dat_net_prep[[x]]
#  if(nrow(z) == 0){
#   return(NA)
#  } else {
#    z[,1] <- as.character(z[,1])
#    z[,2] <- as.character(z[,2])
#    tmp <- unique(c(z[,1], z[,2]))
#    nodes <- seq_along(tmp)
#    names(nodes) <- tmp
#    w <- z$value
#    z$Node1 <- as.vector(nodes[z[,1]])
#    z$Node2 <- as.vector(nodes[z[,2]])
#    z <- network(z[,c("Node1", "Node2")], directed = F)
#    set.edge.attribute(z, "Weight", w)
#    z <- ggnetwork(z)
#    z$PheCode <- names(nodes)[z$vertex.names]
#    z$Top <- z$PheCode %in% tops[[x]]
#    z <- merge(z, phecodes_complete[,c("PheCode", "Phenotype")], by = "PheCode")
#    z <- z[!duplicated(z),]
#    return(z)
#  }
#})

#names(dat_net) <- names(dat_net_prep)

#save(dat_net, file = "/PHShome/mom41/Clustering/dat_net.RData")


#pdf(file = "/PHShome/mom41/Clustering/networks.pdf", width = 10)
#lapply(seq_along(dat_net), function(x){
#if(is.na(dat_net[[x]])){
#  return(NA)
#} else {

#col_man <- c("purple4", "orangered3")
#names(col_man) <- c("TRUE", "FALSE")
#lab_man <- c("True", "False")
#names(lab_man) <- c("TRUE", "FALSE")

#ggplot(dat_net[[x]], aes(x = x, y = y, xend = xend, yend = yend)) +
#  geom_edges(linetype = "solid", 
#             color = "grey50",
#             aes(size = Weight)) +
#  geom_nodes(aes(color = Top), 
#             size = 5) +
#  theme_blank() +
#  guides(size = guide_legend(title = "Correlation Increase")) +
#  scale_colour_manual(values = col_man,
#                      name = "Within top 10",
#                      labels = lab_man) +
#  geom_nodelabel_repel(aes(label = Phenotype),
#                       box.padding = unit(1, "lines"),
#                       data = function(y){ y[y$Top == TRUE,]}) +
#  labs(title = paste0("Network of Cluster ", names(dat_net)[x]))
#}
#})
#dev.off()


#other approach
load("cor_plot.RData")

cor_plot_fil <- lapply(cor_plot, function(x) x[!sapply(1:nrow(x), function(y) any(duplicated(strsplit(as.character(x[y,1]), "_")[[1]]))),])
cor_plot_fil <- lapply(cor_plot_fil, function(x) x[x$Cor_cl >= quantile(x$Cor_cl, 0.95, na.rm = T),])
cor_plot_fil <- lapply(cor_plot_fil, function(x) x[complete.cases(x),])

save(cor_plot_fil, file = "/PHShome/mom41/Clustering/cor_plot_fil.RData")

load("/PHShome/mom41/Clustering/cor_plot_fil.RData")
load("/PHShome/mom41/Clustering/top10_EN.RData")

dat_net_cl <- lapply(seq_along(cor_plot_fil), function(x){
  z <- cor_plot_fil[[x]]
  if(nrow(z) == 0){
   return(NA)
  } else {
    z$Node1 <- sapply(strsplit(as.character(z[,1]), "_"), `[`, 1)
    z$Node2 <- sapply(strsplit(as.character(z[,1]), "_"), `[`, 2)
    tmp <- unique(c(z$Node1, z$Node2))
    if(length(tmp) <= 2){
     return(NA)
    } else {
      nodes <- seq_along(tmp)
      names(nodes) <- tmp
      w <- z$Cor_cl
      z <- network(z[,c("Node1", "Node2")], directed = F)
      set.edge.attribute(z, "Weight", w)
      z <- ggnetwork(z)
      z$PheCode <- names(nodes)[z$vertex.names]
      z$Top <- z$PheCode %in% top10[[x]][,1]
      z <- merge(z, phecodes_complete[,c("PheCode", "Phenotype")], by = "PheCode")
      z <- z[!duplicated(z),]
      return(z)
    }
  }
})

names(dat_net_cl) <- names(cor_plot_fil)

save(dat_net_cl, file = "/PHShome/mom41/Clustering/dat_net_cl.RData")

pdf(file = "/PHShome/mom41/Clustering/networks_EN.pdf", width = 10)
lapply(seq_along(dat_net_cl), function(x){
if(is.na(dat_net_cl[[x]])){
  return(NA)
} else {

col_man <- c("purple4", "orangered3")
names(col_man) <- c("TRUE", "FALSE")
lab_man <- c("True", "False")
names(lab_man) <- c("TRUE", "FALSE")

ggplot(dat_net_cl[[x]], aes(x = x, y = y, xend = xend, yend = yend)) +
  geom_edges(linetype = "solid", 
             color = "grey50",
             aes(size = Weight)) +
  geom_nodes(aes(color = Top), 
             size = 5) +
  theme_blank() +
  guides(size = guide_legend(title = "Correlation Increase")) +
  scale_colour_manual(values = col_man,
                      name = "Within top 10",
                      labels = lab_man) +
  geom_nodelabel_repel(aes(label = Phenotype),
                       box.padding = unit(1, "lines"),
                       data = function(y){ y[y$Top == TRUE,]}) +
  labs(title = paste0("Network of Cluster ", names(dat_net_cl)[x]))
}
})
dev.off()

#just one

#testnet <- cor_plot[["70"]]
#testnet$Code1 <- gsub("_.*", "", testnet$Pair)
#testnet$Code2 <- gsub(".*_", "", testnet$Pair)

#testnet <- testnet[testnet$Cor_cl >= 0.6,]
#testnet <- testnet[complete.cases(testnet),]
#testnet <- testnet[!testnet$Code1 == testnet$Code2,]

#tmp <- unique(c(testnet$Code1, testnet$Code2))
#nodes <- seq_along(tmp)
#names(nodes) <- tmp
#w <- testnet$Cor_cl
#z <- network(testnet[,c("Code1", "Code2")], directed = F)
#set.edge.attribute(z, "Weight", w)
#z <- ggnetwork(z)
#z$PheCode <- names(nodes)[z$vertex.names]

#z$Top <- z$PheCode %in% tops[["70"]]

#z <- merge(z, phecodes_complete[,c("PheCode", "Phenotype")], by = "PheCode")
#z <- z[!duplicated(z),]

#col_man <- c("purple4", "orangered3")
#names(col_man) <- c("TRUE", "FALSE")
#lab_man <- c("True", "False")
#names(lab_man) <- c("TRUE", "FALSE")

#ggplot(z, aes(x = x, y = y, xend = xend, yend = yend)) +
#  geom_edges(linetype = "solid", 
#             color = "grey50",
#             aes(size = Weight)) +
#  geom_nodes(aes(color = Top), 
#             size = 5) +
#  theme_blank() +
#  guides(size = guide_legend(title = "Correlation Increase")) +
#  scale_colour_manual(values = col_man,
#                      name = "Within top 10",
#                      labels = lab_man) +
#  geom_nodelabel_repel(aes(label = Phenotype),
#                       box.padding = unit(1, "lines"),
#                       data = function(y){ y[y$Top == TRUE,]}) +
#  labs(title = "Network of test cluster")

.libPaths("/PHShome/mom41/R/x86_64-pc-linux-gnu-library/3.6/")
library(ggplot2)
library(ggrepel)

source("Scripts/Functions.R")

load("/PHShome/mom41/Clustering/R_saves/dat_em.RData")
load("/PHShome/mom41/Clustering/R_saves/dat_bg.RData")
load("/PHShome/mom41/Clustering/R_saves/set_cols.RData")
load("/PHShome/mom41/Clustering/R_saves/dat_uc.RData")
load("/PHShome/mom41/Clustering/R_saves/dat_clust.RData")

tops <- lapply(levels(dat_clust$Cluster), function(x){
    tmp <- dat_clust[dat_clust$Cluster == x,]
    size <- length(unique(tmp$ID))
    tmp_u <- unique(tmp[,c("ID", "PheCode")])
    res <- table(tmp_u$PheCode)/size
    res <- res[order(res, decreasing = T)]
    names(res[1:10])
})

tops <- unique(unlist(tops))

pr_sum <- lapply(tops, function(x){
  extractPRClusters(x, EM = dat_em, BG = dat_bg, UC = dat_uc)
})
names(pr_sum) <- tops

save(pr_sum, file = "/PHShome/mom41/Clustering/R_saves/pr_sum.RData")

pr_counts <- sapply(pr_sum, length)
pr_counts <- data.frame(Code = names(pr_counts), Count = pr_counts)

ggplot(pr_counts, aes(x = Count)) +
  geom_bar(fill = "purple4") +
  theme_classic() +
  scale_x_continuous(breaks = seq(
  labs(title = "Number of Clusters Overexpressing a Code",
       x = "Number of Clusters",
       y = "Number of Codes")
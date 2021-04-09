#library
.libPaths("/PHShome/mom41/R/x86_64-pc-linux-gnu-library/3.6/")
library(reshape2)

#data
load("dat.RData")
load("dat_clust.RData")

#construct m
dat$PheCode <- as.factor(dat$PheCode)
spl <- split(dat$PheCode, as.factor(dat$ID))

m <- sapply(spl, function(x){
  table(x)
})

m <- t(m)

#background correlation
if(file.exists("dat_cor_bg.RData")){
 load("dat_cor_bg.RData")
} else {
dat_cor_bg <- cor(m)
save(dat_cor_bg, file = "/PHShome/mom41/Clustering/dat_cor_bg.RData")
}

#per cluster correlation
dat_clust$PheCode <- as.factor(dat_clust$PheCode)

dat_cor <- lapply(levels(dat_clust$Cluster), function(x){
  tmp <- dat_clust[dat_clust$Cluster == x, ]
  
  spl <- split(tmp$PheCode, as.factor(tmp$ID))

  m <- sapply(spl, function(x){
    table(x)
  })

  m <- t(m)

  cor(m)
})

save(dat_cor, file = "/PHShome/mom41/Clustering/dat_cor.RData")

#transform
cor_dif <- lapply(dat_cor, function(x){
  tmp <- x - dat_cor_bg
  tmp[lower.tri(tmp)] <- NA
  melt(tmp, na.rm = T)
})

save(cor_dif, file = "/PHShome/mom41/Clustering/cor_dif.RData")

#filter
bg_filter <- split(dat_clust$ID, as.factor(dat_clust$PheCode))
bg_filter <- lapply(bg_filter, unique)
bg_filter <- lapply(bg_filter, length)
bg_filter_rm <- names(bg_filter)[which(bg_filter < 100)]

cl_filter_rm <- lapply(levels(dat_clust$Cluster), function(x){
  tmp <- dat_clust[dat_clust$Cluster == x,]
  cl_filter <- split(tmp$ID, as.factor(tmp$PheCode))
  cl_filter <- lapply(cl_filter, unique)
  cl_filter <- lapply(cl_filter, length)
  return(names(cl_filter)[which(cl_filter < 100)])
})
names(cl_filter_rm) <- levels(dat_clust$Cluster)

cor_dif_filtered <- lapply(names(cor_dif), function(x){
  tmp <- cor_dif[[x]]
  tmp <- tmp[-which(tmp[,1] %in% c(cl_filter_rm[[x]], bg_filter_rm)),]
  tmp <- tmp[-which(tmp[,2] %in% c(cl_filter_rm[[x]], bg_filter_rm)),]
  return(tmp)
})

save(cor_dif_filtered, file = "/PHShome/mom41/Clustering/cor_dif_filtered.RData") 

#labelling
cor_dif_lab <- lapply(cor_dif_filtered, function(x){
  tmp <- x[order(x$value, decreasing = T),][1:10,]
  tmp <- merge(tmp, phecodes_complete[,c("PheCode","Phenotype")], by.x = 1, by.y = "PheCode")
  colnames(tmp) <- c("Code_1", "Code_2", "CorDif", "Pheno_1")
  tmp <- tmp[!duplicated(tmp),]
  tmp <- merge(tmp, phecodes_complete[,c("PheCode","Phenotype")], by.x = "Code_2", by.y = "PheCode")
  colnames(tmp)[ncol(tmp)] <- "Pheno_2"
  tmp <- tmp[!duplicated(tmp),]
  tmp[order(tmp$CorDif, decreasing = T), c("Pheno_1", "Pheno_2", "CorDif", "Code_1", "Code_2")]
})

lapply(seq_along(cor_dif_lab), function(x){
  write.table(names(cor_dif_lab)[x], "cor_dif_lab.csv", append = T, sep = ",", row.names = F)
  write.table(cor_dif_lab[[x]], "cor_dif_lab.csv", append = T, sep = ",", row.names = F)
})

#scatter plot correlation bg vs correlation cluster
dat_cor_bg <- melt(dat_cor_bg)

bg_pair <- data.frame(Pair = paste0(dat_cor_bg[,1], "_", dat_cor_bg[,2]), Cor_bg = dat_cor_bg[,3])

dat_cor_filtered <- lapply(names(dat_cor), function(x){
  tmp <- melt(dat_cor[[x]]
  tmp <- tmp[-which(tmp[,1] %in% c(cl_filter_rm[[x]], bg_filter_rm)),]
  tmp <- tmp[-which(tmp[,2] %in% c(cl_filter_rm[[x]], bg_filter_rm)),]
  return(tmp)
})

cor_plot <- lapply(dat_cor_filtered, function(x){
  if(nrow(x) == 0){
    return(NA)
  } else {
    tmp <- data.frame(Pair = paste0(x[,1], "_", x[,2]), Cor_cl = x[,3])
    merge(tmp, bg_pair, by = "Pair")
  }
})
names(cor_plot) <- names(dat_cor)

save(cor_plot, file = "/PHShome/mom41/Clustering/cor_plot.RData")

pdf("/PHShome/mom41/Clustering/cor_plot.pdf", width = 10)
lapply(names(cor_plot), function(x){
ggplot(cor_plot[[x]], aes(x = Cor_bg, y = Cor_cl, colour = Cor_cl - Cor_bg)) +
  geom_point() +
  theme_classic() +
  labs(title = paste0("Correlation volcano plot cluster ", x),
       x = "Correlation Background",
       y = "Correlation Cluster")
})
dev.off()


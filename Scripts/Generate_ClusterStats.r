.libPaths("/PHShome/mom41/R/x86_64-pc-linux-gnu-library/3.6/")

source("/PHShome/mom41/Clustering/Functions.R")

load("/PHShome/mom41/Clustering/dat_clust.RData")
load("/PHShome/mom41/Clustering/dat_em.RData")
load("/PHShome/mom41/Clustering/id_set_match.RData")

dat_clust$PheCode <- as.factor(dat_clust$PheCode)

cluster_stats <- lapply(levels(dat_clust$Cluster), function(x){
    Sub <- dat_clust[dat_clust$Cluster == x,]
    
    Size <- length(unique(Sub$ID))
    
    Sizes <- table(id_set_match[id_set_match$ID %in% Sub$ID, "Set"])
    
    Sub_u <- unique(Sub[,c("ID", "PheCode")])
    
    Comp <- table(Sub_u$PheCode)/Size
    
    Sets <- sapply(dat_em, `[`, as.character(x))
    names(Sets) <- gsub("\\..*", "", names(Sets))
    CorMain <- sapply(1:length(Sets), function(y){
      cor(Comp, Sets[[y]])
    })
    names(CorMain) <- names(Sets)
    
    res <- round(c(Size, Sizes, Sizes/Size, CorMain),2)
    
    names(res) <- c("Size", names(Sizes), paste0("Prop. ", names(Sizes)), paste0("Cor. ", names(CorMain)))
    
    return(res)

})

names(cluster_stats) <- levels(dat_clust$Cluster)

save(cluster_stats, file = "/PHShome/mom41/Clustering/cluster_stats.RData")

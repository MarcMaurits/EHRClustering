#Library
.libPaths("/PHShome/mom41/R/x86_64-pc-linux-gnu-library/3.6/")
library(ggplot2)

#Data
load("/PHShome/mom41/RA_Clustering/ra_status.RData")
load("/PHShome/mom41/Clustering/dat_clust.RData")
load("/PHShome/mom41/Clustering/dat_tsne.RData")

#Crude labelling
ra_code_ids <- dat_clust[dat_clust$PheCode %in% c("714.1"), "ID"]
ra_code_ids <- unique(ra_code_ids)

#Visualise
colourset <- c("grey", "purple4")

my_pch ="."

plot_tsne <- data.frame(X = dat_tsne$Y[,1],
                        Y = dat_tsne$Y[,2],
                        ID = rownames(dat_tsne$Y)) 

plot_tsne <- merge(plot_tsne, ra_status, by = "ID")
colnames(plot_tsne)[ncol(plot_tsne)] <- "RA"

plot_tsne$RA_dich <- as.factor(ifelse(plot_tsne$RA == "Case", 1, 0))

levels(plot_tsne$RA_dich) <- c(1,0)
plot_tsne <- plot_tsne[order(plot_tsne$RA_dich),]

plot_tsne$RA_crude <- plot_tsne$ID %in% ra_code_ids

#TSNE
ggplot(plot_tsne, aes(x = X, y = Y, colour = RA_dich)) +
  geom_point(pch = 20,
             size = 1) + 
  theme_classic() +
  scale_colour_manual(values = colourset) +
  labs(title = "tSNE embedding",
       subtitle = "Labelled RA cases",
       x = "",
       y = "")

ggplot(plot_tsne, aes(x = X, y = Y, colour = RA_crude)) +
  geom_point(pch = 20,
             size = 1) + 
  theme_classic() +
  scale_colour_manual(values = colourset) +
  labs(title = "tSNE embedding",
       subtitle = "Crude RA cases",
       x = "",
       y = "")

#Distribution
calcEnrich <- function(dat, cl, pats){
  ids_in <- unique(dat[dat$Cluster == cl, "ID"])
  ids_out <- unique(dat[!dat$Cluster == cl, "ID"])
  
  ids_in_y <- length(intersect(ids_in, pats))
  ids_in_n <- length(setdiff(ids_in, pats))
  ids_out_y <- length(intersect(ids_out, pats))
  ids_out_n <- length(setdiff(ids_out, pats))
  
  mat <- matrix(c(ids_in_y, ids_out_y, ids_in_n, ids_out_n), byrow = T, ncol = 2, nrow = 2)
  colnames(mat) <- c("InCluster", "OutsideCluster")
  rownames(mat) <- c("Case", "NonCase")
  
  print(mat)
  print(round(prop.table(mat,2),2))
  
  fisher.test(mat)
}

dat_ra_enr <- lapply(levels(dat_clust$Cluster), function(x){
  calcEnrich(dat_clust, x, ra_status[ra_status$Status == "Case", "ID"])
})
names(dat_ra_enr) <- levels(dat_clust$Cluster)

cl_enr <- sapply(seq_along(dat_ra_enr), function(x){
  dat_ra_enr[[x]]$p.value < 0.05
})
names(cl_enr) <- names(dat_ra_enr)

cl_or <- sapply(seq_along(dat_ra_enr), function(x){
  dat_ra_enr[[x]]$estimate
})
names(cl_or) <- names(dat_ra_enr)

dat_centers <- extractCenters(dat_tsne, dat_clust)

ggplot(dat_centers, aes(x = X, y = Y, size = Size, colour = cl_enr & cl_or >= 1)) + 
  geom_point() + 
  scale_size(range = c(1,10)) +
  scale_colour_manual(values = c("grey",
                                 "purple4"),
                      name = "Enriched for cases",
                      labels = c("No",
                                 "Yes")) +
  theme_classic() +
  labs(title = "Clustered tSNE plot",
       subtitle = "RA Case Enrichment")
















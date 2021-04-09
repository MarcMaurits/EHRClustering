.libPaths("/PHShome/mom41/R/x86_64-pc-linux-gnu-library/3.6/")
library(Rtsne)
library(ggplot2)
library(viridis)
library(lisi)

load("/PHShome/mom41/Clustering/id_set_match.RData")
load("/PHShome/mom41/Clustering/dat_clust.RData")
load("/PHShome/mom41/Clustering/dat_tsne.RData")
load("/PHShome/mom41/Clustering/set_cols.RData")

#t-SNE raw
if(file.exists("/PHShome/mom41/Clustering/dat_tsne_raw.RData")){
  load("/PHShome/mom41/Clustering/dat_tsne_raw.RData")
} else {
  load("/PHShome/mom41/Clustering/dat.RData")
  #Creating matrix
  dat$PheCode <- as.factor(dat$PheCode)
  spl <- split(dat$PheCode, as.factor(dat$ID))

  m <- sapply(spl, function(x){
    table(x)
  })

  m <- t(m)
  dat_tsne_raw <- Rtsne(m, dims = 2, perplexity = 30, verbose = F, max_iter = 5000, check_duplicates = F, pca = F, num_threads = 0)

  rownames(dat_tsne_raw$Y) <- rownames(m)

  save(dat_tsne_raw, file = "/PHShome/mom41/Clustering/dat_tsne_raw.RData")
}

#Lisi raw
meta_data <- as.data.frame(dat_clust[!duplicated(dat_clust$ID), "Cluster"])
rownames(meta_data) <- dat_clust[!duplicated(dat_clust$ID), "ID"]
colnames(meta_data) <- "Cluster"
meta_data$Set <- id_set_match$Set
meta_data <- meta_data[complete.cases(meta_data),]

tsne_prep_raw <- dat_tsne_raw$Y[rownames(dat_tsne_raw$Y) %in% rownames(meta_data),]

dat_lisi_raw <- compute_lisi(tsne_prep_raw, meta_data, c("Cluster", "Set"))

plot_lisi_raw <- data.frame(X = tsne_prep_raw[,1], Y = tsne_prep_raw[,2], Cluster = dat_lisi_raw$Cluster, Set = dat_lisi_raw$Set)

plot_lisi_raw$SetLabels <- meta_data$Set
plot_lisi_raw[plot_lisi_raw$Set >= 2, "SetLabels"] <- "LISI >= 2"
plot_lisi_raw$SetLabels <- as.factor(plot_lisi_raw$SetLabels)
plot_lisi_raw$SetLabels <- relevel(plot_lisi_raw$SetLabels, "LISI >= 2")

#Lisi
tsne_prep <- dat_tsne$Y[rownames(dat_tsne$Y) %in% rownames(meta_data),]

dat_lisi <- compute_lisi(tsne_prep, meta_data, c("Cluster", "Set"))

plot_lisi <- data.frame(X = tsne_prep[,1], Y = tsne_prep[,2], Cluster = dat_lisi$Cluster, Set = dat_lisi$Set)

plot_lisi$SetLabels <- meta_data$Set
plot_lisi[plot_lisi$Set >= 2, "SetLabels"] <- "LISI >= 2"
plot_lisi$SetLabels <- as.factor(plot_lisi$SetLabels)
plot_lisi$SetLabels <- relevel(plot_lisi$SetLabels, "LISI >= 2")

hist_lisi <- data.frame(LISI = c(plot_lisi_raw$Set, plot_lisi$Set), Stage = rep(c("Pre", "Post"), times = c(nrow(plot_lisi_raw), nrow(plot_lisi)))


set_cols <- c(set_cols, "grey")
names(set_cols)[length(set_cols)] <- "LISI >= 2"

#Plot
pdf(file = "lisi_plots.pdf", width = 10)
ggplot(plot_lisi_raw, aes(x = X, y = Y, colour = Cluster)) +
	geom_point(size = 1) +
	theme_classic() +
	scale_colour_viridis(option = "magma") +
	labs(title = "Cluster LISI pre-Harmony",
		 x = "",
		 y = "")
		 
ggplot(plot_lisi_raw, aes(x = X, y = Y, colour = Set)) +
	geom_point(size = 1) +
	theme_classic() +
	scale_colour_viridis(option = "magma") +
	labs(title = "Set LISI pre-Harmony",
		 x = "",
		 y = "")
      
ggplot(plot_lisi_raw, aes(x = X, y = Y, colour = SetLabels)) +
	geom_point(size = 1) +
	theme_classic() +
	scale_colour_manual(values = set_cols) +
	labs(title = "Set LISI pre-Harmony",
     subtitle = "LISI < 2 ID's Highlighted",
		 x = "",
		 y = "")
      
ggplot(plot_lisi_raw, aes(x = X, y = Y, colour = meta_data$Set %in% c("Boston Children\'s", "Cincinnati Children\'s"))) +
  geom_point(size = 1) +
  theme_classic() +
  scale_colour_manual(name = "Hospital",
                      labels = c("Normal",
                                 "Children"),
                      values = c("grey",
                                 "purple4")) +
  labs(title = "Children Hospitals pre-Harmony",
       x = "",
       y = "")
      
ggplot(plot_lisi, aes(x = X, y = Y, colour = Cluster)) +
	geom_point(size = 1) +
	theme_classic() +
	scale_colour_viridis(option = "magma") +
	labs(title = "Cluster LISI post-Harmony",
		 x = "",
		 y = "")
		 
ggplot(plot_lisi, aes(x = X, y = Y, colour = Set)) +
	geom_point(size = 1) +
	theme_classic() +
	scale_colour_viridis(option = "magma") +
	labs(title = "Set LISI post-Harmony",
		 x = "",
		 y = "")
      
ggplot(plot_lisi, aes(x = X, y = Y, colour = SetLabels)) +
	geom_point(size = 1) +
	theme_classic() +
	scale_colour_manual(values = set_cols) +
	labs(title = "Set LISI post-Harmony",
     subtitle = "LISI < 2 ID's Highlighted",
		 x = "",
		 y = "")

ggplot(plot_lisi, aes(x = X, y = Y, colour = meta_data$Set %in% c("Boston Children\'s", "Cincinnati Children\'s"))) +
  geom_point(size = 1) +
  theme_classic() +
  scale_colour_manual(name = "Hospital",
                      labels = c("Normal",
                                 "Children"),
                      values = c("grey",
                                 "purple4")) +
  labs(title = "Children Hospitals post-Harmony",
       x = "",
       y = "")

ggplot(hist_lisi, aes(x = LISI, colour = Stage)) +
  geom_line() +
  scale_colour_manual(values = c("orangered3",
                                 "purple4"),
                      name = "Stage") +
  theme_classic() +
  theme(text = element_text(face = "bold",
                              size = 15,
                              colour = "black"),
          line = element_line(colour = "black"),
          axis.text = element_text(colour = "black")) +
  labs(title = "LISI density pre- and post-Harmony",
       x = "LISI",
       y = "Density")
      
dev.off()
#Library
.libPaths("/PHShome/mom41/R/x86_64-pc-linux-gnu-library/3.6/")
library(dplyr)
library(Rtsne)
library(umap)
library(harmony)
library(Rphenograph)
library(RColorBrewer)
library(ggplot2)
library(viridis)

#Data
dat <- read.csv("/PHShome/mom41/EMERGE_201907_PHECODE_GWAS_0.csv", header = T, stringsAsFactors = F)

dat <- dat %>%
  arrange(SUBJECT_ID, AGE_AT_OBSERVATION) %>%
  rename(ID = SUBJECT_ID, PheCode = PHECODE, Age = AGE_AT_OBSERVATION) %>%
  select(ID, PheCode, Age)

#Phecodes
#phecodes_icd9 <- read.csv("/PHShome/mom41/20200317_icd9_phecode.csv", stringsAsFactors = F)
#phecodes_icd10 <- read.csv("/PHShome/mom41/20200317_icd10_phecode.csv", stringsAsFactors = F)

#phecodes_icd10cm <- read.csv("/PHShome/mom41/20200317_icd10cm_phecode.csv", stringsAsFactors = F)

#phecodes_icd9 <- phecodes_icd9 %>%
#  select(ICD9, PheCode, Phenotype) %>%
#  rename(ICD = ICD9)
  
#phecodes_icd10 <- phecodes_icd10 %>%
#  select(ICD10, PheCode, Phenotype) %>%
#  rename(ICD = ICD10)
  
#phecodes_icd10cm <- phecodes_icd10cm %>%
#  select(icd10cm, phecode, phecode_str) %>%
#  filter(!icd10cm %in% phecodes_icd10$ICD) %>%
#  rename(ICD = icd10cm, PheCode = phecode, Phenotype = phecode_str)
  
#phecodes <- rbind(phecodes_icd9, phecodes_icd10, phecodes_icd10cm)

#phecodes <- phecodes[complete.cases(phecodes),]

#duplicate_icds <- phecodes[duplicated(phecodes$ICD), "ICD"]

#phecodes <- phecodes[!phecodes$ICD %in% duplicate_icds,]

#dat <- merge(dat, phecodes, by.x = "Code", by.y = "ICD")

save(dat, file = "/PHShome/mom41/Clustering/dat.RData")  

#Dataset mapping
id_set_match <- data.frame(ID = unique(dat$ID), 
                           Set = NA)

id_set_match[grep("^16", id_set_match$ID), "Set"] <- "Marshfield"
id_set_match[grep("^23", id_set_match$ID), "Set"] <- "Boston Childrens"
id_set_match[grep("^27", id_set_match$ID), "Set"] <- "Vanderbilt"
id_set_match[grep("^38", id_set_match$ID), "Set"] <- "Kaiser Permanente"
id_set_match[grep("^42", id_set_match$ID), "Set"] <- "Columbia"
id_set_match[grep("^49", id_set_match$ID), "Set"] <- "Mayo"
id_set_match[grep("^52", id_set_match$ID), "Set"] <- "Northwestern"
id_set_match[grep("^63", id_set_match$ID), "Set"] <- "Geisinger"
id_set_match[grep("^68", id_set_match$ID), "Set"] <- "Mass General Brigham"
id_set_match[grep("^74", id_set_match$ID), "Set"] <- "Mt Sinai"
id_set_match[grep("^81", id_set_match$ID), "Set"] <- "Cincinnati Childrens"
id_set_match[grep("^88", id_set_match$ID), "Set"] <- "Meharry"
id_set_match[grep("^95", id_set_match$ID), "Set"] <- "CHOP"

save(id_set_match, file = "id_set_match.RData")

#Creating matrix
dat$PheCode <- as.factor(dat$PheCode)
spl <- split(dat$PheCode, as.factor(dat$ID))

m <- sapply(spl, function(x){
  table(x)
})

m <- t(m)

#Harmony
dat_harm <- HarmonyMatrix(m, id_set_match$Set, do_pca = T, npcs = 500)
rownames(dat_harm) <- id_set_match$ID

save(dat_harm, file = "/PHShome/mom41/Clustering/dat_harm.RData")

#Phenograph
dat_graph <- Rphenograph(dat_harm)

save(dat_graph, file = "/PHShome/mom41/Clustering/dat_graph.RData")

graph_key <- cbind(rownames(dat_harm)[as.numeric(dat_graph[[2]]$name)], dat_graph[[2]]$membership)

save(graph_key, file = "/PHShome/mom41/Clustering/graph_key.RData")

#Clustering data
dat_clust <- merge(dat, graph_key, by.x = "ID", by.y = 1, all.x = T)

colnames(dat_clust)[4] <- "Cluster"

save(dat_clust, file = "/PHShome/mom41/Clustering/dat_clust.RData")

#Embedding
dat_tsne <- Rtsne(dat_harm, dims = 2, perplexity = 30, verbose = F, max_iter = 5000, check_duplicates = F, pca = F, num_threads = 0)

rownames(dat_tsne$Y) <- rownames(dat_harm)

save(dat_tsne, file = "/PHShome/mom41/Clustering/dat_tsne.RData")

dat_umap <- umap(dat_harm)

save(dat_umap, file = "/PHShome/mom41/Clustering/dat_umap.RData")

#Visualise
colourset <- colors(distinct = T)
colourset <- colourset[-grep("gray|white", colourset)]

my_pch ="."

plot_tsne <- data.frame(X = dat_tsne$Y[,1],
                        Y = dat_tsne$Y[,2],
                        ID = rownames(dat_tsne$Y)) 

plot_tsne <- merge(plot_tsne, graph_key, by.x = "ID", by.y = 1)
colnames(plot_tsne)[ncol(plot_tsne)] <- "Cluster"

plot_tsne <- merge(plot_tsne, id_set_match, by = "ID")

plot_tsne$Cluster <- as.factor(plot_tsne$Cluster)

plot_umap <- data.frame(X = dat_umap$layout[,1],
                        Y = dat_umap$layout[,2],
                        ID = rownames(dat_umap$layout))

plot_umap <- merge(plot_umap, graph_key, by.x = "ID", by.y = 1)
colnames(plot_umap)[ncol(plot_umap)] <- "Cluster"

plot_umap <- merge(plot_umap, id_set_match, by = "ID")

plot_umap$Cluster <- as.factor(plot_umap$Cluster)

pdf(file = "embedding_plots.pdf")
#TSNE
plot_tsne <- plot_tsne[sample.int(nrow(plot_tsne)),]

ggplot(plot_tsne, aes(x = X, y = Y, colour = Set)) +
  geom_point(pch = my_pch,
             size = 2) +
  theme_classic() +
  scale_colour_viridis(discrete = T) +
  labs(title = "tSNE embedding post-Harmony",
       subtitle = "Showing degree of Harmony",
       x = "",
       y = "")

ggplot(plot_tsne, aes(x = X, y = Y, colour = Cluster)) +
  geom_point(pch = my_pch,
             size = 2) +
  theme_classic() +
  scale_colour_manual(values = colourset) +
  theme(legend.position = "none") +
  labs(title = "tSNE embedding post-Harmony",
       subtitle = paste0("Showing kNN clustering (N = ", length(unique(plot_tsne$Cluster)), ")"),
       x = "",
       y = "")

#UMAP
plot_umap <- plot_umap[sample.int(nrow(plot_umap)),]

ggplot(plot_umap, aes(x = X, y = Y, colour = Set)) +
  geom_point(pch = my_pch,
             size = 2) +
  theme_classic() +
  scale_colour_viridis(discrete = T) +
  labs(title = "Umap embedding post-Harmony",
       subtitle = "Showing degree of Harmony",
       x = "",
       y = "")

ggplot(plot_umap, aes(x = X, y = Y, colour = Cluster)) +
  geom_point(pch = my_pch,
             size = 2) +
  theme_classic() +
  scale_colour_manual(values = colourset) +
  theme(legend.position = "none") +
  labs(title = "Umap embedding post-Harmony",
       subtitle = paste0("Showing kNN clustering (N = ", length(unique(plot_umap$Cluster)), ")"),
       x = "",
       y = "")
dev.off()

#Set proportions
props <- calculateClusterSetProp(dat_clust, id_set_match)

prop_counts <- sapply(1:nrow(props), function(x){
  sum(props[x,] >= 0.1)
})

#Correlations
cors <- sapply(levels(dat_clust$Cluster), function(x){
  calculateCorrelations(x, dat_clust, dat_em, id_set_match)
})

save(cors, file = "cors.RData")

med_cors <- apply(cors, 2, median, na.rm = T)
med_cors <- med_cors[order(med_cors, decreasing = T)]

min_cors <- apply(cors, 2, min, na.rm = T)
min_cors <- min_cors[names(med_cors)]

max_cors <- apply(cors, 2, max, na.rm = T)
max_cors <- max_cors[names(med_cors)]

p_cors <- data.frame(Cluster = names(med_cors),
                     Med = med_cors,
                     Min = min_cors,
                     Max = max_cors)

p_cors <- p_cors[is.finite(p_cors$Med),]

p_cors$Cluster <- factor(p_cors$Cluster, levels = unique(p_cors$Cluster))

ggplot(p_cors, aes(x = Cluster, y = Med)) +
  geom_point() +
  geom_errorbar(aes(ymin = Min, ymax = Max)) +
  theme_classic() +
  theme(axis.text.x = element_blank(),
        axis.ticks.x = element_blank()) +
  labs(title = "Plot of correlations by cluster",
       x = "Cluster",
       y = "Correlation")







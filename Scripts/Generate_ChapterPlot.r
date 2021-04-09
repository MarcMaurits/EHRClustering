#library
.libPaths("/PHShome/mom41/R/x86_64-pc-linux-gnu-library/3.6/")
library(reshape2)
library(ggplot2)

#data
load("dat_tsne.RData")
load("phecodes_complete.RData")
load("dat.RData")

#calculate
dat_chap <- split(dat$PheCode, as.factor(dat$ID))

dat_chap <- lapply(dat_chap, function(x){
  phecodes_complete[match(x, phecodes_complete$PheCode), "Category"]
})

dat_chap <- lapply(dat_chap, table)

dat_chap <- do.call("rbind", dat_chap)

dat_chap <- as.data.frame(dat_chap)

save(dat_chap, file = "/PHShome/mom41/Clustering/dat_chap.RData")

dat_chap <- scale(dat_chap)

#plot
x = 1

ggplot(as.data.frame(dat_tsne$Y), aes(x = V1, y = V2, colour = dat_chap[,x])) +
  geom_point(alpha = .5) +
  scale_colour_gradient(low = "white",
                        high = "black") +
  theme_classic() +
  labs(title = "ICD Chapter Distribution",
       subtitle = colnames(dat_chap)[x],
       x = "",
       y = "")
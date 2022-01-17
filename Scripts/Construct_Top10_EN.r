#library
.libPaths("/PHShome/mom41/R/x86_64-pc-linux-gnu-library/3.6/")

#load tops
top10 <- lapply(1:114, function(x){
  tmp <- get(load(paste0("/PHShome/mom41/Clustering/EN/Coefs_", x, ".RData")))
  tmp <- tmp[-grep("Intercept", tmp[,1]),]
  tmp[order(abs(tmp[,2]), decreasing = T),][1:10,]
})

names(top10) <- 1:114

save(top10, file = "/PHShome/mom41/Clustering/R_saves/top10_EN_abs.RData")

#ind <- Sys.getenv("LSB_JOBINDEX")

#tmp <- get(load(paste0("/PHShome/mom41/Clustering/EN/dat_en_", ind,".RData")))
#res <- coef(tmp$finalModel, tmp$bestTune$lambda)
#EN_Coefs <- data.frame(Code = gsub("P", "", res@Dimnames[[1]][res@i + 1]), 
#                       Beta = res@x)


#save(EN_Coefs, file = paste0("/PHShome/mom41/Clustering/EN/Coefs_", ind, ".RData"))

load("phecodes_complete.RData")

phecodes_red <- phecodes_complete[!duplicated(phecodes_complete$PheCode),c("PheCode", "Phenotype")]

lapply(1:114, function(x){
	tmp <- get(load(paste0("/PHShome/mom41/Clustering/EN/Coefs_", x,".RData")))
  tmp <- merge(tmp, phecodes_red, by.x = "Code", by.y = "PheCode")
  write.table(paste0("Cluster_", x), file = "/PHShome/mom41/Clustering/EN/all_coefs.csv", row.names = F, col.names = F, append = T, sep = ",")
  write.table(tmp, file = "/PHShome/mom41/Clustering/EN/all_coefs.csv", row.names = F, append = T, sep = ",")
})

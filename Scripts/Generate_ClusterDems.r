.libPaths("/PHShome/mom41/R/x86_64-pc-linux-gnu-library/3.6/")

source("/PHShome/mom41/Clustering/Scripts/Functions.R")

load("/PHShome/mom41/Clustering/R_saves/dat_clust.RData")
load("/PHShome/mom41/Clustering/R_saves/id_set_match.RData")

dat_dem <- read.csv("/PHShome/mom41/Clustering/Inputs/EMERGE_201907_DEMO_GWAS_3.csv")

cluster_dems <- lapply(levels(dat_clust$Cluster), function(x){
  ids <- unique(dat_clust[dat_clust$Cluster == x, "ID"])
  setdat <- dat_clust[dat_clust$ID %in% ids,]
  demdat <- dat_dem[dat_dem$SUBJECT_ID %in% ids,]
    
  res1 <- nrow(setdat)
  res2 <- length(ids)
  res3 <- length(unique(setdat$PheCode))
    
  res4 <- round(table(demdat$SEX)["C46110"]/nrow(demdat),2)
  res5 <- round(table(demdat$RACE)["C41261"]/nrow(demdat),2)
  res6 <- round(table(demdat$ETHNICITY)["C17459"]/nrow(demdat),2)
    
  tmp <- setdat[!duplicated(setdat$ID), "Age"]
  
  res7 <- round(median(tmp, na.rm = T),2)
  res8 <- round(range(tmp, na.rm = T)[1],2)
  res9 <- round(range(tmp, na.rm = T)[2],2)
  
  tmp <- split(setdat$PheCode, as.factor(setdat$ID))
    
  res10 <- median(sapply(tmp, length), na.rm = T)
  res11 <- range(sapply(tmp, length), na.rm = T)[1]
  res12 <- range(sapply(tmp, length), na.rm = T)[2]
    
  tmp <- lapply(tmp, unique)
    
  res13 <- median(sapply(tmp, length), na.rm = T)
  res14 <- range(sapply(tmp, length), na.rm = T)[1]
  res15 <- range(sapply(tmp, length), na.rm = T)[2]
    
  tmp <- split(setdat$Age, as.factor(setdat$ID))
  tmp <- sapply(tmp, function(y){
    ((max(y) - min(y))*365)+1
  })
    
  res16 <- round(median(tmp, na.rm = T))
  res17 <- round(range(tmp, na.rm = T)[1])
  res18 <- round(range(tmp, na.rm = T)[2])
    
  resfull <- c(res1, res2, res3, res4, res5, res6, res7, res8, res9, res10, res11, res12, res13, res14, res15, res16, res17, res18)
  names(resfull) <- c("Entries", "IDs", "PheCodes", "PropFem", "PropWhite", "PropHisp", "PPAgeMed", "PPAgeMin", "PPAgeMax", "PPEntriesMed", "PPEntriesMin", "PPEntriesMax", "PPPheCodesMed", "PPPheCodesMin", "PPPheCodesMax", "PPFollowUpMed", "PPFollowUpMin", "PPFollowUpMax")
    
  return(resfull)
})

names(cluster_dems) <- levels(dat_clust$Cluster)
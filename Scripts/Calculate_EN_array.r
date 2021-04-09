.libPaths("/PHShome/mom41/R/x86_64-pc-linux-gnu-library/3.6/")
library(Matrix)
library(glmnet)
library(caret)

load("dat_clust.RData")
load("graph_key.RData")

dir.create(file.path("/PHShome/mom41/Clustering", "GLM"), showWarnings = F)

ind <- Sys.getenv("LSB_JOBINDEX")

#Prepping m
dat_clust$PheCode <- as.factor(dat_clust$PheCode)

if(file.exists("prep_glm.RData")){
  load("prep_glm.RData")
} else {
  spl <- split(dat_clust$PheCode, as.factor(dat_clust$ID))

  m <- sapply(spl, function(x){
    table(x)
  })

  m <- t(m)

  colnames(m) <- paste0("P", colnames(m))

  prep_glm <- sparse.model.matrix(~., as.data.frame(m))

  save(prep_glm, file = "/PHShome/mom41/Clustering/prep_glm.RData")
}

#GLM
#dat_glm <- cv.glmnet(prep_glm, as.numeric(rownames(prep_glm) %in% graph_key[graph_key[,2] == as.character(ind), 1]), family = "binomial", nfolds = 10)

#save(dat_glm, file = paste0("/PHShome/mom41/Clustering/GLM/dat_glm_", ind, ".RData"))

#EN
#ind = 20 

prep_en <- cbind(prep_glm, as.numeric(rownames(prep_glm) %in% graph_key[graph_key[,2] == as.character(ind), 1]))
colnames(prep_en)[ncol(prep_en)] <- "InCluster"

train_control <- trainControl(method = "repeatedcv",
                              number = 5,
                              repeats = 5,
                              search = "random",
                              verboseIter = F)

elastic_net_model <- train(InCluster ~.,
                           data = as.matrix(prep_en),
                           method = "glmnet",
                           preProcess = c("center", "scale"),
                           tuneLength = 25,
                           trControl = train_control)

save(elastic_net_model, file = paste0("/PHShome/mom41/Clustering/EN/dat_en_", ind, ".RData"))
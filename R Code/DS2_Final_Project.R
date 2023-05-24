library(tidyverse)
library(mlr)
# library(mlr3verse)
library(DataExplorer)
library(readxl)
library(viridis)
library(ggridges)
library(parallelMap)
library(parallel)
library(GGally)
library(factoextra)
library(rgl)
library(idendr0)
# library(protoshiny)
# library(protoclust)
# library(ape)
library(umap)

# Read in data, only interested in the one sheet
birds <- read_excel("AVONET Supplementary dataset 1.xlsx", 
                    sheet = "AVONET3_BirdTree")

# Drop the non-important columns like range, latlong, and mass source
birds_trimmed <- birds %>% drop_columns(c(4:8,20:24,26:27,31:35))

birds.quant <- birds_trimmed[,4:14]
ggpairs(birds.quant)

# # Summary
# create_report(birds_trimmed)

# Viz

ggpairs(gvhdTib, aes(col = kMeansCluster),
        upper = list(continuous = "density")) +
  theme_bw()

ggplot(birds, aes(x = Hand_Wing.Index, y = Primary.Lifestyle, fill = Primary.Lifestyle, alpha = 0.8)) +
  geom_density_ridges() +
  theme_ridges() + 
  theme(legend.position = "none")

birds %>%
  ggplot(aes(x = Hand_Wing.Index, y = Order3, fill = Order3, alpha = 0.80)) +
  geom_density_ridges() +
  theme_ridges() +
  theme(legend.position = "none") +
  facet_wrap(~Order3, scales = "free")

ggplot(data = birds, aes(x = Primary.Lifestyle)) +
  geom_bar(aes(fill = Primary.Lifestyle)) + coord_flip() +
  scale_fill_viridis(discrete = TRUE) +
  facet_wrap(~Order3, scales = "free")

birds %>% filter(Trophic.Level != "NA") %>% ggplot(aes(x = Trophic.Level)) +
  geom_bar(aes(fill = Trophic.Level)) + coord_flip() +
  scale_fill_viridis(discrete = TRUE) +
  facet_wrap(~Order3, scales = "free")

birds %>% filter(Trophic.Niche != "NA") %>%
  ggplot(aes(x = Trophic.Niche, fill = Trophic.Niche)) +
  geom_bar() + 
  coord_flip() +
  scale_fill_viridis(discrete = TRUE) +
  facet_wrap(~Order3, scales = "free")

birds %>% 
  filter (Trophic.Niche == "Frugivore" | Trophic.Niche == "Granivore") %>%
  ggplot(aes(x = Trophic.Niche)) +
  geom_bar(aes(fill = Trophic.Niche)) + coord_flip() +
  scale_fill_viridis(discrete = TRUE) +
  facet_wrap(~Family3, scales = "free")

birds %>% 
  filter(Order3 == "Anseriformes" & Trophic.Niche != "NA") %>% 
  ggplot(aes(x = Trophic.Niche)) +
  geom_bar(aes(fill = Trophic.Niche)) + coord_flip() +
  scale_fill_viridis(discrete = TRUE) +
  facet_wrap(~Family3, scales = "free")

# Regression/kNN start ----------------------------------------------------------

beak <- birds[,c(9:12,29)]

# beak <- beak %>% mutate(coronal = Beak.Depth * Beak.Width,
#                         saggital = Beak.Depth * Beak.Length_Nares,
#                         frontal = Beak.Length_Nares * Beak.Width,
#                         roughvolume = Beak.Depth * Beak.Width * Beak.Length_Nares)

# plot3d(beak$saggital,beak$coronal,beak$frontal)

# pairs(beak[,c(1:4,6:9)])

task <- makeClassifTask(data = beak, target = "Trophic.Niche")

knn <- makeLearner("classif.knn", par.vals = list("k" = 16))

knnModel <- train(knn, task)

knnpredict <- predict(knnModel, newdata = beak)

kFold <- makeResampleDesc(method = "RepCV", folds = 5, reps = 20,
                          stratify = TRUE)
kFoldCV <- resample(learner = knn, task = task,
                    resampling = kFold, measures = list(mmce, acc))

calculateConfusionMatrix(kFoldCV$pred, relative = TRUE)

knnParamSpace <- makeParamSet(makeDiscreteParam("k", values = 1:30))

gridSearch <- makeTuneControlGrid()

cvForTuning <- makeResampleDesc("RepCV", folds = 10, reps = 10)

tunedK <- tuneParams("classif.knn", task = task,
                     resampling = cvForTuning,
                     par.set = knnParamSpace, control = gridSearch)

plotLearnerPrediction(knn, task)


knnTuningData <- generateHyperParsEffectData(tunedK)

plotHyperParsEffect(knnTuningData, x = "k", y = "mmce.test.mean",
                    plot.type = "line") + theme_bw()


# LDA ------------------------------------------------

ldaTask <- makeClassifTask(data = beak, target = "Primary.Lifestyle")

lda <- makeLearner("classif.lda")

ldaModel <- train(lda, ldaTask)

ldaModelData <- getLearnerModel(ldaModel)

ldaPreds <- predict(ldaModelData) #returns list, where element x stores the discriminant factor values of each case.

dfs <- ldaPreds$x

ldaCV <- resample(learner = lda, task = ldaTask, resampling = kFold, measures = list(acc))

# ldaModel$learner.model

ldadat <- beak %>% mutate(LD1 = dfs[, 1], LD2 = dfs[, 2])
ldadat <- ldadat[,c(10,11,5)]

beak %>%
  mutate(LD1 = dfs[, 1],
         LD2 = dfs[, 2]) %>%
  ggplot(aes(LD1, LD2, col = Primary.Lifestyle)) +
  geom_point() +
  stat_ellipse() + #look this function UP!!
  theme_bw()

# ldaknn --------------------------------------------------------------------
taskLK <- makeClassifTask(data = ldadat, target = "Primary.Lifestyle")

knnLK <- makeLearner("classif.knn", par.vals = list("k" = 15))

kFoldLK <- makeResampleDesc(method = "RepCV", folds = 10, reps = 25,
                             stratify = TRUE)
kFoldCV <- resample(learner = knnLK, task = taskLK,
                    resampling = kFoldLK, measures = list(acc))

knnParamSpaceLK <- makeParamSet(makeDiscreteParam("k", values = 1:30))

gridSearchLK <- makeTuneControlGrid()

cvForTuningLK <- makeResampleDesc("RepCV", folds = 10, reps = 20)

tunedKLK <- tuneParams("classif.knn", task = taskLK,
                        resampling = cvForTuningLK,
                        par.set = knnParamSpaceLK, control = gridSearchLK)

plotLearnerPrediction(knnLK, taskLK)

knnTuningDataLK <- generateHyperParsEffectData(tunedKLK)

plotHyperParsEffect(knnTuningDataLK, x = "k", y = "mmce.test.mean",
                    plot.type = "line") + theme_bw()


# SVM --------------------------------------------------------

birds_slim <- birds[,c(2,9:19,25,28:30)]
birds_slim <- mutate_at(birds_slim, vars(13:16), as.factor)

birdTask <- makeClassifTask(data = birds_slim, target = "Family3")
svm <- makeLearner("classif.svm")
getParamSet("classif.svm")

kernels <- c("linear", "polynomial", "radial", "sigmoid")

svmParamSpace <- makeParamSet(
  makeDiscreteParam("kernel", values = kernels),
  makeIntegerParam("degree", lower = 1, upper = 3),
  makeNumericParam("cost", lower = 0.1, upper = 10),
  makeNumericParam("gamma", lower = 0.1, 10))

randSearch <- makeTuneControlRandom(maxit = 20)
cvForTuning <- makeResampleDesc("Holdout", split = 2/3)

parallelStartSocket(cpus = detectCores()-2)

tunedSvmPars <- tuneParams("classif.svm", task = birdTask,
                           resampling = cvForTuning,
                           par.set = svmParamSpace,
                           control = randSearch)

parallelStop()

tunedSvmPars
#----------------------------------------------------------------

# HC
birdDist <- dist(birds_slim[,2:16], method = "euclidean")

birdclust <- hclust(birdDist, method = "ward.D2")

birdprotoclust <- protoclust(birdDist)


# birdDend <- as.dendrogram(birdclust)
# plot(birdDend, leaflab = "none", type = "triangle", horiz = TRUE)

#-------------------------------------------------------------------------

bird.tsne <- birds_trimmed %>% 
  drop_na() %>%
  select(-c(Order3,Species3,Habitat,Trophic.Level,Species.Status))%>%
  mutate(ID=row_number())

birds_meta <- bird.tsne %>%
  select(ID,Family3,Trophic.Niche,Primary.Lifestyle)

tSNE_fit <- bird.tsne %>%
  select(where(is.numeric)) %>%
  column_to_rownames("ID") %>%
  scale() %>% 
  Rtsne(check_duplicates = FALSE)

tSNE_df <- tSNE_fit$Y %>% 
  as.data.frame() %>%
  rename(tSNE1="V1",
         tSNE2="V2") %>%
  mutate(ID=row_number())

tSNE_df <- tSNE_df %>%
  inner_join(birds_meta, by="ID")

tSNE_df %>%
  ggplot(aes(x = tSNE1, 
             y = tSNE2,
             color = Trophic.Niche))+
  geom_point()+
  theme(legend.position="none")

# 02_clustering_analysis.R
# Clustering tendency assessment, K-means clustering, VAT comparison, validation

library(factoextra)
library(clustertend)
library(dplyr)
library(cluster)
library(seriation)

# Load standardized features
features <- readRDS("data/features.rds")

# Select and standardize clustering variables
features_for_clustering <- features %>%
  select(pid, totalPlayTime, handheldPlayTime, propNightSessions, sessionCount, meanSessionDuration)

features_no_outliers <- features_for_clustering %>%
  mutate(across(where(is.numeric), ~ scale(.) %>% as.vector))

# Check clustering tendency (Hopkins)
hopkins_stat <- get_clust_tendency(features_no_outliers %>% select(-pid), n = nrow(features_no_outliers) - 1)$hopkins_stat
cat("Hopkins statistic:", hopkins_stat, "\n")

# Visual Assessment of Tendency (VAT)
diss_actual <- dist(features_no_outliers %>% select(-pid))
VAT_actual <- VAT(diss_actual)

# Simulated VAT (to compare structure)
set.seed(123)
means <- sapply(features_no_outliers %>% select(-pid), mean)
sds <- sapply(features_no_outliers %>% select(-pid), sd)
simulated_data <- matrix(nrow = nrow(features_no_outliers), ncol = ncol(features_no_outliers) - 1)
for (i in seq_along(means)) {
  simulated_data[, i] <- rnorm(nrow(simulated_data), mean = means[i], sd = sds[i])
}
simulated_data <- as.data.frame(simulated_data)
colnames(simulated_data) <- names(means)
diss_simulated <- dist(simulated_data)
VAT_simulated <- VAT(diss_simulated)

# Plot both VAT matrices
par(mfrow = c(1, 2))
image(1:nrow(as.matrix(VAT_simulated$VAT_ordered)), 1:ncol(as.matrix(VAT_simulated$VAT_ordered)),
      as.matrix(VAT_simulated$VAT_ordered), main = "VAT: Simulated Data", col = heat.colors(100), axes = FALSE)
image(1:nrow(as.matrix(VAT_actual$VAT_ordered)), 1:ncol(as.matrix(VAT_actual$VAT_ordered)),
      as.matrix(VAT_actual$VAT_ordered), main = "VAT: Actual Data", col = heat.colors(100), axes = FALSE)
par(mfrow = c(1, 1))

# Determine optimal number of clusters
fviz_nbclust(features_no_outliers %>% select(-pid), kmeans, method = "wss")
gap_stat <- clusGap(features_no_outliers %>% select(-pid), FUN = kmeans, nstart = 25, K.max = 10, B = 50)
fviz_gap_stat(gap_stat)

# K-means clustering (K = 3 based on previous results)
set.seed(123)
kmeans_result <- kmeans(features_no_outliers %>% select(-pid), centers = 3, nstart = 25)
features_clustered <- features_no_outliers %>% mutate(cluster = kmeans_result$cluster)

# Validate clustering
silhouette_result <- silhouette(kmeans_result$cluster, dist(features_no_outliers %>% select(-pid)))
fviz_silhouette(silhouette_result)
cat("Average silhouette width:", mean(silhouette_result[, 3]), "\n")

library(fpc)
dunn_index <- dunn(clusters = kmeans_result$cluster, Data = as.matrix(features_no_outliers %>% select(-pid)))
cat("Dunn index:", dunn_index, "\n")

# Save clustered features
saveRDS(features_clustered, "data/features_clustered.rds")
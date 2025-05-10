# 05_visual_exploration.R
# Supplementary plots used for exploratory and presentation purposes

library(ggplot2)
library(dplyr)

features <- readRDS("data/features.rds")
features_clustered <- readRDS("data/features_clustered.rds")
participants <- readRDS("data/participants_with_scores.rds")

# --- Gameplay Distributions ---
features$totalPlayTimeHours <- features$totalPlayTime / 60

# Histogram: Total Play Time (Hours)
ggplot(features, aes(x = totalPlayTimeHours)) +
  geom_histogram(bins = 30, fill = "lightblue", color = "black") +
  xlab("Total Play Time (Hours)") + ylab("Frequency") +
  ggtitle("Distribution of Total Play Time")

# Histogram: Handheld Play Time (Proportion)
ggplot(features, aes(x = handheldPlayTime)) +
  geom_histogram(bins = 30, fill = "salmon", color = "black") +
  xlab("Handheld Play Time (Proportion)") + ylab("Frequency") +
  ggtitle("Distribution of Handheld Play Time")

# --- Clustering Relationship Plots ---
clustered <- participants %>%
  inner_join(features_clustered %>% select(pid, cluster, totalPlayTime), by = "pid")

# Plot: Well-being vs. Total Play Time by Cluster
ggplot(clustered, aes(x = totalPlayTime, y = well_being, color = factor(cluster), shape = factor(cluster))) +
  geom_point(alpha = 0.7, size = 3) +
  geom_smooth(method = "lm", se = FALSE, linetype = "dashed", color = "black") +
  labs(title = "Well-being vs. Total Play Time by Cluster",
       x = "Total Play Time (Minutes)", y = "Well-being",
       color = "Cluster", shape = "Cluster") +
  theme_minimal()

# Plot: Well-being vs. Need Satisfaction by Cluster
ggplot(clustered, aes(x = need_satisfaction, y = well_being, color = factor(cluster))) +
  geom_point(alpha = 0.7, size = 3, aes(shape = factor(cluster))) +
  geom_smooth(method = "lm", se = FALSE, aes(linetype = factor(cluster))) +
  geom_smooth(method = "lm", se = FALSE, color = "black", linetype = "dotted", size = 1) +
  labs(title = "Regression of Well-being on Need Satisfaction by Cluster",
       x = "Need Satisfaction", y = "Well-being",
       color = "Cluster", shape = "Cluster", linetype = "Cluster") +
  theme_minimal()
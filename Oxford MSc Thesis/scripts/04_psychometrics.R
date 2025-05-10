# 04_psychometrics.R
# Reliability analysis and descriptive statistics for key scales

library(psych)

# Load participants with scores
data <- readRDS("data/participants_with_scores.rds")

# Subscales
well_being_items <- data %>% select(starts_with("wemwbs_"))
ns_items <- data %>% select(bangs_1, bangs_2, bangs_3, bangs_7, bangs_8, bangs_9, bangs_13, bangs_14, bangs_15)
nf_items <- data %>% select(bangs_4, bangs_5, bangs_6, bangs_10, bangs_11, bangs_12, bangs_16, bangs_17, bangs_18)

# Cronbach's alpha
cat("\nCronbach's Alpha Results\n")
cat("--------------------------\n")
cat("Well-being:", round(alpha(well_being_items)$total$raw_alpha, 3), "\n")
cat("Need Satisfaction:", round(alpha(ns_items)$total$raw_alpha, 3), "\n")
cat("Need Frustration:", round(alpha(nf_items)$total$raw_alpha, 3), "\n")

# Descriptive statistics for composite variables
library(psych)
summary_stats <- data %>%
  summarise(
    Mean_WellBeing = mean(well_being, na.rm = TRUE),
    SD_WellBeing = sd(well_being, na.rm = TRUE),
    Mean_NeedSatisfaction = mean(need_satisfaction, na.rm = TRUE),
    SD_NeedSatisfaction = sd(need_satisfaction, na.rm = TRUE),
    Mean_NeedFrustration = mean(need_frustration, na.rm = TRUE),
    SD_NeedFrustration = sd(need_frustration, na.rm = TRUE)
  )

print(summary_stats)
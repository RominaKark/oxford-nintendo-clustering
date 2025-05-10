# 03_regression_models.R
# Linear regression, moderation analysis, and assumption checks

library(dplyr)
library(ggplot2)
library(car)
library(lmtest)

# Load prepared data
participants <- readRDS("data/participants_with_scores.rds")
features     <- readRDS("data/features.rds")
features_clustered <- readRDS("data/features_clustered.rds")

# Merge for analysis
cleaned_data <- participants %>%
  inner_join(features_clustered %>% select(pid, cluster, totalPlayTime), by = "pid") %>%
  mutate(
    cluster = factor(cluster),
    gender = ifelse(gender %in% c("Man", "Woman"), gender, "Other"),
    gender = factor(gender)
  )

# --- General regression: playtime -> well-being ---
general_model <- lm(well_being ~ totalPlayTime, data = cleaned_data)
summary(general_model)

# --- Moderation: cluster * needs -> well-being ---
model_rq3 <- lm(well_being ~ cluster * need_satisfaction + cluster * need_frustration, data = cleaned_data)
summary(model_rq3)

# --- Assumption Checks ---
# Linearity & homoscedasticity
plot(model_rq3$fitted.values, model_rq3$residuals,
     xlab = "Fitted Values", ylab = "Residuals", main = "Residuals vs Fitted")
abline(h = 0, col = "red")

# Normality
qqnorm(residuals(model_rq3))
qqline(residuals(model_rq3), col = "red")

# Breusch-Pagan test (heteroskedasticity)
bptest(model_rq3)

# Durbin-Watson test (autocorrelation)
dwtest(model_rq3)

# Multicollinearity (VIF)
vif_values <- vif(model_rq3)
print(vif_values)

# Cook's distance (influence)
cooksd <- cooks.distance(model_rq3)
plot(cooksd, type = "h", main = "Cook's Distance")
abline(h = 4 / length(cooksd), col = "red")

# Remove influential if needed
influential <- which(cooksd > (4 / length(cooksd)))
cleaned_data_filtered <- cleaned_data[-influential, ]

# Re-run model without outliers
model_filtered <- lm(well_being ~ cluster * need_satisfaction + cluster * need_frustration + gender + age,
                     data = cleaned_data_filtered)
summary(model_filtered)
# 01_data_preparation.R
# Loads packages, imports raw data (optional), cleans, and engineers features

# --- Load Required Libraries ---
required_packages <- c(
  "tidyverse", "lubridate", "seriation", "caret", "factoextra",
  "cluster", "clustertend", "mclust", "car", "lmtest", "psych", "corrplot"
)
installed <- installed.packages()[, "Package"]
for (pkg in required_packages) {
  if (!pkg %in% installed) install.packages(pkg)
}
invisible(lapply(required_packages, library, character.only = TRUE))

# --- Optional: Raw Data Import Template ---
# Sys.setenv(DATA_PATH = "your/local/path/to/data/")
# intervals <- read_csv(paste0(Sys.getenv("DATA_PATH"), "telemetry.csv.gz"))
# zones     <- read_csv(paste0(Sys.getenv("DATA_PATH"), "demographics.csv.gz"))
# surveys   <- read_csv(paste0(Sys.getenv("DATA_PATH"), "survey.csv.gz"))
# metaData  <- read_csv(paste0(Sys.getenv("DATA_PATH"), "gameMetadata.csv.gz"))
# saveRDS(intervals, "data/intervals.rds")
# saveRDS(zones,     "data/zones.rds")
# saveRDS(surveys,   "data/surveys.rds")
# saveRDS(metaData,  "data/metaData.rds")

# --- Load Cleaned Data ---
intervals <- readRDS("data/intervals.rds")
zones     <- readRDS("data/zones.rds")
surveys   <- readRDS("data/surveys.rds")

zones$hourDiff <- as.integer(substring(zones$localTimeZone, 6, 6))

# --- Merge and Clean ---
merged_data <- merge(intervals, zones, by = "pid") %>%
  merge(surveys, by = "pid") %>%
  filter(!is.na(hourDiff)) %>%
  mutate(
    sessionStartFixed = as_datetime(sessionStart) - hours(hourDiff),
    sessionEndFixed   = as_datetime(sessionEnd) - hours(hourDiff),
    recordedDate      = as_datetime(recordedDate),
    genderRC = ifelse(gender %in% c("Man", "Woman", NA), gender, "Non-binary")
  ) %>%
  mutate(across(starts_with(c("wemwbs","promis","trojan","bangs","displacement")), ~ case_when(
    . %in% c("Greatly interfered") ~ -3,
    . %in% c("Moderately interfered") ~ -2,
    . %in% c("Slightly interfered") ~ -1,
    . %in% c("No impact") ~ 0,
    . %in% c("1 - None of the time","Never","1 - Strongly disagree","1 \nStrongly Disagree","1  Strongly Disagree","Slightly supported","1") ~ 1,
    . %in% c("2 - Rarely","Rarely","Moderately supported","2") ~ 2,
    . %in% c("3 - Some of the time","Sometimes","Greatly supported","3") ~ 3,
    . %in% c("4 - Often","Often","4Neither Agree nor Disagree","4") ~ 4,
    . %in% c("5 - All of the time","Always","5 - Strongly agree","5") ~ 5,
    . %in% c("6") ~ 6,
    . %in% c("7 Strongly agree") ~ 7,
    TRUE ~ NA_integer_
  ))) %>%
  filter(across(c(starts_with("bangs"), starts_with("wemwbs"), "age", "gender", "employment", "ethnicity"), ~ !is.na(.))) %>%
  filter(sessionStartFixed >= recordedDate - days(14) & sessionStartFixed <= recordedDate) %>%
  filter(sessionEndFixed <= as.Date("2024-05-06")) %>%
  group_by(pid) %>%
  filter(all(duration <= 24 * 60)) %>%
  ungroup()

# --- Feature Engineering ---
filtered_participants <- merged_data

features <- filtered_participants %>%
  mutate(sessionDuration = duration) %>%
  group_by(pid) %>%
  summarise(
    totalPlayTime = sum(sessionDuration, na.rm = TRUE),
    sessionCount = n(),
    meanSessionDuration = mean(sessionDuration, na.rm = TRUE),
    varianceSessionDuration = var(sessionDuration, na.rm = TRUE),
    propNightSessions = sum(sessionDuration[hour(sessionStartFixed) >= 18], na.rm = TRUE) / sum(sessionDuration, na.rm = TRUE),
    handheldPlayTime = sum(sessionDuration[operationMode == "Handheld"], na.rm = TRUE) / sum(sessionDuration, na.rm = TRUE)
  ) %>% ungroup()

filtered_participants <- filtered_participants %>%
  mutate(
    need_satisfaction = rowMeans(select(., bangs_1, bangs_2, bangs_3, bangs_7, bangs_8, bangs_9, bangs_13, bangs_14, bangs_15), na.rm = TRUE),
    need_frustration = rowMeans(select(., bangs_4, bangs_5, bangs_6, bangs_10, bangs_11, bangs_12, bangs_16, bangs_17, bangs_18), na.rm = TRUE),
    well_being = rowMeans(select(., starts_with("wemwbs_")), na.rm = TRUE)
  )

# --- Save for later use ---
saveRDS(features, "data/features.rds")
saveRDS(filtered_participants, "data/participants_with_scores.rds")
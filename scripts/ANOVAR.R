#### GET AND SET WD

setwd("/Users/colleen/Desktop/sose-24/Project/eeg-data-class-project-seminar")
getwd()

#### LOAD DATA AND PREP FOR ANOVA
# Load necessary libraries
library(tidyverse)
library(car) # For Anova function
library(reshape2) # For data reshaping

# Load the data
data <- read_csv('extracted_data_300-400.csv')

# If "Condition" needs to be split into "cond" and "trialtype":
# Assume "Condition" is in the format "cond_trialtype", e.g., "1_2"
data <- data %>%
  separate(Condition, into = c("cond", "trialtype"), sep = "_")

# Convert to factors
data$Subject <- as.factor(data$Subject)
data$cond <- as.factor(data$cond)
data$trialtype <- as.factor(data$trialtype)

# Aggregate data if necessary (e.g., averaging across time points if you don't need time-specific analysis)
aggregated_data <- data %>%
  group_by(Subject, cond, trialtype) %>%
  summarise(Value = mean(Value, na.rm = TRUE))

# Print the aggregated data to check
print(aggregated_data)

####
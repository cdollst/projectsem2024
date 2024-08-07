#### GET AND SET WD

setwd("/Users/colleen/Desktop/sose-24/Project/eeg-data-class-project-seminar")
getwd()

#### LOAD DATA AND PREP FOR ANOVA
# Load necessary libraries
library(tidyverse)
#library(dplyr) #if it didn't load in with tidyverse

# Load the data
data300 <- read_csv('extracted_data_300-400.csv')

# Add condition and trial type variables using dplyr
data300 <- data300 %>%
  mutate(cond = case_when(
    Condition == 1 ~ "oddball",
    Condition == 2 ~ "oddball",
    Condition == 3 ~ "reversal",
    Condition == 4 ~ "reversal"
  ),
  trialtype = case_when(
    Condition == 1 ~ "common",
    Condition == 2 ~ "rare",
    Condition == 3 ~ "common",
    Condition == 4 ~ "rare"
  ))

# Check the data frame to ensure columns were added correctly
head(data300)

#### RUN THE ANOVA (Aggregated I don't think we need this just here if you want it)

# Aggregate data if necessary (e.g., averaging across time points if you don't need time-specific analysis)
aggregated_data <- data300 %>%
  group_by(Subject, cond, trialtype) %>%
  summarise(Value = mean(Value, na.rm = TRUE))

# Print the aggregated data to check
#print(aggregated_data)

# Reshape data from long to wide format
wide_data <- dcast(aggregated_data, Subject ~ cond + trialtype, value.var = "Value")

# Convert the data to long format for ANOVA
long_data <- melt(wide_data, id.vars = "Subject")

# Rename columns to match ANOVA requirements
colnames(long_data) <- c("Subject", "Condition_TrialType", "Value")

# Separate the Condition and TrialType
long_data <- long_data %>%
  separate(Condition_TrialType, into = c("cond", "trialtype"), sep = "_")

# Convert to factors
long_data$cond <- as.factor(long_data$cond)
long_data$trialtype <- as.factor(long_data$trialtype)

# Run the repeated measures ANOVA
anova_results <- aov(Value ~ cond * trialtype + Error(Subject/(cond * trialtype)), data = long_data)

# Summarize the ANOVA results
summary(anova_results)

#### RUN ANOVA WITHOUT AGGREGATION...

# Convert to factors; columns are converted to factors to ensure they are treated as categorical variables in the ANOVA.
data300$Subject <- as.factor(data300$Subject)
data300$cond <- as.factor(data300$cond)
data300$trialtype <- as.factor(data300$trialtype)

# Check the data frame to ensure columns were added correctly
head(data300)

# Run the repeated measures ANOVA with the Error term to account for within-subjects design
anova_results <- aov(Value ~ cond * trialtype + Error(Subject/(cond * trialtype)), data = data300)

# Summarize the ANOVA results
summary(anova_results)

# Create a summary data frame for plotting
summary_data <- data300 %>%
  group_by(cond, trialtype) %>%
  summarise(
    mean_value = mean(Value, na.rm = TRUE),
    se_value = sd(Value, na.rm = TRUE) / sqrt(n())
  )

# Print the summary data
print(summary_data)

# Save the summary data to a CSV file
write_csv(summary_data, 'summary_data.csv')

# Create the bar plot using ggplot2
barplot <- ggplot(summary_data, aes(x = cond, y = mean_value, fill = trialtype)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  geom_errorbar(aes(ymin = mean_value - se_value, ymax = mean_value + se_value),
                width = 0.2, position = position_dodge(0.9)) +
  labs(
    title = "Mean EEG Amplitudes by Condition and Trial Type",
    x = "Condition",
    y = "Mean EEG Amplitude (µV)"
  ) +
  theme_minimal() +
  scale_fill_brewer(palette = "Set1")

# Print the plot
print(barplot)

# Create the box plot using ggplot2
plot <- ggplot(data300, aes(x = interaction(cond, trialtype), y = Value, fill = trialtype)) +
  geom_boxplot() +
  labs(
    title = "EEG Amplitudes by Condition and Trial Type",
    x = "Condition and Trial Type",
    y = "EEG Amplitude (µV)"
  ) +
  theme_minimal() +
  scale_fill_brewer(palette = "Set1") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Print the plot
print(plot)

# Create the violin plot using ggplot2
violin_plot <- ggplot(data300, aes(x = interaction(cond, trialtype), y = Value, fill = trialtype)) +
  geom_violin(trim = FALSE) +
  geom_boxplot(width = 0.1, fill = "white", position = position_dodge(width = 0.9)) +
  labs(
    title = "EEG Amplitudes by Condition and Trial Type",
    x = "Condition and Trial Type",
    y = "EEG Amplitude (µV)"
  ) +
  theme_minimal() +
  scale_fill_brewer(palette = "Set1") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Print the violin plot
print(violin_plot)

# Create the rain plot using ggplot2
rain_plot <- ggplot(data300, aes(x = interaction(cond, trialtype), y = Value, color = trialtype)) +
  geom_jitter(width = 0.2, size = 1.5, alpha = 0.7) +
  geom_boxplot(width = 0.2, fill = "white", alpha = 0.5, position = position_dodge(width = 0.75)) +
  labs(
    title = "EEG Amplitudes by Condition and Trial Type",
    x = "Condition and Trial Type",
    y = "EEG Amplitude (µV)"
  ) +
  theme_minimal() +
  scale_color_brewer(palette = "Set1") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Print the rain plot
print(rain_plot)

#I found a main effect of trial type with my data/grandaverage, so I will conduct a post-hoc test to look at the differences between trial types more

#### Post-hoc paired t-tests for each condition:
# Filter data for each condition
oddball_data <- data300 %>% filter(cond == "oddball")
reversal_data <- data300 %>% filter(cond == "reversal")

# Paired t-test for oddball condition
oddball_ttest <- t.test(Value ~ trialtype, data = oddball_data, paired = TRUE)
print(oddball_ttest)

# Paired t-test for reversal condition
reversal_ttest <- t.test(Value ~ trialtype, data = reversal_data, paired = TRUE)
print(reversal_ttest)

# Combine post-hoc test results into a data frame for plotting
posthoc_results <- tibble(
  Condition = rep(c("oddball", "reversal"), each = 2),
  TrialType = rep(c("common", "rare"), 2),
  Mean = c(mean(oddball_data %>% filter(trialtype == "common") %>% pull(Value)),
           mean(oddball_data %>% filter(trialtype == "rare") %>% pull(Value)),
           mean(reversal_data %>% filter(trialtype == "common") %>% pull(Value)),
           mean(reversal_data %>% filter(trialtype == "rare") %>% pull(Value))),
  SE = c(sd(oddball_data %>% filter(trialtype == "common") %>% pull(Value)) / sqrt(nrow(oddball_data %>% filter(trialtype == "common"))),
         sd(oddball_data %>% filter(trialtype == "rare") %>% pull(Value)) / sqrt(nrow(oddball_data %>% filter(trialtype == "rare"))),
         sd(reversal_data %>% filter(trialtype == "common") %>% pull(Value)) / sqrt(nrow(reversal_data %>% filter(trialtype == "common"))),
         sd(reversal_data %>% filter(trialtype == "rare") %>% pull(Value)) / sqrt(nrow(reversal_data %>% filter(trialtype == "rare"))))
)

# Print the post-hoc test results
print(posthoc_results)

# Save the post-hoc test results
write_csv(posthoc_results, 'posthoc_results_combined.csv')

# Create a bar plot to visualize the paired post-hoc t-test results
posthoc_plot <- ggplot(posthoc_results, aes(x = TrialType, y = Mean, fill = TrialType)) +
  geom_bar(stat = "identity", position = position_dodge(), width = 0.7) +
  geom_errorbar(aes(ymin = Mean - SE, ymax = Mean + SE),
                width = 0.2, position = position_dodge(0.7)) +
  facet_wrap(~Condition) +
  labs(
    title = "Mean EEG Amplitudes by Trial Type for Each Condition",
    x = "Trial Type",
    y = "Mean EEG Amplitude (µV)"
  ) +
  theme_minimal() +
  scale_fill_brewer(palette = "Set1")

# Print the post-hoc plot
print(posthoc_plot)

# Create a boxplot to visualize the paired post-hoc t-test results
boxplot <- ggplot(data300, aes(x = interaction(cond, trialtype), y = Value, fill = trialtype)) +
  geom_boxplot(outlier.shape = NA) +
  geom_jitter(width = 0.2, size = 1, alpha = 0.6) +
  labs(
    title = "EEG Amplitudes by Condition and Trial Type",
    x = "Condition and Trial Type",
    y = "EEG Amplitude (µV)"
  ) +
  theme_minimal() +
  scale_fill_brewer(palette = "Set1") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Print the box plot
print(boxplot)


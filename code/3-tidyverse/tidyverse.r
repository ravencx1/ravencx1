library(tidyverse)
library(haven)
demo <- read_xpt(file="data/original/DEMO_D.XPT")
glimpse(demo)
# containing participant ID (respondent sequence number), gender, age and ethnicity.
demo1 <- demo %>%
  select(SEQN, RIAGENDR, starts_with("RIDAGE"), starts_with("RIDRETH"))
head(demo1)
# Read in the Body Measurement Data (BMX_D.csv). 
bmx <- read_csv(file="data/original/BMX_D.csv")
#Reformat the variable names of both the Body Measurement Data and the subset of the demographics data to lowercase. 
bmx <- bmx %>%
  rename_with(tolower)
demo1 <- demo1 %>%
  rename_with(tolower)
#Merge the Body Measurement Data with the demographics data, keeping the rows from the Body Measurement Data.
data_merged <- bmx %>%
  left_join(demo1, by="seqn")
# Move the demographics variables to the left hand side of the data frame, just to the right of the participant ID.
data_merged <- data_merged %>%
  relocate( riagendr, ridageyr, ridreth1, .after = seqn)
# Section 3: Merge sample information
# Read in the derived sample file that records whether accelerometer data are available.
sample <- read_csv(file="data/derived/BMX_included.csv") %>%
rename_with(tolower) %>%
rename(in_sample = included)
# Merge it into the body measurement and demographics data, moving the “in sample” variable just to the right of participant ID and renaming it “in_sample”.
data_merged1 <- data_merged %>%
  left_join(sample, by="seqn") %>%
  relocate(in_sample, .after = seqn)
# Section 4: Create an obesity variable
# Use the CDC definitions of BMI categories (https://www.cdc.gov/bmi/adult-calculator/bmicategories.
# html) to create a new categorical binary variable called “obesity” using dplyr.
# # Obesity
# # 30 or greater
data_merged2 <- data_merged1 %>%
  mutate(obesity = case_when(
    bmxbmi >= 30 ~ 1,
    bmxbmi < 30 ~ 0,
    TRUE ~ NA_integer_
  ))


# Section 5: Summarise the data
# Use dplyr verbs to calculate:
# • What percentage of the people in the body measurement sample who are considered to have obesity also have activity monitor data? How does this compare to the people who are not considered to have obesity?
data_merged2 %>%
filter(!is.na(obesity)) %>%
group_by(obesity) %>%
summarise(percent_with_accel = mean(in_sample, na.rm = TRUE) * 100)
#people with obesity have a higher percentage of activity monitor data compared to those without obesity.


# • What percentage of males have activity monitor data? How does this compare to females?
data_merged2 %>%
filter(!is.na(riagendr)) %>%
group_by(riagendr) %>%
summarise(percent_with_accel = mean(in_sample, na.rm = TRUE) * 100)
#percentage of males with activity monitor data is slightly lower than that of females.

# • What is the maximum reported height in cm of a child under 16 in this sample?
data_merged2 %>%
filter(ridageyr < 16) %>%
summarise(max_height = max(bmxht, na.rm = TRUE))
#191

# Section 6: Export the data
# Save the combined data frame to the derived data directory as a CSV called body_measurements.csv

write_csv(data_merged2, file="data/derived/body_measurements.csv")
# Make sure you’ve documented the new data and the code you’ve created in the relevant READMEs.
# And that your Conda environment and git repository are up to date.

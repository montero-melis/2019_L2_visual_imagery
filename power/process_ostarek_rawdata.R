# Process data from Ostarek & Huettig (JEP:HPP, 2017)

library("tidyverse")

file_names <- file.path("power/ostarek_data_CFS", list.files("power/ostarek_data_CFS"))
file_names <- file_names[grep("logfile", file_names)]

d <- map(file_names, read_tsv) %>% bind_rows
head(d)

# rename some columns
d <- d %>%
  rename(
    trial = Trial_nr, condition = Condition, pic_presence = Pic_Present_Absent,
    prime = Prime, target = Target)
head(d)

# participants
d$participant <- sub("^(\\d+)_.*", "\\1", d$Outputfile)

# Some columns do not seem to contain any information
map(select(d, Picture_Time, Button_Time), summary)
# ... so delete
d <- select(d, - Picture_Time, - Button_Time)
head(d)


# One thing to note: The condition name was mis-specified for two items.
d %>%
  select(condition, prime, target) %>%
  filter(prime == "Raket", target == "17_T_Rocket.jpg") %>%
  unique()
d %>%
  select(condition, prime, target) %>%
  filter(prime == "Vlinder", target == "28_T_Butterfly.jpg") %>%
  unique()
# Recode:
d$condition[d$prime == "Raket" & d$target == "17_T_Rocket.jpg"] <- "congruent"
d$condition[d$prime == "Vlinder" & d$target == "28_T_Butterfly.jpg"] <- "congruent"

# One item ("spuitje") was written in two different forms:
table(d$prime)
# To avoid problems, all primes to lowercase
d$prime <- tolower(d$prime)

# Number of data points per experimental cell
with(d, addmargins(table(condition, pic_presence), 1))  # Perfectly balanced!

# Number of data points per participant
sum(table(d$Outputfile) != 256)  # All of them have 256 observations!

# Quick check: what do response buttons mean? (check against false alarm rates in
# separate data file)
d %>%
  mutate(
    pressed_1 = ifelse(Button_Pressed == 1, 1, 0),
    pressed_2 = ifelse(Button_Pressed == 2, 1, 0)
    ) %>%
  filter(pic_presence == "absent") %>%
  group_by(Outputfile) %>%
  summarise(Prop1 = mean(pressed_1),
            Prop2 = mean(pressed_2))
# 1 = Object present
# 2 = No object present
# Recode this info
d$resp_presence <- ifelse(d$Button_Pressed == 1, 1, 0)
# Code response accuracy
d$resp_acc <- with(d, ifelse(
  (pic_presence == "present" & resp_presence == 1) |
    (pic_presence == "absent" & resp_presence == 0),
  1, 0))
head(d, 12)

# Save to disk
d %>%
  select(participant, trial, condition, pic_presence, prime, target,
         resp_presence, resp_acc, RT) %>%
  write_csv("power/data_ostarek2017.csv")

# Process data from Lupyan & Ward (PNAS, 2013)

library("tidyverse")

path2file <- file.path("power/lupyan_ward_data_CFS/")
exp1 <- read_csv(file.path(path2file, "lupyan_ward_exp1.csv"))
exp2 <- read_csv(file.path(path2file, "lupyan_ward_exp2.csv"))



# Experiment 1 data -------------------------------------------------------

# Explore columns to understand them
head(exp1)
names(exp1)

# rename some columns
exp1 <- exp1 %>%
  rename(
    participant = subjCode, trial = trial_num, prime = sound_name, picture = pic_name
  )
head(exp1)

exp1 %>% select(sound_file, prime) %>% unique()  # redundant cols
# what's this "is_valid" column?
exp1 %>% select(is_valid, is_pres) %>% unique() %>% arrange(is_valid, is_pres)
exp1 %>% select(is_valid, is_pres, cue) %>% unique() %>% arrange(is_valid, is_pres, cue)
# I think it's coding whether the validity prompt is valid or not, but it's a
# bit misleading since any prompt is considered as "valid" for the no-object
# trials, the "validity_recoded" column might have addressed this...
exp1 %>%
  group_by(validity_prompt, picture, cue, prime, is_pres, is_valid, validity_recoded) %>%
  count() %>%
  arrange(validity_prompt, picture, is_pres, is_valid, validity_recoded) %>%
  print(n = 22)
# oh man, this seems quite convoluted and their might be some errors in there...
#
exp1 %>% select(prime, picture) %>% unique() %>% arrange(prime, picture) %>% print(n=50)


# Create columns for compatibility with Markus's data
exp1 <- exp1 %>%
  mutate(condition = ifelse(prime == picture, "congruent", "incongruent"))
exp1$condition[is.na(exp1$condition)] <- "incongruent"
exp1$condition[exp1$prime == "noise"] <- "noise"
# check result
exp1 %>% select(prime, picture, condition) %>% unique() %>%
  arrange(prime, picture, condition) %>% print(n=20)
# pic_presence
table(exp1$condition)
table(exp1$is_pres)
with(exp1, addmargins(table(condition, is_pres)))

# Simplified version of data, enough to compute d' and make it compatible with
# Markus's data:
exp1_simple <- exp1 %>%
  select(
    participant, block, trial, condition, pic_presence = is_pres, cue, prime,
    target = picture, resp_acc = obj_presence_acc, RT = rt
  )
head(exp1_simple)

write_csv(exp1_simple, "power/data_lupyan13_exp1_simple.csv")


# Experiment 2 data -------------------------------------------------------

# Explore columns to understand them
names(exp2)

unique(exp2$sound)
table(exp2$sound)
# what's this "is_valid" column?
exp2 %>% select(is_valid, is_pres) %>% unique() %>% arrange(is_valid, is_pres)
exp2 %>% select(is_valid, is_pres, cue) %>% unique() %>% arrange(is_valid, is_pres, cue)
# There were 4 exemplars of each object category (see LW13, p.14200)
exp2 %>% select(pic_name, pic_num) %>% unique() %>% arrange(pic_name, pic_num)

# rename some columns
exp2 <- exp2 %>%
  rename(
    participant = subjCode, trial = trial_num, picture = pic_name,
  ) %>%
  mutate(picture_version = paste(picture, pic_num, sep = "_"))
head(exp2)

# Simplified version of data, enough to compute d' and make it compatible with
# Markus's data:
exp2_simple <- exp2 %>%
  select(
    participant, block, trial, prime = sound, picture, picture_version, cue,
    is_pres, obj_presence_acc
  )
head(exp2_simple)

write_csv(exp2_simple, "power/data_lupyan13_exp2_simple.csv")

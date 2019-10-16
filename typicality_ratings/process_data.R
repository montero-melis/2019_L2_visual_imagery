## Process data as output by the online experiment in Frinex

library("tidyverse")  # ggplot2, dplyr, readr, purrr, etc

mypath <- file.path("typicality_ratings", "results_191006")
mypath

# Load data files ---------------------------------------------------------

# Load main data file
d_all <- read_csv(file.path(mypath, "tagpairdata.csv"))

# Create column so I can later reorder rows if necessary
d_all$row_nb <- seq_len(nrow(d_all))
# Deal with time data, see https://www.cyclismo.org/tutorial/R/time.html
d_all$DateTime <- as.POSIXct(strptime(d_all$TagDate, format = "%Y-%m-%d %H:%M:%S"))
# remove character duplicate of TimeDate
d_all$TagDate <- NULL

str(d_all)
head(d_all)

# List of valid completion codes (from actual participants only)
valid_codes <- read.table(
  file.path(mypath, "valid_completion_codes.txt"),
  col.names = "code"
  )
head(valid_codes)

# List of participant information
ppt_info <- read_csv(file.path(mypath, "participants.csv"))
head(ppt_info)
# Add task order info (somehow didn't get recorded to TaskOrder but info is there)
ppt_info$task_order <- ifelse(ppt_info$Item == "english_ratings", "En-Du", "Du-En")

# List of items / stimuli
items <- read_csv("typicality_ratings/stimuli_typicality.csv") %>%
  select(item_id, trial_type, trial_lang, pic_file, object_name)
items$object_name <- toupper(items$object_name)
head(items)


# Select valid participants only ------------------------------------------

# Select unique pairs of <UserId, CompletionCode> (note some of them are
# duplicated, perhaps because the information was resent several times?)
user_ids <- unique(d_all[d_all$TagValue1 == "CompletionCode", c("UserId", "TagValue2")])
valid_ids <- user_ids[user_ids$TagValue2 %in% valid_codes$code, ] %>% pull(UserId)

# Use the data from valid pilot participants only
d <- d_all[d_all$UserId %in% valid_ids, ]
# same for participant info - keep only valid participants:
ppt_info <- ppt_info[ppt_info$UserId %in% valid_ids,]
# Assign more manageable user id's (simple integers)
ppt_info$user_id <- seq_len(nrow(ppt_info))
head(ppt_info)

# For easy reference, save participant keys to file
ppt_info %>% select(user_id, UserId) %>% arrange(user_id) %>%
  write_csv(file.path(mypath, "participant_id_keys.csv"))

d <- left_join(d, ppt_info %>% select(UserId, user_id))

# How many participants are there?
length(unique(d$UserId))         # 30
length(unique(ppt_info$UserId))  # 30


# Translation task --------------------------------------------------------

# Select relevant rows only
transl <- d[grep("Translate", d$TagValue1), ] %>%
  filter(EventTag == "freeText") %>%
  rename(Response = TagValue2)
head(transl)

# Clean up strings
transl$Response <- gsub("(.*?)(\\n)+", "\\1", transl$Response)  # remove "\n"s
transl$Response <- trimws(transl$Response)
transl$Response <- tolower(transl$Response)

# Extract item ID
transl$item_id <- as.numeric(sub(".*_([0-9]+)_.*", "\\1", transl$TagValue1))
head(transl)

# Join with item data
transl <- left_join(transl, items %>% filter(trial_lang == "English"))

# Version for coding
transl4cod <- transl %>%
  select(item_id, object_name, pic_file, Response)
# only unique responses:
transl4cod <- unique(transl4cod) %>%
  arrange(item_id, Response)
transl4cod$Score <- ""
transl4cod$Comment <- ""
head(transl4cod)

# write to disk for coding
write_csv(transl4cod, file.path(mypath, "transl_task_4coding.csv"))


# Translation task: coded data --------------------------------------------

# The coding was done offline by the RA. Now we merge the coded data set back:
transl_coded <- read_csv2(file.path(mypath, "translation4coding_coded.csv"))
head(transl_coded)

# Coding conventions:
# Data for this task is coded with the following values:
# 0 = No response (incl ?, -, etc)
# 1 = Correct and intended translation (corresponds to the picture)
# 2 = Correct but unintended translation (does not correspond to the picture)
# 3 = Incorrect translation
#
# 1 and 2 are considered correct for purposes of data exclusion
#
# When participants gave more than two words, each of them could be coded in the
# way above. To err on the conservative side, we always code the response as the
# worse score, e.g.;
# "1;2" --> 2
# "1;3" --> 3
# "3;1" --> 3
# "2;3" --> 3
# "1;2;3" --> 3

transl_coded$Score_ascoded <- transl_coded$Score

# Unique coded responses and their frequency:
table(transl_coded$Score_ascoded)
# It works to just take the max number if there are several (separated by ";")
transl_coded$Score <- sapply(
  lapply(
    strsplit(transl_coded$Score_ascoded, split = ";"),
    as.numeric),
  max)

table(transl_coded$Score)

# Fold back into the data
head(transl_coded)
head(transl)
transl_scored <- left_join(transl, transl_coded %>% select(item_id : Score))

# Specify the trial within group (works bc data frame is ordered by row_nb)
transl_scored <- transl_scored %>%
  group_by(UserId) %>%
  mutate(trial = row_number())

# Not all participants have the same number of trials!
table(transl_scored$trial)  # trial = 99?
transl_scored[transl_scored$trial == 99, ]
# A couple of trials seem to be repeated!
sum(table(transl_scored$object_name) != 30)
table(transl_scored$object_name)[table(transl_scored$object_name) != 30]
weird_items <- names(table(transl_scored$object_name)[table(transl_scored$object_name) != 30])
weird_ppts <- transl_scored[transl_scored$trial == 99, ] %>% pull(UserId)
transl_scored %>%
  filter(UserId %in% weird_ppts, object_name %in% weird_items)
# ... well, at least they were consistent in their responses; leave it in for simplicity

# Save to disk the final version with only necessary columns
transl_scored %>%
  ungroup %>%
  select(user_id, item_id, response = Response, score = Score,
         object_name, pic_file) %>%
  write_csv(file.path(mypath, "data_translation_task.csv"))


# Typicality ratings ------------------------------------------------------

# Choose rows from typicality rating task and simplify columns
typic <- d %>%
  filter(EventTag %in% c("RatingButton", "ObjectMismatch", "DontKnowWord")) %>%
  select(user_id, EventTag, TagValue1, TagValue2, row_nb)
head(typic)

# As for translation task, join with item data; however now we also need the
# trial language in addition to the item number

# Extract item ID
typic$item_id <- as.numeric(sub(".*_([0-9]+)_.*", "\\1", typic$TagValue1))
# Extract trial language
typic$trial_lang <- sub("(.*)_[0-9].*", "\\1", typic$TagValue1)
head(typic)

# Join with item data
typic <- left_join(typic, items)
head(typic)

# Join with task-order from participant data
typic <- left_join(typic, ppt_info %>% select(user_id, task_order))
head(typic)


# Put the responses in a single column
typic$response <- typic$TagValue2
# Mismatch responses:
typic[typic$EventTag == "ObjectMismatch", "response"] <- "Mismatch"
typic[typic$EventTag == "DontKnowWord", "response"] <- "WordUnknown"

# Check if there are repeated data points. I think this happens because
# participants jump back from a screen to the instructions screen and then
# back to the task again:
table(typic$user_id)  # there should be 228 observations / participant, but...
table(typic$user_id)[table(typic$user_id) != 228]
weird_ppts <- as.numeric(names(table(typic$user_id)[table(typic$user_id) != 228]))

# Repeated items:
typic %>%
  filter(user_id %in% weird_ppts) %>%
  group_by(user_id, item_id, trial_lang) %>%
  summarise(n = n()) %>%
  filter(n != 1)

# Some detective work - requires going back to the original data file:
# Remove duplicate items if they have the same response; if different, use the
# least favourable
# ppt 1
typic %>% filter(user_id == 1, item_id %in% c(34, 103), trial_lang == "English")
typic <- typic %>% filter(! row_nb %in% c(23026, 23028, 23036))
# apparently ppt 14 started one day for a few minutes and then finished some days
# later, which explains the large jump in row_nb
typic %>% filter(user_id == 14, item_id == 69, trial_lang == "English")
typic <- typic %>% filter(! row_nb %in% c(13069))
# ppt 19
typic %>% filter(user_id == 19, item_id == 60, trial_lang == "Dutch")
typic <- typic %>% filter(! row_nb %in% c(9286))
# ppt 26
typic %>% filter(user_id == 26, item_id == 119, trial_lang == "Dutch")
typic <- typic %>% filter(! row_nb %in% c(4122))

# Check again
sum(table(typic$user_id) != 228)  # problem solved


# Specify the trial within participant (works bc data frame is ordered by row_nb)
typic <- typic %>%
  group_by(user_id) %>%
  mutate(trial = row_number())

# Simplify columns
typic <- typic %>%
  ungroup %>%
  select(user_id, task_order, trial, item_id : object_name, response)
head(typic)

# Write to disk
write_csv(typic, file.path(mypath, "data_typicality_ratings.csv"))

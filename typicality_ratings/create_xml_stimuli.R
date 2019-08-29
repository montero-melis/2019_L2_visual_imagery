## A script to generate the stimuli objects for the MPI frinex experiment
## platform, so I can simply copy and paste
## (NB: this is very specific to that experiment and just saves me from typing)

library(tidyverse)


## read verb stimuli
items <- read_csv("typicality_ratings/stimuli_typicality.csv")
items$object_name <- toupper(items$object_name)
head(items)


## create output file
file.create("typicality_ratings/stimuli_xml.xml")


## Dutch ratings
du_xml <- paste(
  '<stimulus identifier="Dutch_',
  with(items[items$trial_lang == "Dutch", ],
       paste(item_id, trial_type, sep = "_")),
  '" label="Hoe typisch ',
  items[items$trial_lang == "Dutch", ]$carrier,
  ' ',
  items[items$trial_lang == "Dutch", ]$object_name,
  '?" imagePath = "',
  items[items$trial_lang == "Dutch", ]$pic_file,
  '" pauseMs="0" tags="dutch_ratings"/>',
  sep = "")
head(du_xml)

# Write to disk
cat("<!-- stimuli for Dutch ratings -->", file = "typicality_ratings/stimuli_xml.xml",
    sep = "\n", append = TRUE)
write.table(du_xml, file = "typicality_ratings/stimuli_xml.xml", quote = FALSE,
            col.names = FALSE, row.names = FALSE, append = TRUE)
cat("\n", file = "typicality_ratings/stimuli_xml.xml", append = TRUE)



## English ratings
en_xml <- paste(
  '<stimulus identifier="English_',
  with(items[items$trial_lang == "English", ],
       paste(item_id, trial_type, sep = "_")),
  '" label="How typical ',
  items[items$trial_lang == "English", ]$carrier,
  ' ',
  items[items$trial_lang == "English", ]$object_name,
  '?" imagePath = "',
  items[items$trial_lang == "English", ]$pic_file,
  '" pauseMs="0" tags="english_ratings"/>',
  sep = "")
head(en_xml)

# Write to disk
cat("<!-- stimuli for English ratings -->", file = "typicality_ratings/stimuli_xml.xml",
    sep = "\n", append = TRUE)
write.table(en_xml, file = "typicality_ratings/stimuli_xml.xml", quote = FALSE,
            col.names = FALSE, row.names = FALSE, append = TRUE)
cat("\n", file = "typicality_ratings/stimuli_xml.xml", append = TRUE)



## Translation task
transl_xml <- paste(
  '<stimulus identifier="Translate_',
  with(items[items$trial_lang == "English", ],
       paste(item_id, trial_type, sep = "_")),
  '" label="What is \'',
  items[items$trial_lang == "English", ]$object_name,
  '\' in Dutch?" pauseMs="0" tags="translation_task"/>',
  sep = "")
head(transl_xml)

# Write to disk
cat("<!-- stimuli for translation task -->", file = "typicality_ratings/stimuli_xml.xml",
    sep = "\n", append = TRUE)
write.table(transl_xml, file = "typicality_ratings/stimuli_xml.xml", quote = FALSE,
            col.names = FALSE, row.names = FALSE, append = TRUE)
cat("\n", file = "typicality_ratings/stimuli_xml.xml", append = TRUE)

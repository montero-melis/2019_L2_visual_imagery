## A script to generate the stimuli objects for the MPI frinex experiment
## platform, so I can simply copy and paste
## (NB: this is very specific to that experiment and just saves me from typing)

library(tidyverse)


## read verb stimuli
items <- read_csv("typicality_ratings/stimuli_typicality.csv")
head(items)


## create output file
file.create("online_exp/stimuli_xml.xml")


## feature task
feature_xml <- paste(
  '<stimulus identifier="feature',
  verbs$id,
  '" label="',
  verbs$feature,
  '" pauseMs="0" tags="feature_task"/>',
  sep = "")
head(feature_xml)

# Write to disk
cat("<!-- stimuli for FEATURE task -->", file = "online_exp/stimuli_xml.xml",
    sep = "\n", append = TRUE)
write.table(feature_xml, file = "online_exp/stimuli_xml.xml", quote = FALSE,
            col.names = FALSE, row.names = FALSE, append = TRUE)
cat("\n", file = "online_exp/stimuli_xml.xml", append = TRUE)


## negation task
negation_xml <- paste(
  '<stimulus identifier="negation',
  verbs$id,
  '" label="Zij ',
  verbs$negation,
  ', maar zij..." pauseMs="0" tags="negation_task"/>',
  sep = "")
negation_xml

# Write to disk
cat("<!-- stimuli for NEGATION task -->", file = "online_exp/stimuli_xml.xml",
    sep = "\n", append = TRUE)
write.table(negation_xml, file = "online_exp/stimuli_xml.xml", quote = FALSE,
            col.names = FALSE, row.names = FALSE, append = TRUE)
cat("\n", file = "online_exp/stimuli_xml.xml", append = TRUE)


## via task
via_xml <- paste(
  '<stimulus identifier="via',
  verbs$id,
  '" label="Zij ',
  verbs$via,
  ' via ..." pauseMs="0" tags="via_task"/>',
  sep = "")
via_xml

# Write to disk
cat("<!-- stimuli for VIA task -->", file = "online_exp/stimuli_xml.xml",
    sep = "\n", append = TRUE)
write.table(via_xml, file = "online_exp/stimuli_xml.xml", quote = FALSE,
            col.names = FALSE, row.names = FALSE, append = TRUE)
cat("\n", file = "online_exp/stimuli_xml.xml", append = TRUE)

library(tidyverse)

fk1999 <- read_csv("data/fk1999-stimuli.csv") %>%
  mutate(
    prefix = case_when(
      expected == "cissors" ~ "The child told her father she had cut herself making a paper snowflake. He told her that she should be more careful handling the",
      TRUE ~ prefix
    ),
    expected = case_when(
      expected == "cissors" ~ "scissors",
      expected == "Swiss cheese" ~ "swiss cheese",
      TRUE ~ expected
    ),
    within_category = case_when(
      expected == "cissors" ~ "stapler",
      TRUE ~ within_category
    ),
    between_category = case_when(
      expected == "cissors" ~ "scalpel",
      TRUE ~ between_category
    )
  )
fk1999_constraints <- read_csv("data/fk1999-constraints.csv")

fk1999 %>%
  inner_join(fk1999_constraints %>% select(expected, cloze)) %>%
  mutate(
    constraint = case_when(cloze < median(cloze) ~ "low", TRUE ~ "high"),
    cloze = cloze/100
  ) %>%
  rename(cloze_expected = cloze) %>%
  write_csv("data/fk1999-final.csv")

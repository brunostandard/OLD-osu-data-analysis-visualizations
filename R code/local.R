library(readr)
library(dplyr) # ignore the warning
library(tidyr)
library(ggplot2)


info <- read_csv("datasets/local/info.csv",col_names = FALSE)
info <- t(info)
#colnames(info)
head(info)
labels <- c("")


users <- read_csv("datasets/local/users.csv",col_names = FALSE)
names <- c("User","Score","accuracy", "?","?","?")
colnames(users) <- names
head(users)



scores <- read_csv("datasets/local/scores.csv",col_names = FALSE)

head(scores)

num_to_datetime <- function(num) {
  1970 + num/(365*24*60*60)
}

scores <- scores %>%
  mutate(
    X1 = 1970 + X1/(365*24*60*60)
  ) %>%
  select(X1,X4,X7,X8,X9,X10,X11,X12,X13,X14,X15)


colnames(scores) <- c("time","song","level","300","100","50","0","max_combo","score","score","X16")

head(scores)

ids <- read.table("data/derived/pids-with-accel.txt",
                    header=F, col.names='PID')
BMX <- read.csv("data/original/BMX_D.csv")
nrow(ids)
nrow(BMX)
library(dplyr)

ids <- ids %>% mutate(included=1)  
data <- left_join(BMX, ids, by=join_by(SEQN==PID)) %>%
    mutate(included=ifelse(is.na(included), 0, included)) %>%
    select(SEQN, included)
head(data)

write.csv(data, "data/derived/BMX_included.csv", row.names=F)

########################################################
## get Trump vote by district from DailyKos compilation
##
## simon jackman
## simon.jackman@sydney.edu.au
## ussc, univ of sydney
## 2017-03-20 21:01:31
########################################################
library(magrittr)
library(dplyr)
load("~/Dropbox/Projects/redistricting/Congressional/data/cong.RData")
dat16 <- cong %>% filter(year == 2016)

save("dat16",file="../data/dat16.RData")

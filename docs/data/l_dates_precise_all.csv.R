
# shared libraries, functions etc ####

source("./docs/data/shared.R") 

source("./docs/data/r_dates_precise_all.R")

   
# Convert data frame to delimited string, then write to standard output
cat(format_csv(bn_precise_dates))
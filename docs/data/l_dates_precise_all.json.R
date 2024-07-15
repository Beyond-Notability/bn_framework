
# shared libraries, functions etc ####

source("./docs/data/shared.R") 

source("./docs/data/r_dates_precise_all.R")

bn_precise_dates |>
   jsonlite::toJSON()
   
   

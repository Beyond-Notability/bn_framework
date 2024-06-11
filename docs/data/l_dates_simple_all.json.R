
# shared libraries, functions etc ####

source("./docs/data/shared.R") 

source("./docs/data/r_dates_simple_all.R")

bn_simple_dates |>
   jsonlite::toJSON()


source("./src/data/shared.R") 

source("./src/data/r_networks_general.R")


## events  (still a monster...)
source("./src/data/r_networks_events.R")

## rai elections
source("./src/data/r_networks_rai_elections.R")

## sal elections a bit big for testing!
#source("./src/data/r_networks_sal_elections_v2.R")

## excavations
source("./src/data/r_networks_excavations.R")


source("./src/data/r_networks_grouped.R")

## make a zip which could have several objects

# Add to zip archive, write to stdout.
setwd(tempdir())
write_json(bn_grouped_json, "bn-grouped-network.json")
system("zip - -r .")


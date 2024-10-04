
# shared libraries, functions etc ####


source("./src/data/shared.R") 

source("./src/data/r_dates_education.R")
  

## make a zip with several objects

# Add to zip archive, write to stdout.
setwd(tempdir())
## degrees.json is for the earlier faceted version which isn't in use at present; degrees2 is the one in use.
write_json(bn_women_education_degrees, "educated_degrees.json")
write_json(bn_women_education_degrees2, "educated_degrees2.json")
write_json(bn_women_educated_start_end_years, "start_end_pairs.json")
## will it work better with csv than json...
write_csv(bn_women_education_degrees2, "educated_degrees2.csv")
write_csv(bn_women_educated_start_end_years, "start_end_pairs.csv")
system("zip - -r .")
    
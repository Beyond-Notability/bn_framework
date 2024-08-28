source("./src/data/shared.R") 

source("./src/data/r_resided_at.R")


# Add to zip archive, write to stdout
setwd(tempdir())
write_csv(bn_dates_ages_not_dob, "dates-ages.csv", na="")
write_csv(resided_birth_age, "resided-birth-age.csv", na="")
write_csv(resided_dated, "resided-dated.csv", na="")
write_csv(resided, "resided.csv", na="")
write_csv(dates_resided_early_late, "dates-resided-early-late.csv", na="")
system("zip - -r .")  

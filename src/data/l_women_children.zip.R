
source("./src/data/shared.R") 

source("./src/data/r_women_children.R")



## make a zip even though you only have one file to start with, so you have the method...
## not sure from docs if .zip. naming of this file matters but makes sense for clarity anyway.

# Add to zip archive, write to stdout
setwd(tempdir())
write_csv(bn_had_children_ages, "had-children-ages.csv", na="")
#write_csv(bn_work_years_children, "work-years-with-children.csv", na="")
#write_csv(bn_served_years_children, "served-years-with-children.csv", na="")
write_csv(bn_work_served_years_children, "work-served-years-with-children.csv", na="")
write_csv(bn_last_ages, "consolidated-last-ages.csv", na="")
system("zip - -r .")  

#cat(format_csv(bn_had_children_ages_sorted_by_start_age, na=""))
   



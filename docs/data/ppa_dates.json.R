
# shared libraries, functions etc ####

source("./docs/data/shared.R") 


#source("./docs/data/dates.R") ??? bad idea






bn_women_dates_birth <-
bn_women_dates |>
  filter(date_prop %in% c("P26")) |>
  #add_count(bn_id) |> filter(n>1) |>
    group_by(bn_id) |>
  arrange(date_precision, .by_group = TRUE) |>
  top_n(1, row_number()) |>
  ungroup()

bn_women_dates_categories_birth <-
  bn_women_dates_categories |>
  # might as well add dob here...? will need a filter for dob specific charts
  left_join(
    bn_women_dates_birth |>
      select(bn_id, date_birth=date, year_birth=year), by="bn_id"
  ) |>
  mutate(age = year - year_birth) |>
  mutate(period = case_when(
    between(year_birth, 1815, 1854) ~ "1815-1853",
    between(year_birth, 1855, 1877) ~ "1854-1876",
    between(year_birth, 1878, 1924) ~ "1877-1924"
  )) 


bn_women_dates_ppa <-
bn_women_dates_categories_birth |>
  filter(category %in% c("PPA")) |>
  # this should be all you need now...
  # need shorter labels for event participation and charitable/organisational !
  mutate(subcat = case_match(
    ppa_bucket,
    "event participation" ~ "events",
    "charitable/organisational" ~ "charitable",
    .default = ppa_bucket
  )) 


# "bn_id"   "personLabel"   "date_propLabel"  "prop_valueLabel"   "date"               
# "year"  "date_precision" "date_certainty"  "date_label"   "date_level"         
# "date_string"  "qual_date_prop"  "date_prop"   "prop_value"   "s"                  
# "person"  "ppa_bucket"  "section" "category" "label"              
# "date_prop_label_std" "date_birth" "year_birth"   "age"   "period"             
# "subcat"  





bn_women_dates_ppa |>
	
   jsonlite::toJSON()
#  write_csv(stdout()) # work out how to do this at some point...


 
# zip(zipfile, files)


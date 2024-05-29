
# frequently used libraries ####

library(knitr)
library(kableExtra)

library(readxl) 
library(writexl)

library(janitor)
library(scales)
library(glue)

library(tidytext)

library(tidyverse)

# viz/ggplot extras

library(patchwork)

library(ggthemes)
library(ggalt)



# wikidata/sparql etc

library(SPARQLchunks) # can't get chunks working! but it's fine for inline queries.


# standard query using bn_prefixes and bn_endpoint. sparql= 'query string (excluding prefixes)'
bn_std_query <- function(sparql){
  c(paste(
    bn_prefixes,
    sparql
  )) |>
    SPARQLchunks::sparql2df(endpoint=bn_endpoint) 
}


## endpoint ####

bn_endpoint <- "https://beyond-notability.wikibase.cloud/query/sparql"

## prefixes 

bn_prefixes <- 
"PREFIX bnwd: <https://beyond-notability.wikibase.cloud/entity/>
PREFIX bnwds: <https://beyond-notability.wikibase.cloud/entity/statement/>
PREFIX bnwdv: <https://beyond-notability.wikibase.cloud/value/>
PREFIX bnwdt: <https://beyond-notability.wikibase.cloud/prop/direct/>
PREFIX bnp: <https://beyond-notability.wikibase.cloud/prop/>
PREFIX bnps: <https://beyond-notability.wikibase.cloud/prop/statement/>
PREFIX bnpq: <https://beyond-notability.wikibase.cloud/prop/qualifier/> 
PREFIX bnpsv: <https://beyond-notability.wikibase.cloud/prop/statement/value/>
PREFIX bnpqv: <https://beyond-notability.wikibase.cloud/prop/qualifier/value/>
  PREFIX bnwdref: <https://beyond-notability.wikibase.cloud/reference/>
  PREFIX bnpr: <https://beyond-notability.wikibase.cloud/prop/reference/>
  PREFIX bnprv: <https://beyond-notability.wikibase.cloud/prop/reference/value/>
"



# since i can never remember how to do this... make decades 0-9
make_decade <- function(data, year) {
  data |>
    mutate(decade = {{year}} - ({{year}} %% 10)) |>
    relocate(decade, .after = {{year}})
}

# to make date and year given a single column named date, in wikibase format. won't work on edtf.
make_date_year <-function(data){
  data  |>
    mutate(date = if_else(str_detect(date, "^_:t"), NA, date))  |>
    mutate(date = parse_date_time(date, "ymdHMS"))  |>
    mutate(year = year(date))
}




# add date property labels inside a mutate
date_property_labels <- function(v) {
  case_when(
    {{v}}=="P1" ~ "point in time",
    {{v}}=="P27" ~ "start time",
    {{v}}=="P28" ~ "end time",
    {{v}}=="P53" ~ "earliest date",
    {{v}}=="P51" ~ "latest date"
  )
}




#mutate(across(c(a, b), ~str_extract(., "([^/]*$)") )) 
# previous: \\bQ\\d+$

# get an ID out of a wikibase item URL. v is often but not always person. could be eg item, place, woman, etc.
make_bn_item_id <- function(df, v) {
  df |>
    mutate(bn_id = str_extract({{v}}, "([^/]*$)")) |>
    relocate(bn_id)
}

# the same if it was a query for properties
make_bn_prop_id <- function(df, v) {
  df |>
    mutate(bn_prop_id = str_extract({{v}}, "([^/]*$)")) |>
    relocate(bn_prop_id)
}

# use across to extract IDs from URLs for 1 or more cols, no renaming or relocating
# across_cols can be any tidy-select kind of thing
# generally only use this on ID cols, but sometimes qualifiers can be mixed: what if there were a / somewhere in a non URI  ??? 
# could add http to the rgx? then you'd have to change to str_match.
make_bn_ids <- function(data, across_cols=NULL, ...) {
  data |>
    mutate(across({{across_cols}}, ~str_extract(., "([^/]*$)")))
}





## dates of birth/death. - using this a lot now and it's not a heavy query, so it seems worth adding to the shared file.

bn_women_list_sparql <-
  'SELECT distinct ?person ?personLabel ?statements ?dob ?dod
WHERE {
   ?person bnwdt:P3 bnwd:Q3 ;
         wikibase:statements ?statements .
   FILTER NOT EXISTS {?person bnwdt:P4 bnwd:Q12 .}

      optional { ?person bnwdt:P15 ?dod .   }
      optional { ?person bnwdt:P26 ?dob .   }

    SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en,en-gb". } 
}'

# minimal processing to use as is or for dob/dod
bn_women_list <-
  bn_std_query(bn_women_list_sparql) |>
  make_bn_item_id(person) |>
  relocate(bn_id, personLabel) |>
  mutate(across(c(dob, dod), ~na_if(., ""))) |>
  arrange(parse_number(str_remove(bn_id, "Q")))


bn_women_dob_dod <-
  bn_women_list |>
  filter(!is.na(dob) | !is.na(dod)) |>
  #bn_women_dob_dod_query |>
  mutate(across(c(dob, dod), ~parse_date_time(., "ymdHMS"), .names = "bn_{.col}")) |>
  mutate(across(c(bn_dob, bn_dod), year, .names = "{.col}_yr")) |>
  select(-dob, -dod) |>
  # only one row per person please
  group_by(bn_id) |>
  top_n(1, row_number()) |>
  ungroup() 




## all the properties in the wikibase with label 
bn_properties <-
  c("SELECT DISTINCT ?property ?propertyType ?propertyLabel 
      WHERE {
        ?property a wikibase:Property ;
              rdfs:label ?propertyLabel ;
              wikibase:propertyType ?propertyType .
  
      FILTER(LANG(?propertyLabel) = 'en') 
    }
    order by ?propertyLabel") |>
  sparql2df(endpoint=bn_endpoint) |>
  make_bn_prop_id(property) |>
  mutate(property_type = str_extract(propertyType, "[A-Za-z]+$")) |>
  relocate(property_type, .after = bn_prop_id) |>
  relocate(property, propertyType, .after = last_col())  |>
  arrange(parse_number(str_extract(bn_prop_id, "\\d+"))) 


## labels and display ####

# for abbreviating names of the three main societies in labels (use in str_replace_all)
sal_rai_cas_abbr <-
  c("Society of Antiquaries of London"="SAL", "Royal Archaeological Institute"="RAI", "Congress of Archaeological Societies"="CAS")

##(make sure you do this after sal_rai_cas_abbr if you're using that)
organisations_abbr <-
  c("Archaeological" = "Arch", "Antiquarian" = "Antiq", "Society" = "Soc", "Association" = "Assoc")



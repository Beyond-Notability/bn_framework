
# shared libraries, functions etc ####

#source(here::here("_R/shared.R")) (not using all of shared.r here)


# libraries ####

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



# any extra libraries will usually go here 

# standard query strings and queries ####

#source(here::here("_R/std_queries.R"))


# a standard query using bn_prefixes and bn_endpoint. sparql= 'query string'
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

## added some extra prefixes - probably won't want the ones to do with references, but will need the psv and pqv.
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



# since i can never remember how to do this...
make_decade <- function(data, year) {
  data |>
    mutate(decade = {{year}} - ({{year}} %% 10)) |>
    relocate(decade, .after = {{year}})
}

# for single column named date; needs to be in wikibase format. won't work on edtf.
make_date_year <-function(data){
  data  |>
    mutate(date = if_else(str_detect(date, "^_:t"), NA, date))  |>
    mutate(date = parse_date_time(date, "ymdHMS"))  |>
    mutate(year = year(date))
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



## labels and display ####

# for abbreviating names of the three main societies in labels (use in str_replace_all)
sal_rai_cas_abbr <-
  c("Society of Antiquaries of London"="SAL", "Royal Archaeological Institute"="RAI", "Congress of Archaeological Societies"="CAS")

##(make sure you do this after sal_rai_cas_abbr if you're using that)
organisations_abbr <-
  c("Archaeological" = "Arch", "Antiquarian" = "Antiq", "Society" = "Soc", "Association" = "Assoc")




##for beeswarms you only need dob not dod as well... unless you want to reconstruct missing dobs from dods? hmm.
## this is a quick query so i think just run it.
bn_women_dob_sparql <-
'SELECT distinct ?person ?date 
WHERE {
   ?person bnwdt:P3 bnwd:Q3 .
  FILTER NOT EXISTS {?person bnwdt:P4 bnwd:Q12 .}
  ?person bnwdt:P26 ?date .   
}'

bn_women_dob_query <-
  bn_std_query(bn_women_dob_sparql) |>
  make_bn_item_id(person) |>
  select(-person) |>
  make_date_year() |>
  rename(dob=date, yob=year) |>
  group_by(bn_id) |>
  top_n(1, dob) |>
  ungroup() 
# top_n for a few women with >1 dob...
# some of these look like a year + more specific date. you only need year for this anyway... use top_n. if that's not enough, will need distinct(bn_id, yob) and top_n(yob)



# organised by P109: union query for linked event pages or in quals, excluding human organisers. atm all are items.

bn_organised_by_sparql <-
'SELECT distinct ?person ?organised_by ?organised_byLabel ?prop ?ev ?evLabel ?s

WHERE {  
  ?person bnwdt:P3 bnwd:Q3 .
  ?person ( bnp:P71 | bnp:P24 | bnp:P72 | bnp:P23 | bnp:P13 | bnp:P120 | bnp:P113 ) ?s .
    ?s ( bnps:P71 | bnps:P24 | bnps:P72 | bnps:P23 | bnps:P13 | bnps:P120 | bnps:P113 ) ?ev .  
   
  ?person ?p ?s .
      ?prop wikibase:claim ?p;      
         wikibase:statementProperty ?ps.  

  # organised by  
  {
    # in linked event page
   ?ev bnwdt:P109 ?organised_by .  
  }
  union
  {
    # in qualifier
     ?s bnpq:P109 ?organised_by . 
    }
  
  # exclude human organisers... P12 Q2137
       filter not exists { ?organised_by bnwdt:P12 bnwd:Q2137 . }
        
  SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en,en-gb". } 
}'

bn_organised_by_query <-
  bn_std_query(bn_organised_by_sparql) |>
  make_bn_item_id(person) |>
  make_bn_ids(c(ev, prop, organised_by, s)) |>
  select(-person) |>
  rename(ppa=prop)




# data saved to CSV 
bn_events_fetched <-
  read_csv("/Users/vanity/r_projects/beyond_notability/bn_notes/_data/queries/bn_ppa_events.csv")
  


# process the data a bit
bn_women_events_query <-
  bn_events_fetched |>
  make_bn_item_id(person) |>
  make_bn_ids(c(ppa, s, qual_value, prop, qual_prop)) |>
  mutate(across(c(qual_value, qual_valueLabel, qual_prop, qual_propLabel), ~na_if(., ""))) |>
  relocate(person, .after = last_col()) |>
  arrange(bn_id, s)



#  main only
# bn_women_ppa_events <-
bn_women_events <-
bn_women_events_query |>
  distinct(bn_id, personLabel, propLabel, ppaLabel, prop, ppa, s) |>
  left_join(bn_women_dob_query, by="bn_id") |>
  left_join(bn_organised_by_query |> 
              # just in case you get another with multiple organisers
              group_by(s) |>
              top_n(1, row_number()) |>
              ungroup() |>
              select(s, organised_by, organised_byLabel), by="s") |>
  #renaming to match original
  rename(event=ppaLabel, event_id=ppa) |>
  rename(ppa=prop, ppa_label=propLabel) |>
  relocate(ppa, .after = ppa_label) |>
  relocate(s, .after = last_col())

# propLabel was ppa_label
# ppaLabel was ppa_valueLabel
# ppa was ppa_value
# prop was ppa

# bn_women_ppa_events_qualifiers <-
bn_women_events_qualifiers <-
bn_women_events_query |>
  #renaming to match original
  rename(event=ppaLabel, event_id=ppa) |>
  rename(ppa=prop, ppa_label=propLabel) |>
  rename(qual_label = qual_propLabel, qual_p=qual_prop) |>
  relocate(ppa, .after = ppa_label) |>
  relocate(event_id, .after = event)



# this bit needs a query

bn_women_ppa_qual_inst_sparql <-
  'SELECT distinct ?person ?ppa ?qual ?qual_instance ?qual_instanceLabel  ?s
WHERE {  
  ?person bnwdt:P3 bnwd:Q3 .
  ?person ?p ?s .  
 
      ?ppa wikibase:claim ?p;      
         wikibase:statementProperty ?ps.       
      ?ppa bnwdt:P12 bnwd:Q151 . # i/o ppa      
 
      # get stuff about ?s 
      ?s ?ps ?qual.
  
      # get instance of for qual
        ?qual bnwdt:P12 ?qual_instance .

  SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en,en-gb". } 
}
order by ?s'

bn_women_ppa_qual_inst_query <-
  bn_std_query(bn_women_ppa_qual_inst_sparql) |>
  make_bn_item_id(person) |>
  make_bn_ids(c(ppa, qual, qual_instance, s)) |>
  select(-person) |>
  semi_join(bn_women_events, by="s")

# probably best not to use this if some events don't have i/o; go the other way and do left join
# bn_women_events_qual_io <-
# bn_women_ppa_qual_inst_query |>
#   semi_join(bn_women_events, by="s")




## saved to CSV

bn_events_time_precision_fetched <-
 read_csv("/Users/vanity/r_projects/beyond_notability/bn_notes/_data/queries/bn_ppa_events_time_precision.csv") 

bn_women_events_time_precision_query <-
  bn_events_time_precision_fetched |>
  make_bn_item_id(person) |>
  make_bn_ids(c(prop, ppa, date_prop, pqv, s)) |>
  #make_date_year() |> # um.
  select(-person)

# read_csv is automatically converting date to POSIXct... since when? it will break make_date_year
#bn_std_query(bn_women_events_time_precision_sparql) # not converted
#read_csv(bn_events_timeprecision_csv_file) # converted



bn_women_events_dates <-
  bn_women_events_time_precision_query |>
  # you need to keep the date as well as the precision when you pivot, to join. c() in values_from
  # start/end pivot to a single row
  filter(date_prop %in% c("P27", "P28")) |>
  pivot_wider(names_from = date_propLabel, values_from = c(date_precision, date), id_cols = s) |>
  clean_names("snake") |>
  rename(start_precision=date_precision_start_time, end_precision = date_precision_end_time) |>
  # then add p.i.t.
  bind_rows(
    bn_women_events_time_precision_query |>
      filter(date_prop %in% c("P1")) |>
      select(s, pit_precision=date_precision, date)
  ) |> 
  mutate(date = case_when(
    !is.na(date) ~ date,
    !is.na(date_start_time) ~ date_start_time
  )) |>
  mutate(date_precision = case_when(
    !is.na(pit_precision) ~ pit_precision,
    !is.na(start_precision) ~ start_precision
  )) |>
  mutate(year = year(date)) |>
  # drop extra stuff; you can always get it back if you need it right.
  select(s, date, date_precision, year)




# add a new step before of_dates for doing of_org combination
bn_women_events_of <-
bn_women_events |> 
  left_join(bn_women_events_qualifiers |>
              # of (item/free text)
              filter(qual_p %in% c("P78", "P66")) |>
              anti_join(bn_women_events |> filter(event_id=="Q3644"), by="s") |> # exclude CAS AGM of 
              distinct(s, qual_p, qual_label, qual_value, qual_valueLabel) |> # do i need distinct? possibly not.
              # ensure you have only 1 per stmt. these are all spoke_at; are they the ones with multiple papers?
              group_by(s) |>
              top_n(1, row_number()) |>
              ungroup() |>
              rename(of_label=qual_label, of=qual_p, of_id=qual_value, of_value=qual_valueLabel) 
              , by="s") |>
  # prefer of if you have both
  # i think organised_by is Items only, but use the id here just in case
  mutate(of_org = case_when(
    !is.na(of_value) ~ of_value,
    !is.na(organised_by) ~ organised_byLabel
  )) |>
  mutate(of_org_id = case_when(
    !is.na(of_id) ~ of_id,
    !is.na(organised_by) ~ organised_by
  )) 


# had manytomany warning. caused by multiple orgs in of. top_n as a quick hack to get rid. there are only a handful.
bn_women_events_of_dates <-
  bn_women_events_of |>
  left_join(bn_women_events_dates, by="s")  |>
  relocate(s, .after = last_col())






bn_women_events_of_dates_types_all <-
bn_women_events_of_dates |>
  # add i/o that are generic event types meeting/conference/exhibition - shouldn't dup... if it does will need to turn this into a separate step
  left_join(
    bn_women_ppa_qual_inst_query |>
      filter(qual_instanceLabel %in% c("meeting", "conference", "exhibition")) |>
      distinct(qual, qual_instance, qual_instanceLabel) |>
      rename(instance_id=qual_instance, instance=qual_instanceLabel), by=c("event_id"="qual")
  ) |>
  # # add other i/o - started to dup. see how you get on without it.  mostly will be orgs....
  # left_join(
  #   bn_women_ppa_qual_inst_query |>
  #     filter(!qual_instanceLabel %in% c("meeting", "conference", "exhibition", "event", "bucket", "locality", "venue")) |>
  #     distinct(qual, qual_instance, qual_instanceLabel) |>
  #     rename(instance2_id=qual_instance, instance2=qual_instanceLabel), by=c("event_id"="qual")
  # )  |>
  # add directly available locations
  left_join(
    bn_women_events_qualifiers |>
      filter(qual_label=="location") |>
      group_by(s) |>
      top_n(1, row_number()) |>
      ungroup() |>
      select(s, qual_location=qual_valueLabel, qual_location_value=qual_value)
  , by="s") |>
  
  # consolidate ppa_label item/text. currently only for delegate
  mutate(ppa_type = case_when(
    str_detect(ppa_label, "was delegate") ~ "was delegate at",
    .default = ppa_label
  )) |>
  relocate(ppa_type, .after = ppa)  |>
  
  # make event type. adjusted to do more as you dropped second i/o join. tweak for F.S.
  mutate(event_type = case_when(
    event %in% c("meeting", "exhibition", "conference") ~ event,
    event_id=="Q292" & is.na(of_org) ~ "meeting",  # folklore society not specified as meetings, but they almost certainly are
    #event_id=="Q682" ~ "conference", # Annual Meeting as conference? - to work this has to go before instance
    instance %in% c("meeting", "exhibition", "conference") ~ instance,
    event %in% c("committee", "museum") ~ "other",
    str_detect(event, "Meeting|Congress of the Congress of Archaeological Societies") ~ "meeting",
    str_detect(event, "Conference|Congress") | str_detect(of_org, "Conference|Congress") ~ "conference",
    #str_detect(instance2, "society|organisation|museum|institution|library") ~ "other",
    str_detect(of_org, "Society|Museum|Library|Institut|Association|School|College|Academy|University|Club|Gallery|Committee") | str_detect(event, "Society|Museum|Museo|Library|Institut|Association|School|College|Academy|University|Club|Gallery|Committee") ~ "other",
    .default = "misc"
  )) |>
  
    mutate(event_org = case_when(
    !is.na(of_org) ~ of_org,
    event_id=="Q292" & is.na(of_org) ~ event,
    event_type=="other" ~ event,
    str_detect(event, "Royal Archaeological Institute|\\bRAI\\b") ~ "Royal Archaeological Institute", 
    str_detect(event, "Society of Antiquaries of London|\\bSAL\\b") ~ "Society of Antiquaries of London",
    str_detect(event, "Congress of Archaeological Societies|\\bCAS\\b") ~ "Congress of Archaeological Societies",
    str_detect(event, "Royal Academy") ~ "Royal Academy",
    str_detect(event, "Society of Lady Artists") ~ "Society of Women Artists", 
    str_detect(event, "Folklore Society") ~ "The Folklore Society",
    # i think use event name for conferences/exhibitions without an of. but not generic
    event_type %in% c("conference", "exhibition", "misc")  & !event %in% c("meeting", "exhibition", "event", "petition", "conference")  ~ event
  )) |>

  # need an org id as well as org name. not quite the same as of_org_id... probably
  mutate(org_id = case_when(
    !is.na(of_org_id) ~ of_org_id,
    event_id=="Q292" & is.na(of_org) ~ event_id,
    # need these IDs 
    str_detect(event, "Royal Archaeological Institute|\\bRAI\\b") ~ "Q35", 
    str_detect(event, "Society of Antiquaries of London|\\bSAL\\b") ~ "Q8",
    str_detect(event, "Congress of Archaeological Societies|\\bCAS\\b") ~ "Q186", 
    str_detect(event, "Royal Academy") ~ "Royal_Academy",
    str_detect(event, "Society of Lady Artists") ~ "Q1891", # probably don't need this now ?
    str_detect(event, "Folklore Society") ~ "Q292",
    !is.na(event_org) ~ event_id,
    # conferences etc without an of - use event_id. but not if generic
    event_type %in% c("conference", "exhibition", "misc") & !event %in% c("meeting", "exhibition", "event", "petition", "conference") ~ event_id
  )) |>
  
  # event title. still probably wip. this is now not going to exactly match grouping of instance id, i think.
  # adding organised by -> needs some sort of tweak
  mutate(event_title = case_when(
    # for FS. not sure if still needed...
    event_id=="Q292" & is.na(of_org) ~ paste("meeting,", event),
    #  use year if other info is lacking. either should match instance id without a problem 
    event %in% c("exhibition", "meeting", "event", "conference") & is.na(of_org) & !is.na(year) ~ paste0(event, " (", year, ")"),
    event_id %in% c("Q1918") ~ event,  # society of ladies exhibition- don't want organised by in title here.
    !event %in% c("meeting", "event", "conference") & !is.na(organised_by) ~ event,
    is.na(of_org) ~ event,
    event=="event" ~ of_org,
    .default = paste(event, of_org, sep=", ")
  )) |>
  # some abbreviations
  mutate(event_title = str_replace_all(event_title, sal_rai_cas_abbr))  |>

  # grouping date for distinct events according to type of event
  # do i need to check this again after adjusting event_type? 
  mutate(event_instance_date = case_when(
    is.na(date) ~ NA,
    event_id=="Q682" ~ paste0(year, "-01-01"),
    event_type %in% c("misc", "meeting", "other") ~ as.character(date), # should i make this month?
    event_type %in% c("conference", "exhibition") ~ paste0(year, "-01-01")
  ))  |>
  
# NB: there is no event_of_id now; event_org_id instead.
  # id columns for convenience
  # mutate(event_instance_id = paste(event_instance_date, event_id, of_id, sep="_"))  |>
  # mutate(event_of_id = paste(event_id, of_id, sep="_")) |>
  mutate(event_instance_id = paste(event_instance_date, org_id, event_type, sep="_"))  |>
  
  # hmm, this may not quite work. and might need a bit of extra work for CAS etc. 
  mutate(event_org_id = case_when(
    # if generic and no other info except date, add year to the id [as in event_title].
    event %in% c("exhibition", "meeting", "event", "conference", "Annual Meeting", "petition") & is.na(of_org) & !is.na(year) ~ paste(org_id, event_type, year, sep="_"),
    # otherwise exclude date info
    .default =  paste(org_id, event_type, sep="_"))
         
         ) |>
  relocate(event_title, event_type, year, event_instance_date, event_org, org_id, event_instance_id, event_org_id, of_org, of_org_id, .after = ppa_type) 
  
bn_women_events_of_dates_types <-
bn_women_events_of_dates_types_all |>
  # losing ppa_label, but keep ppa in case you need any joins. just bear in mind slight difference.
  # also dropping separate organised by and of cols.
  distinct(bn_id, personLabel, ppa_type, ppa, event_title, event_type, year, event_instance_date, event_org, org_id, event_instance_id, event_org_id, dob, yob)


# unique event instances based on the workings
# but this is probably not quite right because it includes too much stuff incl title in group by
bn_women_event_instances <-
bn_women_events_of_dates_types_all |>
  group_by(event_instance_id, event_org_id, event_title, event_type, event_org, event, of_org, event_id, of_org_id, event_instance_date, year) |>
  # get all unique dates listed for the event instance, in chronological order
  arrange(date, .by_group = T) |>
  summarise(dates_in_db = paste(unique(date), collapse = " | "), .groups = "drop_last") |>
  ungroup() 




bn_women_events_of_dates_types |>
  distinct(bn_id, personLabel, event_title, event_type, event_instance_date, event_instance_id, year, event_org, org_id) |>  
  add_count(bn_id, name="n_bn") |>
  filter(n_bn>=5) |>
  #select(bn_id, personLabel, event_type, n_bn, event_org) |>
  # not sure how to make it CSV with actually writing a csv file. let's do json for now.
  jsonlite::toJSON()

 


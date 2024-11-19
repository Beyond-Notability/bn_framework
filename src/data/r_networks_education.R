## general moved to r_networks_general.R

## network specific from here


bn_educated_ucl_sparql <-
  'SELECT DISTINCT ?person ?personLabel ?subjectLabel ?subject ?date ?date_prop  ?s

WHERE {  
  ?person bnwdt:P3 bnwd:Q3 . #select women
  FILTER NOT EXISTS {?person bnwdt:P4 bnwd:Q12 .} #filter out project team
  
  # note: academic degree is P59. possible extra info?
  ?person bnp:P94 ?s .  # educated at
    ?s bnps:P94 bnwd:Q542 .
   
  # qualifiers 
  ?s bnpq:P60 ?subject. 
  ?s ( bnpq:P1 | bnpq:P27 | bnpq:P28 ) ?date .
  ?s ?date_prop ?date .

  SERVICE wikibase:label {bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en-gb,en".}
}'

bn_educated_ucl_query <-
  bn_std_query(bn_educated_ucl_sparql) |>
  make_bn_item_id(person) |>
  make_bn_ids(c(subject, s, date_prop)) |>
  #mutate(across(c(subject, subjectLabel, date_prop, date), ~na_if(., ""))) |>
  make_date_year() |>
  left_join(bn_properties |> select(date_prop= bn_prop_id, date_prop_label= propertyLabel), by="date_prop")


bn_educated_ucl_dates <-
bn_educated_ucl_query |> 
  distinct(bn_id, year, date_prop_label, s) |>
  pivot_wider(id_cols = s, names_from = date_prop_label, values_from = year) |>
  clean_names("snake") |>
  mutate(date_type = case_when(
      !is.na(point_in_time) ~ "point",
      is.na(end_time) | is.na(start_time) ~ "inferred", 
      .default = "actual"
      )) |>
  # add date pairs col?
  
## vast majority with both start and end= 1-4 years. 
  mutate(year_start_time = case_when(
    !is.na(point_in_time) ~ point_in_time,
    is.na(start_time) & !is.na(end_time) ~ end_time-3,
    .default = start_time
  )) |> 
  mutate(year_end_time = case_when(
    !is.na(point_in_time) ~ point_in_time,
    is.na(end_time) & !is.na(start_time) ~ start_time+3,
    .default = end_time
  )) |>
  select(!all_of(c("start_time", "end_time", "point_in_time")))


bn_educated_ucl_subjects <-
bn_educated_ucl_query |>
  distinct(bn_id, person_label= personLabel, academic_subject=subjectLabel, subject, s) |>
  # remove subjects with only one student
  add_count(academic_subject) |>
  filter(n>1) |>
  inner_join(bn_educated_ucl_dates, by="s") |>
  # purrr::map2 and seq() to fill out a list from a start number to given end number. then unnest to put each one on a new row.
  mutate(year = map2(year_start_time, year_end_time, ~seq(.x, .y, by=1))) |>
  unnest(year) |>
  select(bn_id, person_label, academic_subject, subject, year, year_start_time, year_end_time, date_type, s) |>
  mutate(subject_year_id = paste( subject, year, sep = "_"))


bn_educated_ucl_pairs <-
bn_educated_ucl_subjects |>
  rename(from=bn_id, from_name=person_label) |>
  inner_join(bn_educated_ucl_subjects |> select(to=bn_id, to_name=person_label, subject_year_id), by="subject_year_id", relationship = "many-to-many") |>
  filter(from!=to) |>
  relocate(to, to_name, .after = from_name) |>
  arrange(from_name, to_name) |>
  make_edge_ids()
# years complicate things... don't want to count each year for each pair as a separate connection!
# can you use the year strt time/end time. no that's per person not per edge.
# i think if you collapse them into date ranges or something... then you ahve something a bit like that PH temporal network...


bn_educated_ucl_pairs_by_subject <-
bn_educated_ucl_pairs |>
  distinct(edge_id, edge1, edge2, academic_subject, subject, year) |>
  group_by(edge1, edge2, academic_subject, subject) |>
  summarise(n=n(), edge_start_year=min(year), edge_end_year=max(year), .groups = "drop_last") |>
  ungroup() 
  # probably all n=1 even without the years.
  #count(academic_subject, edge1, edge2, edge_start_year, edge_end_year, name="weight", sort = T)

bn_educated_ucl_pairs_edges <-
bn_educated_ucl_pairs |>
  distinct(edge_id, edge1, edge2, year)  |> # 202
  #distinct(edge_id, edge1, edge2, academic_subject, subject, year) |> #225
  group_by(edge1, edge2) |>
  summarise(weight=n(), edge_start_year=min(year), edge_end_year=max(year), .groups = "drop_last") |>
  ungroup() |>
  # put college in for binding to other colleges.
  mutate(college="Q542", college_label="University College London")



bn_women_educated_dates_sparql <-
'SELECT ?personLabel ?collegeLabel ?universityLabel ?organisedLabel ?subjectLabel ?date ?date_prop ?s ?college ?university ?subject ?organised ?person 

WHERE {  
  ?person bnwdt:P3 bnwd:Q3 . #select women
  FILTER NOT EXISTS {?person bnwdt:P4 bnwd:Q12 .} #filter out project team
  
  # note: academic degree is P59. 
  ?person bnp:P94 ?s .  # educated at
    ?s bnps:P94 ?college .
      ?college bnwdt:P12 bnwd:Q2914 .   # tertiary ed inst
      optional {?college bnwdt:P4 ?university . } # a few college arent part of a university
      optional {?s bnpq:P109 ?organised . } # some extension centres
      optional {?s bnpq:P60 ?subject . } 
   
  # CHANGE: add P51 (latest).  drop it again for this!
  # dates. 
         # pit/start/end/latest. there are no earliest at present
      ?s (bnpq:P1 | bnpq:P27 | bnpq:P28  ) ?date . 
      ?s ?date_prop ?date.
  
  SERVICE wikibase:label {bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en-gb,en".}
}
order by ?personLabel ?collegeLabel ?date'

bn_women_educated_dates_query <-
  bn_std_query(bn_women_educated_dates_sparql) |>
  make_bn_item_id(person) |>
  make_bn_ids(c(college, university, subject, date_prop, organised, s)) |>
  mutate(across(c(university, organised, subject, universityLabel, organisedLabel, subjectLabel), ~na_if(., ""))) |>
  mutate(date_label = date_property_labels(date_prop)) |>
  # use make date function; filter NAs 
  make_date_year() |>
  filter(!is.na(date)) |>
  relocate(person, s, .after = last_col())



bn_women_educated_dates_wide <-
bn_women_educated_dates_query |>
  # convert uv subject to NA, 
  mutate(across(c(subject, subjectLabel),  ~if_else( str_detect(., "^(_:)?t\\d+$"), NA, . ))) |>
  # drop all alternative provision including extension centres for now. then don't need date_precision as all are year.
#  filter(college != "Q2485") |>
  # there's an update to this...in directory stuff.
  # drop alternative provision without an organised by (should keep extension centres)
  filter(college != "Q2485" | !is.na(organised)) |>
  # extension centre names are in organisedLabel rather than collegeLabel
  mutate(collegeLabel = case_when(
    college == "Q2485" ~ organisedLabel,
    college != "Q2485" ~ collegeLabel,
  )) |>
  mutate(college = case_when(
    college == "Q2485" ~ organised,
    college != "Q2485" ~ college,
  )) |>
  # distinct fixes dups caused by subjects 
  # do you really need university? can't see why.
  distinct(bn_id, personLabel, collegeLabel, college, date, year, date_label, s) |>
  # c() in values_from. that's all folks
  pivot_wider(names_from = date_label, values_from = c(date, year)) |>
  clean_names("snake") |>
  # create by_label to match degrees don't need this
  # col names are long... if renaming, need to be careful that new col names will be unique.
  #rename_with(~str_remove(., "^date_"), starts_with("date_")) |>
  # CHANGE include latest date
  mutate(date_pairs = case_when(
    !is.na(date_point_in_time) ~ "1 single",
    !is.na(date_start_time) & !is.na(date_end_time) ~ "2 both",
    !is.na(date_start_time) ~ "3 start",
    !is.na(date_end_time) ~ "4 end",
    #!is.na(date_latest_date) ~ "1 single", #
  )) |>
  # remove colleges with only one student
  add_count(college) |>
  filter(n>1) |>
  select(-n) |>
  # drop ucl	Q542, doing that separately
  filter(college != "Q542") 
  # don't need ages for this removed that stuff
  # filter out ucl


## you need inferred years before you fill, if you're doing them, 
# start-end interval years filled in. 
bn_women_educated_start_end_years <-
bn_women_educated_dates_wide |>
  #filter(date_pairs!="1 single") |>
  mutate(date_type = case_when(
    !is.na(year_point_in_time) ~ "point",
    is.na(year_end_time) | is.na(year_start_time) ~ "inferred", 
    .default = "actual"
    )) |>
## Q825 23 years... "The LSE Register notes that Chapman was full time at LSE 1903-14, and thereafter an occasional student."
## vast majority with both start and end= 1-4 years.
  rename(year_end_time1=year_end_time, year_start_time1=year_start_time) |>
  mutate(year_end_time = case_when(
    !is.na(year_point_in_time) ~ year_point_in_time,
    bn_id=="Q825" & college=="Q1162" & year_end_time1==1923 ~ 1914,
    is.na(year_end_time1) & !is.na(year_start_time1) ~ year_start_time1+3,
    .default = year_end_time1
  )) |>
  mutate(year_start_time = case_when(
    !is.na(year_point_in_time) ~ year_point_in_time,
    bn_id=="Q825" & college=="Q1162" & year_start_time1==1900 ~ 1903,
    is.na(year_start_time1) & !is.na(year_end_time1) ~ year_end_time1-3,
    .default = year_start_time1
  )) |> 
  # purrr::map2 and seq() to fill out a list from a start number to given end number. then unnest to put each one on a new row.
  mutate(year = map2(year_start_time, year_end_time, ~seq(.x, .y, by=1))) |>
  unnest(year) |>
  select(bn_id, person_label, college_label, college, year, year_start_time, year_end_time, date_type, date_pairs,  s) |>
  mutate(college_year_id = paste(college, year, sep = "_"))



# pairs based on same college and year ####

bn_women_educated_pairs <-
bn_women_educated_start_end_years |>
  rename(from=bn_id, from_name=person_label) |>
  inner_join(bn_women_educated_start_end_years |>
               select(to=bn_id, to_name=person_label, college_year_id), by="college_year_id", relationship = "many-to-many") |>
  filter(from!=to) |>
  relocate(to, to_name, .after = from_name) |>
  arrange(from_name, to_name) |>
  make_edge_ids()


bn_educated_pairs_by_college <-
bn_women_educated_pairs |>
  # leaving out college doesn't seem to make any difference to the distinct, so keep it for metadata.
  distinct(edge_id, edge1, edge2, college_label, college, year) |>
  group_by(edge1, edge2, college_label, college) |>
  summarise(weight=n(), edge_start_year=min(year), edge_end_year=max(year), .groups = "drop_last") |>
  ungroup() 

  # probably all n=1 even without the years.
  #count(college, edge1, edge2, edge_start_year, edge_end_year, name="weight", sort = T)


# combine with ucl pairs.
bn_educated_pairs_all <-
bind_rows(
  bn_educated_pairs_by_college,
  bn_educated_ucl_pairs_edges
) 
  #rename(from=edge1, to=edge2)



# not sure aobut adding nn here. nn of what? hmm.
bn_education_nodes <-
bn_educated_pairs_all |>
  pivot_longer(edge1:edge2, values_to = "person") |>
  distinct(person) |>
  inner_join(bn_person_list, by="person") 


bn_education_edges <-
bn_educated_pairs_all |>
  mutate(from=edge1, to=edge2) |>
  relocate(from, to)
# need to add gender and stuff

bn_education_network <-
  bn_tbl_graph(bn_education_nodes, bn_education_edges) |>
  #filter(!node_is_isolated()) |> not needed if using bn_centrality
  bn_centrality() |>
  bn_clusters()



# version uisng names instead of numerical ids, like the miserables example

bn_education_nodes_d3 <-
bn_education_network |>
  as_tibble() |>
  select(id=name, person, gender, year_birth, year_death,degree, ends_with("_rank"), starts_with("grp")) |>
  # make a slighlty artificial group for testing filtering, if you ever get that far
  mutate(group = case_when(
    degree >8 ~ "group1",
  	degree >3 ~ "group2",
  	degree >1 ~ "group3",
  	.default = "group4"
  )) |>
  mutate(
    name_label = if_else(degree>3, id, ""), 
  	full_name=id) |>
  arrange(id)



bn_education_edges_d3 <-
bn_education_network |>
  activate(edges) |>
  as_tibble() |>
  select(from=edge1, to=edge2, weight, edge_start_year, edge_end_year, college_label) |>
  left_join(bn_education_nodes_d3 |> distinct(source=id, from=person), by="from") |>
  left_join(bn_education_nodes_d3 |> distinct(target=id, to=person), by="to") |>
  relocate(source, target, from, to)

  
# put in named list ready to write_json  
bn_education_json <-
list(
     nodes= bn_education_nodes_d3,
     links= bn_education_edges_d3
     )    


  
  
  
## children data

# union a) unnamed kids in had child in; b) named child
# a handful of named children don't have dob though probably have dob in wikidata 

bn_had_children_sparql <-
'SELECT distinct ?person ?personLabel ?childLabel ?date_value ?date_prec ?had_child_edtf ?note  ?child ?s

where {

  ?person bnwdt:P3 bnwd:Q3 . # select women
  FILTER NOT EXISTS {?person bnwdt:P4 bnwd:Q12 .} #filter out project team
   
{   
  # had child (unnamed)
  ?person bnp:P131 ?s .
      ?s bnps:P131 ?had_child_edtf . # keep the edtf date for reference, though i think you can just use time value/prec with these.

  # get dates detail 
      ?s ?psv ?wdv .
        ?wdv wikibase:timeValue ?date_value .
        ?wdv wikibase:timePrecision ?date_prec .
  
  # filter edtf date.
  FILTER ( datatype(?had_child_edtf) = xsd:edtf ) . #shows only the raw EDTF string from the query results
    
   # not much added in quals for had child. only maybe note P47. some have sourcing circumstances.
   optional { ?s bnpq:P47 ?note .} 
   
  } 
  union 
  {
  # named children (are any in both sections??? from dates looks possible a couple might be [wherry / hodgson])
   ?person bnp:P45 ?s.
        ?s bnps:P45 ?child .
        optional { ?child bnp:P26 ?ss .
                    ?ss bnps:P26 ?dob . 
                     ?ss ?psv ?wdv .
                        ?wdv wikibase:timeValue ?date_value .
                        ?wdv wikibase:timePrecision ?date_prec .
               }
  }
  
    SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en,en-gb". } 
}
order by ?person ?date_value
'

bn_had_children_query <-
  bn_std_query(bn_had_children_sparql) |>
  make_bn_item_id(person) |>
  make_bn_ids(c(child, s)) |>
  mutate(across(c(note, had_child_edtf, childLabel, child), ~na_if(., ""))) |>
  relocate(person, .after = last_col())



# need dob for mothers if i'm going to put kids on life timelines... now in std queries


## may be some dup kids... could be a little bit tricky if you really wanted to separate out every child? but just doing per year should be fine. 



bn_had_children_ages <-
bn_had_children_query |>
    mutate(date_value = if_else(str_detect(date_value, "^_:t"), NA, date_value))  |>
    mutate(date_value = parse_date_time(date_value, "ymdHMS"))  |>
    mutate(year = year(date_value)) |>
  relocate(year, .after = date_value) |>
  filter(!is.na(date_value)) |>
  filter(year>1810) |>
  # this will sort named children above had_child rows. then top_n
  arrange(bn_id, year, child) |>
  group_by(bn_id, year) |>
  top_n(-1, row_number()) |>
  ungroup() |>
  #add_count(bn_id, date_value) |> filter(n>1)
  left_join(bn_women_dob_dod |> select(bn_id, bn_dob_yr, bn_dod_yr, bn_dob, bn_dod), by="bn_id") |>
  mutate(age = year-bn_dob_yr) |>
  filter(!is.na(age)) |>
  # first and last dates overall, for limits if doing by date
  mutate(start_date = min(date_value)- years(1), end_date = max(date_value) + years(1))  |>
  # don't need group_id/lower/upper for this version, only earliest and latest.
  group_by(personLabel) |> 
  mutate(earliest = min(date_value), latest=max(date_value)) |>
  ungroup() |> 
   mutate(start_age = min(age)-1, last_age = max(age), .by = bn_id) |>
   mutate(latest_year = year(latest) ) |>
   mutate(first_year=year(earliest) ) |>
   arrange(personLabel, bn_dob)
  #sorting has to happen in Obs Plot

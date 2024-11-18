# general functions for network analysis ####

library(tidygraph)
#library(widyr)

# create an undirected tbl_graph using person id as node id ####
# n = nodes list, e = edges list. need to be in the right sort of format! 
bn_tbl_graph <- function(n, e){
  tbl_graph(
    nodes= n,
    edges= e,
    directed = FALSE,
    node_key = "person"
  )
}






## new function to dedup repeated pairs after doing joins
make_edge_ids <- function(data){
  data |>
  # make std edge1-edge2 ordering numerically. (don't really need names? that's nodes metadata too really)
  mutate(across(c(from, to), ~str_remove(., "Q"), .names="{.col}_n")) |>
  mutate(across(c(from_n, to_n), parse_number)) |>
  # standard from_to id according to which is lower number, for deduping repeated pairs
  mutate(edge_id = case_when(
    from_n<to_n ~ glue("{from}_{to}"),
    to_n<from_n ~ glue("{to}_{from}")
  )) |>
  mutate(edge1 = case_when(
    from_n<to_n ~ from,
    to_n<from_n ~ to
  )) |>
  mutate(edge2 = case_when(
    from_n<to_n ~ to,
    to_n<from_n ~ from
  )) |>
  select(-from_n, -to_n)
}




# network has to be a tbl_graph
# must have weight col, even if all the weights are 1.
# centrality scores: degree, betweenness, [closeness], harmony, eigenvector. 
bn_centrality <- function(network){
  network |>
    # tidygraph fixes renumbering for you... but you should keep bn ids anyway.
  filter(!node_is_isolated()) |>
  # doesn't use the weights column by default. 
    mutate(degree = centrality_degree(weights=weight),
           betweenness = centrality_betweenness(weights=weight), # number of shortest paths going through a node
           #closeness = centrality_closeness(weights=weight), # how many steps required to access every other node from a given node
           harmonic = centrality_harmonic(weights=weight), # variant of closeness for disconnected networks
           eigenvector = centrality_eigen(weights=weight) # how well connected to well-connected nodes
    )  |>
    # make rankings. wondering whether to use dense_rank which doesn't leave gaps.
    mutate(across(c(degree, betweenness, harmonic, eigenvector),  ~min_rank(desc(.)), .names = "{.col}_rank")) 
    # if you do closeness lower=more central so needs to be ranked the other way round from the rest !
    # mutate(across(c(closeness),  min_rank, .names = "{.col}_rank"))
}



# community detection
# doing unweighted; seemed to work better for events?
# run this *after* centrality function otherwise you might need isolated filter

bn_clusters <- function(network){
  network |>
    mutate(grp_edge_btwn = as.factor(group_edge_betweenness(directed=FALSE))) |>
    mutate(grp_infomap = as.factor(group_infomap())) |>  
    mutate(grp_leading_eigen = as.factor(group_leading_eigen())) |> 
    mutate(grp_louvain = as.factor(group_louvain())) 
}






## gender 
# list of all the named people (not just women) with gender  

# list of all the named people (not just women) with gender  
bn_gender_sparql <-
  'SELECT DISTINCT ?person ?personLabel ?genderLabel
WHERE {  
  ?person bnwdt:P12 bnwd:Q2137 .
  FILTER NOT EXISTS {?person bnwdt:P4 bnwd:Q12 .} #filter out project team 
   optional { ?person bnwdt:P3 ?gender . } # a few without/uv, some named individuals
  SERVICE wikibase:label {bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en-gb,en".}
}
order by ?personLabel'

bn_gender_query <-
  bn_std_query(bn_gender_sparql) |>
  make_bn_ids(person) 

bn_gender <-
  bn_gender_query |>
# drop the not recorded, indecipherable, unnamed person kind of things.
  filter(!person %in% c("Q17", "Q2753", "Q576", "Q47") & personLabel !="??????????") |>
# make blank/uv gender "unknown" (only about a dozen, may well drop them.)
  mutate(genderLabel = case_when(
    is.na(genderLabel) | genderLabel=="" ~ "unknown",
    str_detect(genderLabel, "t\\d") ~ "unknown",
    .default = genderLabel
  )) |>
   # do slightly different gender column <uv> gender for excavations. tidy up later 
   mutate(gender = if_else(genderLabel %in% c("man", "woman"), genderLabel, NA))  |>
  rename(name = personLabel)





## this is not the all-the-dates query
bn_dates_sparql <-
'SELECT distinct ?person (year(?dod) as ?year_death) (year(?dob) as ?year_birth) ?s
  WHERE {
   ?person bnwdt:P12 bnwd:Q2137 . #humans
   FILTER NOT EXISTS { ?person bnwdt:P4 bnwd:Q12 . } # not project team
   
  optional { ?person bnwdt:P15 ?dod .   }
  optional { ?person bnwdt:P26 ?dob .   }
    
} # /where
ORDER BY ?person ?date'

bn_dates_query <-
  bn_std_query(bn_dates_sparql) |>
  make_bn_ids(c(person, s))  



bn_birth_dates <-
bn_dates_query |>
  filter(!is.na(year_birth)) |> 
  distinct(person, year_birth) |>
  group_by(person) |>
  arrange(year_birth, .by_group = T) |>
  top_n(-1, row_number()) |>
  ungroup() 

# dod seems fine on year, but should you assume it'll stay that way?
bn_death_dates <-
bn_dates_query |>
  filter(!is.na(year_death)) |>
  distinct(person, year_death)|>
  group_by(person) |>
  arrange(year_death, .by_group = T) |>
  top_n(-1, row_number()) |>
  ungroup() 



bn_person_list <-
bn_gender |>
  left_join(bn_birth_dates, by="person") |>
  left_join(bn_death_dates, by="person")



bn_members_sparql <-
'select distinct ?person ?personLabel ?member ?memberLabel ?date ?date_propLabel ?date_prop (year(?date) as ?year)
where
{
  ?person bnwdt:P3 bnwd:Q3 .
  ?person bnp:P67 ?s .
    ?s bnps:P67 ?member .
  #filter not exists { ?s bnps:P67 bnwd:Q35. }
   optional {     
       ?s ?pq ?date .   
          ?date_prop wikibase:qualifier ?pq .
          ?date_prop wikibase:propertyType wikibase:Time. 
        }

  SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en,en-gb". }
}'
  
bn_members_query <-
  bn_std_query(bn_members_sparql) |>
  make_bn_ids(c(person, member, date_prop)) |>
  filter(date_prop != "P51") |> # do this here and you don't need to worry about NA right?
  mutate(across(c(date_prop, date_propLabel, date), ~na_if(., ""))) 
 # filter(member != "Q35")


# exclude RAI and BM 
bn_members_decades <-
bn_members_query |> 
  filter(!member %in% c("Q35", "Q4379")) |>
  filter(!is.na(date))  |>
  # dated only
  make_decade(year) |>
  # drop date type
  distinct(person, personLabel, member, memberLabel, decade) |>
  arrange(personLabel, memberLabel, decade) |>
  # only orgs that have more than one member
  semi_join(
    bn_members_query |>
  	distinct(person, member) |>
  	count(member) |> filter(n>1), by="member"
  ) |>
  # shouldn't this be n societies rather than society + decade?
  add_count(person, name="n_event")





bn_members_pairs <-
bn_members_decades |>
  rename(from=person, from_name= personLabel) |>
  inner_join(bn_members_decades |>
               select(to=person, to_name=personLabel, member, decade), by=c("member", "decade"), relationship = "many-to-many") |>
  filter(from!=to) |>
  relocate(from_name, from, to_name, to) |>
  arrange(from_name, to_name) |>
  make_edge_ids()  



bn_members_edges <-
bn_members_pairs |>
  distinct(edge_id, edge1, edge2, member, decade) |> # 
  group_by(edge1, edge2) |>
  summarise(weight=n(), edge_start=min(decade), edge_end=max(decade), .groups = "drop_last") |>
  ungroup() |>
  mutate(from=edge1, to=edge2) |>
  relocate(from, to)


bn_members_nodes <-
bn_members_edges  |>
  pivot_longer(from:to, values_to = "person") |>
  distinct(person) |>
  inner_join(bn_person_list, by="person")  |>
  # number of societies, not n_event. nn for standard naming.
 # inner_join(
 #   bn_members_pairs |>
 # 	distinct(person=from, member) |>
 # 	count(person, name="nn"), by="person"
 # )
  inner_join(
    bn_members_pairs |>
      distinct(from, to, member) |>
      pivot_longer(c(from, to), values_to = "person") |>
      distinct(person, member) |> 
  	count(person, name="nn"), by="person"
  )

bn_members_network <-
  bn_tbl_graph(bn_members_nodes, bn_members_edges) |>
  filter(!node_is_isolated()) |>
  bn_centrality() |>
  bn_clusters()




# version uisng names instead of numerical ids, like the miserables example

bn_members_nodes_d3 <-
bn_members_network |>
  as_tibble() |>
  select(id=name, person, gender, year_birth, year_death, nn, degree, betweenness, eigenvector, harmonic, ends_with("_rank"), starts_with("grp")) |>
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



bn_members_edges_d3 <-
bn_members_network |>
  activate(edges) |>
  as_tibble() |>
  select(from=edge1, to=edge2, weight, edge_start, edge_end) |>
  left_join(bn_members_nodes_d3 |> distinct(source=id, from=person), by="from") |>
  left_join(bn_members_nodes_d3 |> distinct(target=id, to=person), by="to") |>
  relocate(source, target, from, to)

  


  
# put in named list ready to write_json  
bn_members_json <-
list(
     nodes= bn_members_nodes_d3,
     links= bn_members_edges_d3
     )    




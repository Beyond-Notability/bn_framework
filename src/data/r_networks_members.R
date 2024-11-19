# general functions for network analysis ####

# moved


## network specifics

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
  select(id=name, person, gender, year_birth, year_death, nn, degree, ends_with("_rank"), starts_with("grp")) |>
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




# general functions for network analysis ####
# moved


# family/teacher connections moved to r_networks_personal.R. must be loaded before the networks specifics.



# network specifics

bn_elections_sparql <-
  'select distinct ?personLabel ?proposerLabel ?qual_propLabel ?interactionLabel ?date ?person ?prop ?proposer ?qual_prop ?interaction ?s

where
{
  ?person bnwdt:P3 bnwd:Q3 .
  FILTER NOT EXISTS {?person bnwdt:P4 bnwd:Q12 .}  
  
  # proposed: sal p16 , rai p7, rhs p155.
  ?person ( bnp:P16 | bnp:P7 | bnp:P155 ) ?s .
     ?s (bnps:P16 | bnps:P7 | bnps:P155 ) ?proposer .
     ?s ?prop ?proposer .
     
  optional {
  # will this just be supporters? if so should probabl get them explicitly
     ?s ?qual_p ?interaction .   
     ?qual_prop wikibase:qualifier ?qual_p. 
        ?interaction bnwdt:P12 bnwd:Q2137 .
        FILTER NOT EXISTS {?interaction bnwdt:P4 bnwd:Q12 .} 
  } 
  
    optional {
      ?s bnpq:P1 ?date
      }
  
  SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en,en-gb". }
}
ORDER BY ?personLabel'


bn_elections_query <-
  bn_std_query(bn_elections_sparql) |>
  make_bn_item_id(person) |>
  make_bn_ids(c(proposer, interaction, qual_prop, prop, s)) |>
  mutate(across(c(qual_prop, qual_propLabel, prop, interaction, interactionLabel), ~na_if(., ""))) |>
  make_date_year() |>
  select(-person)



bn_sal_proposers <-
bn_elections_query |>
  filter(prop=="P16") |> 
  distinct(bn_id, personLabel, supporterLabel= proposerLabel, supporter= proposer, date, year, prop, s) |>
  #this should drop unnamed people? but it will keep named unknown gender
  semi_join(bn_gender, by=c("supporter"="person"))

bn_sal_signers <-
bn_elections_query |>
  filter(prop=="P16" & qual_prop=="P32") |>
  distinct(bn_id, personLabel, supporterLabel= interactionLabel, supporter= interaction, date, year, prop=qual_prop, s) |>
  # not named people
  filter(!supporter %in% c("Q2753", "Q17", "Q1587", "Q47")) |>
  semi_join(bn_gender, by=c("supporter"="person"))



# fsa and supporters per election
bn_sal_supporters_elections <-
  bind_rows(
    bn_sal_proposers,
    bn_sal_signers
  ) |>
  mutate(support= if_else(prop=="P16", "proposer", "signer")) |>
  rename(support_id=prop) |>
  # make a fsa+date id for each election
  mutate(f_election_id = paste(bn_id, date, sep="_"))




bn_sal_fsa_pairs <-
bn_sal_supporters_elections |>
  mutate(from = bn_id, f_name=personLabel) |>
  rename(from_name=personLabel, to=supporter, to_name=supporterLabel, f_id=bn_id) |>
  relocate(f_election_id)


bn_sal_supporters_pairs <-
bn_sal_supporters_elections |>
  rename(from=supporter, from_name= supporterLabel, f_name=personLabel, f_id=bn_id) |>
  inner_join(bn_sal_supporters_elections |>
               select(to=supporter, to_name=supporterLabel, f_election_id), by=c("f_election_id"), relationship = "many-to-many") |>
  filter(from!=to) |>
  relocate(f_election_id, from_name, from, to_name, to) |>
  arrange(f_election_id, from_name, to_name) 



bn_sal_pairs <-
bind_rows(
  bn_sal_fsa_pairs,
  bn_sal_supporters_pairs
) |>
  arrange(f_election_id, from, to) |>
  make_edge_ids() 






bn_sal_election_edges_v2 <-
  bn_sal_pairs |>
  distinct(edge_id, edge1, edge2, f_election_id, f_id, f_name, year) |> 
  group_by(edge1, edge2) |>
  summarise(weight=n(), edge_start_year=min(year), edge_end_year=max(year), .groups = "drop_last") |>
  ungroup() |>
  mutate(from=edge1, to=edge2) |>
  relocate(from, to)



bn_sal_election_nodes_v2 <-
bn_sal_election_edges_v2 |>
  pivot_longer(from:to, values_to = "person") |>
  distinct(person) |>
  inner_join(bn_person_list, by="person") |>
  inner_join(
    bn_sal_pairs |>
      distinct(from, to, f_election_id) |>
      pivot_longer(c(from, to), values_to = "person") |>
      distinct(person, f_election_id) |> 
  	count(person, name="nn"), by="person"
  )





bn_sal_election_network_v2 <-
bn_tbl_graph(bn_sal_election_nodes_v2, bn_sal_election_edges_v2) |>
  # adjusted to filter by number of elections rather than degree. this drops at least half the people.
  # but keep women
  # try again without the filter.
  #filter(nn>1  | gender=="woman") |>
  bn_centrality() |>
  bn_clusters()




# version uisng names instead of numerical ids, like the miserables example

bn_sal_nodes_d3 <-
bn_sal_election_network_v2 |>
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



bn_sal_edges_d3 <-
bn_sal_election_network_v2 |>
  activate(edges) |>
  as_tibble() |>
  select(from=edge1, to=edge2, weight, edge_start_year, edge_end_year) |>
  left_join(bn_sal_nodes_d3 |> distinct(source=id, from=person), by="from") |>
  left_join(bn_sal_nodes_d3 |> distinct(target=id, to=person), by="to") |>
  relocate(source, target, from, to)  |>
  left_join(connections_pairs, by=c("from"="edge1", "to"= "edge2")) |>
  # new function to make NAs "other"
  mutate(connection_type = na_to_other(connection_type))

  
# put in named list ready to write_json  
bn_sal_elections_json <-
list(
     nodes= bn_sal_nodes_d3,
     links= bn_sal_edges_d3
     )    


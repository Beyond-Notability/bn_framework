# doing distinct at the end might cause occasional glitch in binding but that should be easy to fix

bn_groups_pairs <-
  bind_rows(
    bn_rai_pairs |>
      mutate(group = "RAI elections") |>
      mutate(group_id = paste0("raielections_", f_election_id)) ,
    
    # bn_sal_pairs |>
    #   mutate(group_id = paste0("salelections_", f_election_id)) |>
    #   mutate(group = "SAL elections") ,
    
    bn_events_dated_pairs |>
      mutate(group_id = paste0("events_", event_instance_id)) |>
      mutate(group = "Events") ,
    
    bn_excavations_pairs |>
      mutate(group_id = paste0("excavations_", excavation)) |>
      mutate(group = "Excavations")
    
  ) |>
  distinct(edge1, edge2, group_id, group) |>
  arrange(edge1, edge2, group)

# remove pairs with weight=1 ? 
bn_groups_edges <-
bn_groups_pairs |>
  group_by(edge1, edge2) |>
  summarise(weight=n(), .groups = "drop_last") |>
  ungroup() |>
  # keep the original edge1 and edge2 rather than renaming
  mutate(from=edge1, to=edge2) |>
  relocate(from, to)  ## |>  filter(weight>1)

# use edges list to make nodes list
bn_groups_nodes <-
bn_groups_edges |>
  pivot_longer(from:to, values_to = "person") |>
  distinct(person) |>
  inner_join(bn_person_list, by="person") |>
    inner_join(
    bn_groups_pairs |>
      # probably don't need this... but just in case
      distinct(edge1, edge2, group_id, group) |>
      pivot_longer(c(edge1, edge2), values_to = "person") |>
      distinct(person, group_id, group) |> 
  	count(person, name="nnn"), by="person" 
    # but what exactly is nnn when you merge everything... doesn't work so well for education. and bearing in mind might be filtered.
  )

# because you kept edge1 and edge2 in edges filter is easy!
# do you need n_group?  just want to know which really, not counts.

# groups for nodes metadata
bn_groups_for_nodes_meta <-
bn_groups_pairs |>
  semi_join(bn_groups_edges, by=c("edge1", "edge2")) |>
  #count(edge1, edge2, group, name="n_group")
  distinct(edge1, edge2, group) |>
  pivot_longer(edge1:edge2, values_to = "person") |>
  distinct(person, group) |>
  # groups as a list-column
  group_by(person) |>
  arrange(group, .by_group = T) |>
  summarise(meta=list(group)) |>
  ungroup()


bn_groups_network <-
  bn_tbl_graph(bn_groups_nodes, bn_groups_edges) |>
  #filter(!node_is_isolated()) |> not needed if using bn_centrality
  bn_centrality() |>
  bn_clusters()


# version uisng names instead of numerical ids, like the miserables example

bn_groups_nodes_d3 <-
bn_groups_network |>
  as_tibble() |>
  rename(id=name) |>
  #add groups metadata
  left_join(bn_groups_for_nodes_meta, by="person") |>
  mutate(
    name_label = if_else(degree>3, id, NA), 
  	full_name=id) |>
  arrange(id)



bn_groups_edges_d3 <-
bn_groups_network |>
  activate(edges) |>
  as_tibble() |>
  select(from=edge1, to=edge2, weight) |>
  left_join(bn_groups_nodes_d3 |> distinct(source=id, from=person), by="from") |>
  left_join(bn_groups_nodes_d3 |> distinct(target=id, to=person), by="to") |>
  relocate(source, target, from, to)

  
# put in named list ready to write_json  
bn_grouped_json <-
list(
     nodes= bn_groups_nodes_d3,
     links= bn_groups_edges_d3
     )  

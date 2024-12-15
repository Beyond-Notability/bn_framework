
# family/teacher connections
# should this include men as well? perhaps should in case any reciprocation has been overlooked? but prioritise women.
# leave it for now.

connections_sparql <- 
'select distinct ?personLabel ?toLabel ?to_prop  ?p ?person ?to  ?s
where
{
  ?person bnwdt:P3 bnwd:Q3 .
  {
  ?person ?p ?s .
   ?s ( bnpq:P41 | bnpq:P42 | bnpq:P43 | bnpq:P44 | bnpq:P45 | bnpq:P46 | bnpq:P154 | bnpq:P137 | bnpq:P95 ) ?to . 
   ?s ?to_prop ?to .
  }
  union
  {
  ?person ( bnp:P41 | bnp:P42 | bnp:P43 | bnp:P44 | bnp:P45 | bnp:P46 | bnp:P154 | bnp:P137 | bnp:P95 ) ?s .
    ?s ( bnps:P41 | bnps:P42 | bnps:P43 | bnps:P44 | bnps:P45 | bnps:P46 | bnps:P154 | bnps:P137 | bnps:P95 ) ?to . 
    ?s ?to_prop ?to .
  }
   
  # drop unnamed spouses
  filter not exists { ?s ?to_prop bnwd:Q2753 .  }
  
  SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en,en-gb". }
}'
  
connections_query <-
  bn_std_query(connections_sparql) |>
  make_bn_ids(c(person, to, to_prop, p, s)) |>
  mutate(p = na_if(p, "")) |>
  left_join(bn_properties |> select(bn_prop_id, connection=propertyLabel), by=c("to_prop"="bn_prop_id"))

connections <-
connections_query |>
  mutate(connection_type=case_when(
    connection=="student of" ~ "education",
    connection %in% c("child", "father", "mother", "spouse", "sibling") ~ "family", 
    connection %in% c("parent-in-law", "relative", "significant relative") ~ "family", # less close family could potentially be separated out 
    .default = "other" # just in case you overlooked anything
  ))  


connections_pairs <-
  connections |>
  # dedup to distinct pairs
  mutate(from=person) |>
  make_edge_ids() |>
  distinct(edge1, edge2, connection_type) |>
  # top_n for a pair with mroe than one connection type
  group_by(edge1, edge2) |>
  # this should prefer family
  arrange(connection_type, .by_group = T) |>
  top_n(-1, row_number()) |>
  ungroup() |>
  arrange(edge1, edge2)
  

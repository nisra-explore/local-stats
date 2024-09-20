# read in and process census data


##### import and process long data #####
df_raw_data <- read_csv(data_file_name) %>%
  mutate(category = sub(" ", "", category))
# %>%
#   filter(topic %in% c("population", "households", "age", "mainlang", "cob"))


## work out totals for calculating percentages
df_data_summary <- df_raw_data %>%
  select(-geography) %>%
  group_by(geocode, topic, year) %>%
  summarise(total = sum(count))


df_data_value_perc <- merge(x = df_raw_data, y = df_data_summary, by = c("geocode", "topic", "year"), all = TRUE) %>%
  mutate(perc = count / total * 100) %>% # mutate(topic = case_when(topic == "sex" ~ "population", TRUE ~ topic)) %>%
  mutate(category = case_when(category == "all_usual_residents" ~ "all", TRUE ~ category))



## calculate the rank data for population variables only
df_population_rank <- df_data_value_perc %>%
  subset(topic == "population") %>%
  mutate(geog_level_for_rank = case_when(
    substr(geocode, 1, 2) == "95" ~ substr(geocode, 1, 2),
    substr(geocode, 1, 2) != "95" ~ substr(geocode, 1, 3)
  )) %>%
  group_by(geog_level_for_rank, category, year) %>%
  mutate(value_rank = rank(desc(count), ties.method = "min")) %>%
  ungroup(geog_level_for_rank, category, year) %>%
  select(-geog_level_for_rank, -count, -total, -geography, -perc)



## append on  rank data
df_data <- merge(x = df_data_value_perc, y = df_population_rank, by = c("geocode", "topic", "year", "category"), all.x = TRUE)

column_names <- colnames(df_data)

## get unique values of years and topics to loop around
for (i in 1:length(column_names)) {
  assign(paste0("v_", column_names[i]), unique(df_data[[i]]))
}


rm(v_count, v_category, v_geography, v_value_rank, v_perc)


v_topic

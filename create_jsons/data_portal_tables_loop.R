# Create a subset of data for specific geographic codes from the 'df_dp_all_values' dataframe
df_all_data_portal_subset <- df_dp_all_values %>%
  subset(geog_code == df_geog_codes_for_loop[i, 1] %>% pull()) %>% # Filter based on geographic code in current loop iteration
  arrange(desc(geog_code)) # Arrange in descending order of 'geog_code'

# Create a similar subset for percentage data
df_all_data_portal_subset_perc <- df_dp_all_perc %>%
  subset(geog_code == df_geog_codes_for_loop[i, 1] %>% pull()) %>% # Filter for percentage data
  arrange(desc(geog_code))

# Create a subset that includes Northern Ireland (geog_code "N92000002") for percentage data
df_all_data_portal_subset_incl_ni <- df_dp_all_perc %>%
  subset(geog_code == df_geog_codes_for_loop[i, 1] %>% pull() | geog_code == "N92000002") %>%
  mutate(geog_name = case_when(
    geog_code == "N92000002" ~ "Northern Ireland", # Rename if the code is for Northern Ireland
    TRUE ~ geog_name_loop
  )) %>%
  ungroup() %>% arrange(desc(geog_code))

# Process the subset data for each source and statistic combination
if (nrow(df_all_data_portal_subset) > 0) { # Check if subset data is not empty
  assign(paste0("v_", "source"), unique(df_all_data_portal_subset[["source"]])) # Store unique sources
  
  for (s in 1:length(v_source)) { # Loop through each unique source
    df_temp1 <- df_all_data_portal_subset %>% filter(source == v_source[s]) # Filter data by source
    
    assign(paste0("v_", "statistic_code"), unique(df_temp1[["statistic"]])) # Store unique statistics for each source
    
    for (t in 1:length(v_statistic_code)) { # Loop through each statistic code
      if (!is.na(v_statistic_code[t]) & !is.na(v_source[s])) { # Check for non-NA values
        # Format statistic code with backticks if it is numeric
        v_statistic_code_value <- if (!is.na(as.numeric(v_statistic_code[t]))) paste0("`", v_statistic_code[t], "`") else v_statistic_code[t]
        
        # Construct JSON path dynamically and assign value
        json_text <- paste0("df_json_template$data$", v_source[s], "$value$", v_statistic_code_value)
        data_value <- df_all_data_portal_subset %>%
          subset(source == v_source[s] & statistic == v_statistic_code[t]) %>%
          pull(VALUE)
        r_string <- paste0(json_text, " = ", as.character(data_value))
        eval(parse(text = r_string)) # Evaluate assignment to JSON template
      } else {
        json_text <- paste0("df_json_template$data$", v_source[s], "$value")
        data_value <- df_all_data_portal_subset %>%
          subset(source == v_source[s]) %>%
          pull(VALUE)
        
        r_string <- paste0(json_text, " = ", as.character(data_value))
        eval(parse(text = r_string))
      }
    }
  }
}

# Process percentage subset similarly for sources and statistics
if (nrow(df_all_data_portal_subset_perc) > 0) {
  assign(paste0("v_", "source"), unique(df_all_data_portal_subset_perc[["source"]]))
  
  for (s in 1:length(v_source)) {
    df_temp1 <- df_all_data_portal_subset_perc %>% filter(source == v_source[s])
    
    assign(paste0("v_", "statistic_code"), unique(df_temp1[["statistic"]]))
    
    for (t in 1:length(v_statistic_code)) {
      if (!is.na(v_statistic_code[t]) & !is.na(v_source[s])) {
        v_statistic_code_value <- if (!is.na(as.numeric(v_statistic_code[t]))) paste0("`", v_statistic_code[t], "`") else v_statistic_code[t]
        
        json_text <- paste0("df_json_template$data$", v_source[s], "$perc$", v_statistic_code_value)
        data_value <- df_all_data_portal_subset_perc %>%
          subset(source == v_source[s] & statistic == v_statistic_code[t]) %>%
          pull(perc)
        r_string <- paste0(json_text, " = ", as.character(data_value))
        eval(parse(text = r_string))
      } else {
        json_text <- paste0("df_json_template$data$", v_source[s], "$perc")
        data_value <- df_all_data_portal_subset_perc %>%
          subset(source == v_source[s]) %>%
          pull(perc)
        
        r_string <- paste0(json_text, " = ", as.character(data_value))
        eval(parse(text = r_string))
      }
    }
  }
}

# Sort metadata based on a defined order for geographic levels
df_meta_data <- df_meta_data %>%
  mutate(geog_level = factor(geog_level, levels = c('ni', 'lgd', 'dea', 'sdz', 'dz'))) %>%
  arrange(geog_level)

# Handle metadata differently based on the geographic type
if (geog_type_loop != "ni") { # Non-Northern Ireland metadata handling
  df_temp2 <- df_meta_data %>%
    filter(geog_level == geog_type_loop)
  
  assign("v_datasets", unique(df_temp2[["dataset"]]))
  for (d in 1:length(v_datasets)) {
    json_text <- paste0(
      "df_json_template$meta_data$", v_datasets[d],
      " = ",
      "df_temp2 %>% filter(dataset =='", v_datasets[d],
      "') %>%  select(table_code, dataset_url, geog_level, last_updated, email, title, year)"
    )
    eval(parse(text = json_text)) # Evaluate assignment
  }
} else { # Handle Northern Ireland metadata
  assign("v_datasets", unique(df_meta_data[["dataset"]]))
  for (d in 1:length(v_datasets)) {
    json_text <- paste0(
      "df_json_template$meta_data$", v_datasets[d],
      " = ",
      "df_meta_data %>% filter(dataset =='", v_datasets[d],
      "') %>%  select(table_code, dataset_url, geog_level, last_updated, email, title, year) %>% head(1)"
    )
    eval(parse(text = json_text)) # Evaluate assignment for NI-specific metadata
  }
}

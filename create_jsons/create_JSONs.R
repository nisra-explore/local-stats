# Load configuration settings
source("create_jsons/config.R")

# Load and process census data
print("processing census data")
source("create_jsons/read_and_process_census_data.R")

# Load and process data portal tables
print("processing data portal tables")
source("create_jsons/read_all_dataportal_tables_in.R")

#### Set up loop for geographies ####
# Select geographic codes for loop processing, based on the list 'v_geocode' and 'geog_types_to_update'
df_geog_codes_for_loop <- df_children %>%
  subset(code %in% v_geocode) %>%
  select(code, name) %>%
  mutate(type = case_when(
    substr(code, 1, 3) == "N92" ~ "ctry", # Country
    substr(code, 1, 3) == "N09" ~ "lgd",  # Local government district
    substr(code, 1, 3) == "N10" ~ "dea",  # District electoral area
    substr(code, 1, 3) == "N20" ~ "dz",   # Data zone
    substr(code, 1, 3) == "N21" ~ "sdz"   # Super data zone
  )) %>%
  filter(type %in% geog_types_to_update) %>% # Filter only required types
 # filter(type %in% c('ctry', 'lgd')) %>% # Filter only required types
  arrange(substr(code, 1, 3)) # Order by code prefix

print("looping through geographies")
# Loop through each geographic code in 'df_geog_codes_for_loop'
for (i in 1:nrow(df_geog_codes_for_loop)) {
  
  #### Load JSON template ####
  json_template_filename <- paste0(data_source_root, "json_template/template - main_no_data.json")
  df_json_template <- read_json(json_template_filename, simplifyVector = TRUE)
  
  # Extract current geography code, name, and type for this iteration
  geog_code_loop <- df_geog_codes_for_loop[i, 1] %>% pull()
  geog_name_loop <- df_geog_codes_for_loop[i, 2] %>% pull()
  geog_type_loop <- df_geog_codes_for_loop[i, 3] %>% pull()
  
  # Set type to 'ni' if the code is for Northern Ireland
  if (substr(geog_code_loop, 1, 3) == "N92") {
    geog_type_loop <- "ni"
  }
  
  print("preparing data for ..... ")
  print(paste0(geog_code_loop, " - ", geog_name_loop, " - ", i))
  
  #### Set JSON template values ####
  
  ##### Basic Information #####
  # Assign basic information for the current geographic area
  df_json_template$name <- geog_name_loop
  df_json_template$code <- geog_code_loop
  df_json_template$type <- geog_type_loop
  df_json_template$count <- df_geog_levels %>%
    subset(geog_code == geog_type_loop) %>%
    select(number) %>%
    pull()
  df_json_template$hectares <- df_hectares %>%
    subset(geocode == geog_code_loop) %>%
    select(Area_ha) %>%
    round() %>%
    pull()
  df_json_template$comment <- "This JSON includes data for the area explorer app."
  
  ##### Geographic Boundaries #####
  # Set geographic boundaries using coordinates
  df_json_template$bounds[1, 1] <- df_map_bounds %>%
    subset(geog_code == geog_code_loop) %>%
    select(long_max) %>%
    pull()
  df_json_template$bounds[1, 2] <- df_map_bounds %>%
    subset(geog_code == geog_code_loop) %>%
    select(lat_min) %>%
    pull()
  df_json_template$bounds[2, 1] <- df_map_bounds %>%
    subset(geog_code == geog_code_loop) %>%
    select(long_min) %>%
    pull()
  df_json_template$bounds[2, 2] <- df_map_bounds %>%
    subset(geog_code == geog_code_loop) %>%
    select(lat_max) %>%
    pull()
  
  ##### Children Data #####
  # Include child regions within the current geographic area
  df_json_template$children <- df_children %>%
    subset(parentcode == geog_code_loop) %>%
    select(-parentcode) %>%
    mutate(type = case_when(
      substr(code, 1, 3) == "N92" ~ "ctry",
      substr(code, 1, 3) == "N09" ~ "lgd",
      substr(code, 1, 3) == "N10" ~ "dea",
      substr(code, 1, 3) == "N20" ~ "dz",
      substr(code, 1, 3) == "N21" ~ "sdz"
    )) %>%
    arrange(name)
  
  ##### Parent Data #####
  # Determine parent areas based on hierarchy; only applies if code is not 'N92' (Northern Ireland)
  if (substr(geog_code_loop, 1, 3) != "N92") {
    df_loop_parent1 <- df_children %>%
      subset(code == geog_code_loop) %>%
      select(parentcode)
    # Further levels of parents
    df_loop_parent2 <- df_children %>%
      subset(code %in% df_loop_parent1$parentcode) %>%
      select(parentcode)
    df_loop_parent3 <- df_children %>%
      subset(code %in% df_loop_parent2$parentcode) %>%
      select(parentcode)
    df_loop_parent4 <- df_children %>%
      subset(code %in% df_loop_parent3$parentcode) %>%
      select(parentcode)
    
    df_loop_parents <- rbind(
      df_loop_parent1, df_loop_parent2, df_loop_parent3, df_loop_parent4
    ) %>%
      mutate(rowid = row_number()) %>%
      subset(!is.na(parentcode)) %>%
      rename(code = parentcode) %>%
      merge(df_children %>% select(code, name), by = "code", all.x = TRUE) %>%
      mutate(type = case_when(
        substr(code, 1, 3) == "N92" ~ "ctry",
        substr(code, 1, 3) == "N09" ~ "lgd",
        substr(code, 1, 3) == "N10" ~ "dea",
        substr(code, 1, 3) == "N20" ~ "dz",
        substr(code, 1, 3) == "N21" ~ "sdz"
      )) %>%
      arrange(rowid) %>%
      select(-rowid)
    
    df_json_template$parents <- df_loop_parents
  } else {
    # If Northern Ireland, set a default empty parent list
    df_json_template$parents <- list(list(code = "", name = "", type = ""))
    df_json_template$type <- "ni"
    df_json_template$count <- 1
  }
  
  ##### Location Descriptions #####
  # Additional data based on specific geographies
  if (substr(geog_code_loop, 1, 3) == "N09") {
    df_json_template$lgd_location_description <- df_lgd_description %>%
      subset(geog_code == geog_code_loop) %>%
      select(geog_location) %>%
      pull()
  }
  
  # Additional text data based on source and geography type
  if (substr(geog_code_loop, 1, 3) == "N09") {
    df_json_template$data$crime$text <- df_dp_all_text %>%
      subset(geog_code == geog_code_loop & source == "crimeworry") %>%
      select(reason) %>%
      pull()
    df_json_template$data$env_problem$text <- df_dp_all_text %>%
      subset(geog_code == geog_code_loop & source == "Env_problem") %>%
      select(reason) %>%
      pull()
  }
  if (substr(geog_code_loop, 1, 3) == "N10") {
    df_json_template$dea_location_description <- df_dea_description %>%
      subset(geog_code == geog_code_loop) %>%
      select(geog_location) %>%
      pull()
    df_json_template$data$Admiss$text <- df_dp_all_text %>%
      subset(geog_code == geog_code_loop & source == "Admiss") %>%
      select(reason) %>%
      pull()
  }
  if (substr(geog_code_loop, 1, 3) == "N92") {
    df_json_template$data$Admiss$text <- df_dp_all_text %>%
      subset(geog_code == geog_code_loop & source == "Admiss") %>%
      select(reason) %>%
      pull()
    df_json_template$data$crime$text <- df_dp_all_text %>%
      subset(geog_code == geog_code_loop & source == "crimeworry") %>%
      select(reason) %>%
      pull()
    df_json_template$data$env_problem$text <- df_dp_all_text %>%
      subset(geog_code == geog_code_loop & source == "Env_problem") %>%
      select(reason) %>%
      pull()
  }
  
  # Load additional census and data portal scripts for the loop
  source("create_jsons/census_data_loop.R")
  source("create_jsons/data_portal_tables_loop.R")
  
  # Prepare output file path and name
  output_filename <- paste0(outputs_directory, geog_code_loop, ".json")
  print(output_filename) # Print file path for progress
  
  # Write JSON file
  write_json(df_json_template, output_filename, pretty = TRUE, simplifyVector = TRUE, auto_unbox = TRUE)
}

# Record the date of the last run
write_rds(data.frame(date = as.Date(Sys.time())),
          "create_jsons/date_of_last_run.RDS")

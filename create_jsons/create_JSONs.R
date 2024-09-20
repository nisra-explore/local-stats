
source("create_jsons/config.R")

# source("prep_le_data_portal_data.R")
# source("prep_dental_data_portal_data.R")

print("processing census data")
source("create_jsons/read_and_process_census_data.R")

print("processing data portal tables")
source("create_jsons/read_all_dataportal_tables_in.R")

#### set-up  loop ####
df_geog_codes_for_loop <-
  df_children %>%
  subset(code %in% v_geocode) %>%
  select(code, name) %>%
  mutate(type = case_when(
    substr(code, 1, 3) == "N92" ~ "ctry",
    substr(code, 1, 3) == "N09" ~ "lgd",
    substr(code, 1, 3) == "N10" ~ "dea",
    substr(code, 1, 3) == "N20" ~ "dz",
    substr(code, 1, 3) == "N21" ~ "sdz"
  )) %>%
 filter(type %in% geog_types_to_update) %>%
#filter(type %in% c('ctry', 'lgd', 'dea')) %>%
  arrange(substr(code, 1, 3))# %>% head(1)
 
 
 print("looping through geographies")
## for(i in 1:100){
for (i in 1:nrow(df_geog_codes_for_loop)) {
  #### Read in json template ####
  json_template_filename <- paste0(data_source_root, "json_template/template - main_no_data.json")
  df_json_template <- read_json(json_template_filename, simplifyVector = TRUE)


  geog_code_loop <- df_geog_codes_for_loop[i, 1] %>% pull()
  geog_name_loop <- df_geog_codes_for_loop[i, 2] %>% pull()
  geog_type_loop <- df_geog_codes_for_loop[i, 3] %>% pull()

  if (substr(geog_code_loop, 1, 3) == "N92") {
    geog_type_loop <- "ni"
  }



  print("preparing data for ..... ")
  print(paste0(geog_code_loop, " - ", geog_name_loop, " - ", i))


  #### set json values ####

  ##### codes and names #####
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

  #* change content for this
  df_json_template$comment <- "This JSON includes data for the area explorer app."


  ##### bounds #####


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



  ##### children #####


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


  ##### parents #####


  if (substr(geog_code_loop, 1, 3) != "N92") {
    ## fix number of parents depending of geog selected

    df_loop_parent1 <- df_children %>%
      subset(code == geog_code_loop) %>%
      select(parentcode)
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
    df_json_template$parents <- list(list(code = "", name = "", type = ""))
    df_json_template$type <- "ni"
    df_json_template$count <- 1
  }

  
  if (substr(geog_code_loop, 1, 3) == "N09") {
    df_json_template$lgd_location_description <- df_lgd_description %>%
      subset(geog_code == geog_code_loop) %>%
      select(geog_location) %>%
      pull()
  }
  
  

  if (substr(geog_code_loop, 1, 3) == "N09" ) {
    
    df_json_template$data$crime$text <- df_dp_all_text %>%
      subset(geog_code == geog_code_loop & source == "crimeworry") %>%
      select(reason) %>%
      pull()
  }    

  if (substr(geog_code_loop, 1, 3) == "N09" ) {
    
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
  source("create_jsons/census_data_loop.R")
  source("create_jsons/data_portal_tables_loop.R")



  # prepare output file name and path
  output_filename <- paste0(outputs_directory, geog_code_loop, ".json")

  # print file name - in console for progress
  print(output_filename)
  #
  #   #write file
  write_json(df_json_template, output_filename, pretty = TRUE, simplifyVector = TRUE, auto_unbox = TRUE)
  #
}
#
#

 write_rds(data.frame(date = as.Date(Sys.time())),
          "create_jsons/date_of_last_run.RDS")

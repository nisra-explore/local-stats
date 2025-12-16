## config ##

#### install packages ####

suppressWarnings(if(!require(pacman)) install.packages("pacman"))
library(pacman)
p_load("dplyr", # was going to be used for the 2 column - don't think used anymore
       "openxlsx", 
       "readxl",
       "rjson",
       "jsonlite",
       "janitor",
       "gtools",
       "httr",
       "stringr",
       "readr",
       "tidyr") 



## prep benefits statistics

fn_rename = function(dataframe, lookup) {
  
  
  lookup = lookup[names(lookup) != ""]
  dataframe = dataframe %>%
    rename(any_of(lookup))
  
  lookup = tolower(lookup)
  
  lookup = lookup[names(lookup) != ""]
  dataframe = dataframe %>%
    rename(any_of(lookup))
  
}



#### set-up folders & file names ####
data_source_root <- "create_jsons/inputs/"
outputs_directory <- "github_action_jsons/"
geog_file_name = "geog_data_withdz_and_area2.xlsx"
data_file_name ="create_jsons/inputs/long_table_withdz_v1.csv"


# if outputs folder doesn't exist create it
if (!dir.exists(outputs_directory)) {
  dir.create(outputs_directory)
} else {
  print("JSON outputs folder exists already")
}

#### function to move the topics in correct order ####

move_population_households <- function(x) {
  population_index <- which(x == "population")
  households_index <- which(x == "households")
  original_first = x[1]
  original_second = x[2]
  x[c(1,2)] <- x[c(population_index, households_index)]
  x[population_index] = original_first
  x[households_index] = original_second
  return(x)
}


#### Read in data ####

##### Geography levels  #####
df_geog_levels = read_excel(paste0(data_source_root,geog_file_name), 
                            sheet = "Number of Geogs", 
                            skip = 0)


#* check should be 8 obs

##### import geog hierarchy for children and parents #####
# df_children = read_excel(paste0(data_source_root,geog_file_name), 
#                          sheet = "ParentChild", 
#                          skip = 0) %>% 
# #  mutate(ChildName = gsub("_"," ",ChildName))%>% 
#   mutate(ChildName = str_to_title(ChildName))%>% 
#   mutate(ChildName = gsub(" And "," and ",ChildName)) %>%
#   rename(code =ChildCode, name = ChildName, parentcode = ParentCode)## %>% 
# ##  subset(substr(code,1,3) %in% c("N92", "N09"))

df_children = read_excel(paste0(data_source_root,geog_file_name), 
                         sheet = "ParentChild", 
                         skip = 0) %>% 
  #  mutate(ChildName = gsub("_"," ",ChildName))%>% 
  mutate(ChildName = case_when(grepl("_",ChildName) ~ ChildName,
                               TRUE ~ gsub(" And "," and ",str_to_title(ChildName)))) %>%
  rename(code =ChildCode, name = ChildName, parentcode = ParentCode) 

##%>%
  ##filter(substring(code,1,3) %in% c('N92','N10','N09'))



##### import map bounds #####
df_map_bounds = read_excel(paste0(data_source_root,geog_file_name),
                           sheet = "MapBounds", 
                           skip = 0) %>% rename(geog = "...1") 




##### import hectares  #####
df_hectares = read_excel(paste0(data_source_root,geog_file_name),
                         sheet = "geog_areas", 
                         skip = 0) 

df_dea_description = read_excel(paste0(data_source_root,geog_file_name),
                                sheet = "dea_description", 
                                skip = 0)

df_lgd_description = read_excel(paste0(data_source_root,geog_file_name),
                                sheet = "lgd_description", 
                                skip = 0)

# Turn easier read URL queries to valid URLs
transform_URL <- function(URL) {
  
  URL %>%
    gsub(" ", "", .) %>%
    gsub('"', "%22", .) %>%
    gsub("\\{", "%7B", .) %>%
    gsub("\\}", "%7D", .) %>%
    gsub("\\[", "%5B", .) %>%
    gsub("\\]", "%5D", .) %>%
    gsub("\\n", "", .) %>%
    gsub("\\t", "", .)
  
}

json_data_from_rpc <- function (query) {
  jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.jsonrpc?data=',
   query))
  )$result
}
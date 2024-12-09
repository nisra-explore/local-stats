  # This R script is structured to process and collate data from the NISRA data portal API, 
  # transforming it into various data frames for reporting purposes. 
  # Below are detailed comments explaining the key sections and operations within the script.
  
  
  
  #source("create_jsons/config.R")
  
  df_meta_data <- data.frame()
  
  # Read in script to extract names of tables needed
  this_script <- read_lines("create_jsons/read_all_dataportal_tables_in.R") %>% .[17:length(.)]
  
  tables_needed <- this_script[grepl("dataset_long <-", this_script)] %>% gsub("dataset_long <- ", "", ., fixed = TRUE) %>% 
    gsub('"', "", ., fixed = TRUE) %>%
    gsub(' ', "", ., fixed = TRUE) %>%
    unique()
  
  # All metadata from data portal read in:
  data_portal <- jsonlite::fromJSON(txt = "https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.ReadCollection")$link$item
  
  matrices <- data_portal$extension$matrix
  years <- data_portal$dimension$`TLIST(A1)`$category$index
  updated <- data_portal$updated
  
  titles <- c()
  updates <- c()
  id_cols <- c()
  
  
  for (i in 1:length(tables_needed)) {
    
    titles[i] <- data_portal$label[which(matrices == tables_needed[i])]
    updates[i] <- substr(updated[which(matrices == tables_needed[i])], 1, 10)
    id_cols[i] <- paste(data_portal$id[[which(matrices == tables_needed[i])]], collapse = "; ") %>%
      gsub("TLIST(A1); STATISTIC; ", "", ., fixed = TRUE)
    
    
  }
  
  updates_table <- data.frame(table = tables_needed,
                              title = titles,
                              updated = as.Date(updates),
                              id_cols = id_cols)
  
  date_of_last_run <- readRDS("create_jsons/date_of_last_run.RDS")
  
  ## Example date for testing
  # date_of_last_run$date <- as.Date("2024-04-10")
  
  tables_with_updates <- updates_table %>%
    filter(updated >= date_of_last_run$date)
  
  geog_types_to_update <- c("ctry")
  
  for (geog_type in c("dea", "lgd", "sdz", "dz")) {
    
    for (id in tables_with_updates$id_cols) {
      if (substr(id, 1, nchar(geog_type)) == toupper(geog_type)) {
        geog_types_to_update <- c(geog_types_to_update, geog_type)
        break
      }
    }
    
  }
  
  
  #### Population ####
  
  ##### MYEs #####
  ##### population, totals
  df_pop <- list()
  
  dataset_short <- "MYETotal"
  dataset_subject <- "5/MYE"
  
  ##### MYE by LGD #####
  dataset_long <- "MYE01T06"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "rounded_unrounded", "selection": {"filter": "item", "values": ["Unrounded"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long,
    "year" = latest_year,
    "geog_level" = "lgd",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", dataset_long),
    "last_updated" = format(substring(updated[which(matrices == dataset_long)], 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = data_portal$label[which(matrices == dataset_long)],
    "note" = json_data$note
  )))
  
  data <- data.frame(geog_code = json_data$dimension$LGD2014$category$index,
                     VALUE = json_data$value,
                     source = dataset_short)
  
  df_pop <- rbind(df_pop, data)
  
  ##### MYE by Data Zone #####
  dataset_long <- "MYE01T011"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "dz",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", dataset_long),
    "last_updated" = format(substring(updated[which(matrices == dataset_long)], 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = data_portal$label[which(matrices == dataset_long)],
    "note" = json_data$note
  )))
  
  data <- data.frame(geog_code = json_data$dimension$DZ2021$category$index,
                     VALUE = json_data$value,
                     source = dataset_short) %>%
    filter(geog_code != "N92000002")
  
  df_pop <- rbind(df_pop, data)
  
  ##### MYE by Super Data Zone #####
  dataset_long <- "MYE01T012"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "Sex", "selection": {"filter": "item", "values": ["All"]}},',
      '{"code": "broadage4", "selection": {"filter": "item", "values": ["All"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "sdz",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", dataset_long),
    "last_updated" = format(substring(updated[which(matrices == dataset_long)], 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = data_portal$label[which(matrices == dataset_long)],
    "note" = json_data$note
  )))
  
  data <- data.frame(geog_code = json_data$dimension$SDZ2021$category$index,
                     VALUE = json_data$value,
                     source = dataset_short) %>%
    filter(geog_code != "N92000002")
  
  df_pop <- rbind(df_pop, data)
  
  ##### MYE by DEA ####
  dataset_long <- "MYE01T010"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "Sex", "selection": {"filter": "item", "values": ["All"]}},',
      '{"code": "broadage4", "selection": {"filter": "item", "values": ["All"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "dea",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", dataset_long),
    "last_updated" = format(substring(updated[which(matrices == dataset_long)], 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = data_portal$label[which(matrices == dataset_long)],
    "note" = json_data$note
  )))
  
  data <- data.frame(geog_code = json_data$dimension$DEA2014$category$index,
                     VALUE = json_data$value,
                     source = dataset_short) %>%
    filter(geog_code != "N92000002")
  
  df_pop <- rbind(df_pop, data)
  df_pop <- unique(df_pop)
  
  ##### median age ####
  dataset_short <- "Median"
  
  dataset_long <- "MA01T02"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "Sex", "selection": {"filter": "item", "values": ["All"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "lgd",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", dataset_long),
    "last_updated" = format(substring(updated[which(matrices == dataset_long)], 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = data_portal$label[which(matrices == dataset_long)],
    "note" = json_data$note
  )))
  
  data <- data.frame(geog_code = json_data$dimension$LGD2014$category$index,
                     VALUE = json_data$value,
                     source = dataset_short)
  
  df_pop <- rbind(df_pop, data)
  
  
  
  ##### age band ####
  df_popage <- list()
  dataset_short <- "BroadAge"
  
  dataset_long <- "MYE01T012"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "Sex", "selection": {"filter": "item", "values": ["All"]}},',
      '{"code": "broadage4", "selection": {"filter": "item", "values": ["1", "2", "3", "4"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "sdz",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", dataset_long),
    "last_updated" = format(substring(updated[which(matrices == dataset_long)], 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = data_portal$label[which(matrices == dataset_long)],
    "note" = json_data$note
  )))
  
  categories <- unlist(json_data$dimension$broadage4$category$label)
  
  data <- data.frame(geog_code = sort(rep(json_data$dimension$SDZ2021$category$index, length(categories)))) %>%
    mutate(statistic = rep_len(categories, nrow(.)),
           VALUE = json_data$value,
           source = dataset_short) %>%
    group_by(geog_code) %>%
    mutate(perc = VALUE / sum(VALUE) * 100) %>%
    filter(geog_code != "N92000002")
  
  df_popage <- rbind(df_popage, data)
  
  ##### Age band by LGD ####
  dataset_long <- "MYE01T04"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "Sex", "selection": {"filter": "item", "values": ["All"]}},',
      '{"code": "broadage4", "selection": {"filter": "item", "values": ["1", "2", "3", "4"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "lgd",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", dataset_long),
    "last_updated" = format(substring(updated[which(matrices == dataset_long)], 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = data_portal$label[which(matrices == dataset_long)],
    "note" = json_data$note
  )))
  
  categories <- unlist(json_data$dimension$broadage4$category$label)
  
  data <- data.frame(geog_code = sort(rep(json_data$dimension$LGD2014$category$index, length(categories)))) %>%
    mutate(statistic = rep_len(categories, nrow(.)),
           VALUE = json_data$value,
           source = dataset_short) %>%
    group_by(geog_code) %>%
    mutate(perc = VALUE / sum(VALUE) * 100)
  
  df_popage <- rbind(df_popage, data)
  
  dataset_long <- "MYE01T010"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "Sex", "selection": {"filter": "item", "values": ["All"]}},',
      '{"code": "broadage4", "selection": {"filter": "item", "values": ["1", "2", "3", "4"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "dea",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", dataset_long),
    "last_updated" = format(substring(updated[which(matrices == dataset_long)], 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = data_portal$label[which(matrices == dataset_long)],
    "note" = json_data$note
  )))
  
  categories <- unlist(json_data$dimension$broadage4$category$label)
  
  csv_data = read.csv(paste0("https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.ReadDataset/",dataset_long,"/CSV/1.0/")) %>%
    filter(`TLIST.A1.` == latest_year & Sex == "All") %>%
    mutate(statistic = `Broad.age.band..4.cat.`) %>%
  select(DEA2014, statistic, VALUE) %>% group_by(DEA2014, statistic) %>% 
       summarise(VALUE = sum(VALUE, na.rm = TRUE)) %>% 
       rename(geog_code = DEA2014, statistic = statistic) %>% 
    group_by(geog_code) %>%
    mutate(perc = VALUE / VALUE[statistic == "All"] *100,
           source = dataset_short) %>% 
    filter(statistic != "All")
  
    
    
  data <- data.frame(geog_code = sort(rep(json_data$dimension$DEA2014$category$index, length(categories)))) %>%
    mutate(statistic = rep_len(categories, nrow(.)),
           VALUE = json_data$value,
           source = dataset_short) %>%
    group_by(geog_code) %>%
    mutate(perc = VALUE / sum(VALUE) * 100) %>%
    filter(geog_code != "N92000002")
  
  df_popage <- rbind(df_popage, csv_data)
  
  df_popage <- unique(df_popage)
  ##### population growth ####
  df_popchange <- list()
  dataset_short <- "PopChange"
  
  dataset_long <- "MYE01T06"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "rounded_unrounded", "selection": {"filter": "item", "values": ["Unrounded"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "lgd",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  data_years <- years[[which(matrices == dataset_long)]]
  
  data <- data.frame(geog_code = rep(json_data$dimension$LGD2014$category$index, length(data_years)),
                     VALUE = json_data$value) %>%
    mutate(statistic = sort(rep_len(data_years, nrow(.))),
           source = dataset_short)
  
  df_popchange <- rbind(df_popchange, data)
  
  
  ##### house prices  ##### 
  df_lps <- list()
  dataset_subject <- "95/NIHPI"
  dataset_long <- "LPSHPI01"
  #latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  
  latest_year <- data_portal$dimension$`TLIST(Q1)`$category$index[[which(matrices == dataset_long)]] %>% tail(1)
  
  dataset_short <- "houseprices"
  
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(Q1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "lgd",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  
  categories <- factor(json_data$dimension$STATISTIC$category$index,
                       levels = json_data$dimension$STATISTIC$category$index)
  
  data <- data.frame(geog_code = rep(json_data$dimension$LGD2014$category$index, length(categories))) %>%
    mutate(statistic = sort(rep_len(categories, nrow(.))),
           VALUE = json_data$value,
           source = dataset_short)
  
  df_lps = rbind(df_lps, data)
  
  #### Health ####
  ##### LE #####
  ###### LE by DEA ######
  df_le <- list()
  dataset_short <- "LE"
  dataset_subject <- "8/HILEGH"
  
  dataset_long <- "LEDEA"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "dea",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  categories <- unlist(json_data$dimension$SEX$category$label)
  
  data <- data.frame(geog_code = sort(rep(json_data$dimension$DEA2014$category$index, length(categories)))) %>%
    mutate(statistic = rep_len(categories, nrow(.)),
           VALUE = json_data$value,
           source = dataset_short)
  
  df_le <- rbind(df_le, data)
  ###### LE by LGD ######
  dataset_long <- "LELGD"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "lgd",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  categories <- unlist(json_data$dimension$SEX$category$label)
  
  
  data <- data.frame(geog_code = sort(rep(json_data$dimension$LGD2014$category$index, length(categories)))) %>%
    mutate(statistic = rep_len(categories, nrow(.)),
           VALUE = json_data$value,
           source = dataset_short)
  
  df_le <- unique(rbind(df_le, data))
  
  
  
  
  
  ##### Happiness #####
  
  dataset_subject <- "96/PW"
  
  dataset_long <- "WBPERSWLGD"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  dataset_short <- "wellbeing"
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "STATISTIC", "selection": {"filter": "item", "values": ["WBLIFE", "WBHAP"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "lgd",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  categories <- factor(json_data$dimension$STATISTIC$category$index,
                       levels = json_data$dimension$STATISTIC$category$index)
  
  data <- data.frame(geog_code = rep(json_data$dimension$LGD2014$category$index, length(categories))) %>%
    mutate(STATISTIC = sort(rep_len(categories, nrow(.))),
           VALUE = json_data$value)
  
  
  dataset_long <- "WBPERSWOTHR"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "STATISTIC", "selection": {"filter": "item", "values": ["WBLIFE", "WBHAP"]}},',
      '{"code": "OTHRCAT", "selection": {"filter": "item", "values": ["N92000002"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  data_ni <- data.frame(geog_code = "N92000002",
                        STATISTIC = json_data$dimension$STATISTIC$category$index,
                        VALUE = json_data$value)
  
  data_both = rbind(data, data_ni)
  
  df_happy = data_both %>% filter(STATISTIC == "WBHAP") %>% 
    mutate(source = "Happy") %>% select(geog_code, VALUE, source)
  
  df_satisfy = data_both %>% filter(STATISTIC == "WBLIFE") %>% 
    mutate(source = "Satisfy") %>% select(geog_code, VALUE, source)
  
  
  
  
  ##### Loneliness #####
  
  dataset_subject <- "96/LONEL"
  
  dataset_long <- "WBLONLGD"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  dataset_short <- "lonely"
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "STATISTIC", "selection": {"filter": "item", "values": ["WBLON"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "lgd",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  categories <- factor(json_data$dimension$STATISTIC$category$index,
                       levels = json_data$dimension$STATISTIC$category$index)
  
  data <- data.frame(geog_code = rep(json_data$dimension$LGD2014$category$index, length(categories))) %>%
    mutate(STATISTIC = sort(rep_len(categories, nrow(.))),
           VALUE = json_data$value)
  
  
  dataset_long <- "WBLONOTHR"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "STATISTIC", "selection": {"filter": "item", "values": ["WBLON"]}},',
      '{"code": "OTHRCAT", "selection": {"filter": "item", "values": ["N92000002"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  data_ni <- data.frame(geog_code = "N92000002",
                        STATISTIC = json_data$dimension$STATISTIC$category$index,
                        VALUE = json_data$value)
  
  data_both = rbind(data, data_ni)
  
  df_lonely = data_both %>% 
    mutate(source = "Lonely") %>% select(geog_code, VALUE, source)
  
  
  
  
  ##### Hospital attendance #####
  ##### number and top reason
  df_admissions_all <- list()
  df_admissions_top <- list()
  
  dataset_subject <- "70/HAS"
  
  dataset_long <- "ADMITDEA"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  dataset_short <- "Admiss"
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "dea",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  pdiag <- json_data$dimension$PDIAG$category$index
  reason <- unlist(json_data$dimension$PDIAG$category$label)
  
  data <- data.frame(geog_code = sort(rep(json_data$dimension$DEA2014$category$index, length(pdiag))),
                     VALUE = json_data$value) %>%
    mutate(PDIAG = rep_len(pdiag, nrow(.)),
           reason = rep_len(reason, nrow(.)),
           source = dataset_short)
  
  
  data_all <- data %>%
    filter(PDIAG == "All") %>%
    select(geog_code, VALUE) %>%
    mutate(source = dataset_short)
  
  data_top <- data %>%
    filter(PDIAG != "All") %>%
    group_by(geog_code) %>%
    slice_max(order_by = VALUE, n = 1) %>%
    select(geog_code, reason) %>%
    mutate(source = dataset_short)
  
  
  df_admissions_all <- rbind(df_admissions_all, data_all)
  df_admissions_top <- rbind(df_admissions_top, data_top)
  
  ##### GPs, Dentists #####
  
  df_gps <- list()
  
  dataset_subject <- "66/GMS"
  
  dataset_long <- "GPPRACPATLGD"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  dataset_short <- "GP"
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "STATISTIC", "selection": {"filter": "item", "values": ["PRACS", "GPS", "REGPAT", "PRACLIST"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "lgd",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  categories <- factor(json_data$dimension$STATISTIC$category$index,
                       levels = json_data$dimension$STATISTIC$category$index)
  
  data <- data.frame(geog_code = rep(json_data$dimension$LGD2014$category$index, length(categories)),
                     VALUE = json_data$value) %>%
    mutate(statistic = sort(rep_len(categories, nrow(.))),
           source = dataset_short)
  
  df_gps <- rbind(df_gps, data)
  
  
  dataset_subject <- "66/GMS"
  
  dataset_long <- "GPPRACPATDEA"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  dataset_short <- "GP"
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "STATISTIC", "selection": {"filter": "item", "values": ["PRACS", "GPS", "REGPAT", "PRACLIST"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "dea",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  categories <- factor(json_data$dimension$STATISTIC$category$index,
                       levels = json_data$dimension$STATISTIC$category$index)
  
  data <- data.frame(geog_code = rep(json_data$dimension$DEA2014$category$index, length(categories)),
                     VALUE = json_data$value) %>%
    mutate(statistic = sort(rep_len(categories, nrow(.))),
           source = dataset_short)
  
  df_gps <- rbind(df_gps, data)
  
  
  
  
  
  df_dental <- list()
  dataset_short <- "DEN"
  dataset_subject <- "66/GDS"
  
  dataset_long <- "FPSGDSDSDEA"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "dea",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  categories <- factor(json_data$dimension$STATISTIC$category$index,
                       levels = json_data$dimension$STATISTIC$category$index)
  
  data <- data.frame(geog_code = rep(json_data$dimension$DEA2014$category$index, length(categories))) %>%
    mutate(statistic = sort(rep_len(categories, nrow(.))),
           VALUE = json_data$value,
           source = dataset_short)
  
  df_dental <- rbind(df_dental, data)
  
  
  
  
  dataset_long <- "FPSGDSDSLGD"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "lgd",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  categories <- factor(json_data$dimension$STATISTIC$category$index,
                       levels = json_data$dimension$STATISTIC$category$index)
  
  data <- data.frame(geog_code = rep(json_data$dimension$LGD2014$category$index, length(categories))) %>%
    mutate(statistic = sort(rep_len(categories, nrow(.))),
           VALUE = json_data$value,
           source = dataset_short)
  
  df_dental <- rbind(df_dental, data)
  
  dataset_short <- "DEN_REG"
  
  dataset_long <- "FPSGDSDRLGD"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "Age", "selection": {"filter": "item", "values": ["All"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "lgd",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  data <- data.frame(geog_code = json_data$dimension$LGD2014$category$index,
                     statistic = json_data$dimension$STATISTIC$category$index,
                     VALUE = json_data$value,
                     source = dataset_short)
  
  df_dental <- rbind(df_dental, data)
  
  
  dataset_long <- "FPSGDSDRDEA"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "Age", "selection": {"filter": "item", "values": ["All"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "dea",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  data <- data.frame(geog_code = json_data$dimension$DEA2014$category$index,
                     statistic = json_data$dimension$STATISTIC$category$index,
                     VALUE = json_data$value,
                     source = dataset_short)
  
  df_dental <- rbind(df_dental, data)
  
  #### Work ####
  
  ##### LMR #####
  df_lmr <- list()
  dataset_short <- "LMS"
  dataset_subject <- "79/LMS"
  
  dataset_long <- "LMSLGD"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "STATISTIC", "selection": {"filter": "item", "values": ["EMPN", "EMPR", "UNEMPR", "INACTR"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "lgd",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  categories <- factor(json_data$dimension$STATISTIC$category$index,
                       levels = json_data$dimension$STATISTIC$category$index)
  
  data <- data.frame(geog_code = rep(json_data$dimension$LGD2014$category$index, length(categories))) %>%
    mutate(statistic = sort(rep_len(categories, nrow(.))),
           VALUE = json_data$value,
           source = dataset_short)
  
  df_lmr <- rbind(df_lmr, data)
  
  df_lmr_perc = df_lmr  %>% filter(statistic != "EMPN") %>% rename(perc = VALUE) %>% mutate(VALUE = NA)
  df_lmr_value = df_lmr %>% filter(statistic == "EMPN")
  
  ##### ASHE #####
  df_ashe <- list()
  dataset_short <- "ASHE"
  
  dataset_subject <- "85/EARNINGS"
  
  dataset_long <- "GAPLGD"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "STATISTIC", "selection": {"filter": "item", "values": ["Median"]}},',
      '{"code": "Sex", "selection": {"filter": "item", "values": ["All"]}},',
      '{"code": "WP", "selection": {"filter": "item", "values": ["FT"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "lgd",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  data <- data.frame(geog_code = json_data$dimension$LGD2014$category$index,
                     VALUE = json_data$value,
                     source = dataset_short)
  
  df_ashe <- rbind(df_ashe, data)
  
  
  dataset_short <- "ASHE_weekly"
  dataset_subject <- "85/EARNINGS"
  
  dataset_long <- "GHWPLGD"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "STATISTIC", "selection": {"filter": "item", "values": ["Median"]}},',
      '{"code": "Sex", "selection": {"filter": "item", "values": ["All"]}},',
      '{"code": "WP", "selection": {"filter": "item", "values": ["All"]}},',
      '{"code": "PR", "selection": {"filter": "item", "values": ["Wkly"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "lgd",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  data <- data.frame(geog_code = json_data$dimension$LGD2014$category$index,
                     VALUE = json_data$value,
                     source = dataset_short)
  
  df_ashe <- rbind(df_ashe, data)
  
  
  ##### Industry #####
  df_indust <- list()
  dataset_short <- "BRES"
  dataset_subject <- "12/BRES"
  
  dataset_long <- "BRESHEADLGD"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "GENWP", "selection": {"filter": "item", "values": ["All"]}},',
      '{"code": "HEADLINE", "selection": {"filter": "item", "values": ["Construction", "Manufacturing", "Services", "Other"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "lgd",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  categories <- factor(json_data$dimension$HEADLINE$category$index,
                       levels = json_data$dimension$HEADLINE$category$index)
  
  data <- data.frame(geog_code = sort(rep(json_data$dimension$LGD2014$category$index, length(categories)))) %>%
    mutate(statistic = rep_len(categories, nrow(.)),
           VALUE = json_data$value,
           source = dataset_short) %>%
    group_by(geog_code) %>%
    mutate(perc = VALUE / sum(VALUE) * 100)
  
  
  df_indust <- rbind(df_indust, data)
  
  
  ##### Benefits #####
  df_bs <- list()
  dataset_short <- "BS"
  dataset_subject <- "92/BEN"
  
  dataset_long <- "BSDEA"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "dea",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  categories <- factor(json_data$dimension$STATISTIC$category$index,
                       levels = json_data$dimension$STATISTIC$category$index)
  
  data <- data.frame(geog_code = rep(json_data$dimension$DEA2014$category$index, length(categories))) %>%
    mutate(statistic = sort(rep_len(categories, nrow(.))),
           VALUE = json_data$value,
           source = dataset_short)
  
  df_bs <- rbind(df_bs, data)
  
  dataset_long <- "BSLGD"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "lgd",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  categories <- factor(json_data$dimension$STATISTIC$category$index,
                       levels = json_data$dimension$STATISTIC$category$index)
  
  data <- data.frame(geog_code = rep(json_data$dimension$LGD2014$category$index, length(categories))) %>%
    mutate(statistic = sort(rep_len(categories, nrow(.))),
           VALUE = json_data$value,
           source = dataset_short)
  
  df_bs <- rbind(df_bs, data)
  
  dataset_long <- "BSSDZ"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "sdz",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  categories <- factor(json_data$dimension$STATISTIC$category$index,
                       levels = json_data$dimension$STATISTIC$category$index)
  
  data <- data.frame(geog_code = rep(json_data$dimension$SDZ2021$category$index, length(categories))) %>%
    mutate(statistic = sort(rep_len(categories, nrow(.))),
           VALUE = json_data$value,
           source = dataset_short)
  
  df_bs <- rbind(df_bs, data)
  
  
  dataset_long <- "BSDZ"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "dz",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  categories <- factor(json_data$dimension$STATISTIC$category$index,
                       levels = json_data$dimension$STATISTIC$category$index)
  
  data <- data.frame(geog_code = rep(json_data$dimension$DZ2021$category$index, length(categories))) %>%
    mutate(statistic = sort(rep_len(categories, nrow(.))),
           VALUE = json_data$value,
           source = dataset_short)
  
  df_bs <- rbind(df_bs, data)
  
  #### Education ####
  
  ##### Schools #####
  ##### FSME #####
  
  
  df_school_value <- list()
  df_school_perc <- list()
  dataset_short <- "Primary"
  dataset_subject <- "76/SCEN"
  
  dataset_long <- "DESCPDEA"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "STATISTIC", "selection": {"filter": "item", "values": ["FSME", "All", "SENNonStatemented", "SENStatement"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  latest_year <- as.character(json_data$dimension$`TLIST(A1)`$category$label %>% tail(1))
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, 
    "year" = latest_year,
    "geog_level" = "dea",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  categories <- factor(json_data$dimension$STATISTIC$category$index,
                       levels = json_data$dimension$STATISTIC$category$index)
  
  data <- data.frame(geog_code = rep(json_data$dimension$DEA2014$category$index, length(categories))) %>%
    mutate(statistic = sort(rep_len(categories, nrow(.))),
           VALUE = json_data$value,
           source = dataset_short) %>%
    group_by(geog_code) 
  
  
  data_value <- data %>%
    select(geog_code, statistic, VALUE, source)
  
  
  df_school_value <- rbind(df_school_value, data_value)
  
  
  dataset_long <- "DESCPLGD"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "STATISTIC", "selection": {"filter": "item", "values": ["FSME", "All", "SENNonStatemented", "SENStatement"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "lgd",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  categories <- factor(json_data$dimension$STATISTIC$category$index,
                       levels = json_data$dimension$STATISTIC$category$index)
  
  data <- data.frame(geog_code = rep(json_data$dimension$LGD2014$category$index, length(categories))) %>%
    mutate(statistic = sort(rep_len(categories, nrow(.))),
           VALUE = json_data$value,
           source = dataset_short) %>%
    group_by(geog_code) 
  
  data_value <- data %>%
    select(geog_code, statistic, VALUE, source)
  
  
  df_school_value <- rbind(df_school_value, data_value)
  
  
  dataset_short <- "PostPrimary"
  
  dataset_long <- "DESCPPDEA"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "STATISTIC", "selection": {"filter": "item", "values": ["FSME", "All", "SENNonStatemented", "SENStatement"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "dea",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  categories <- factor(json_data$dimension$STATISTIC$category$index,
                       levels = json_data$dimension$STATISTIC$category$index)
  
  data <- data.frame(geog_code = rep(json_data$dimension$DEA2014$category$index, length(categories))) %>%
    mutate(statistic = sort(rep_len(categories, nrow(.))),
           VALUE = json_data$value,
           source = dataset_short) %>%
    group_by(geog_code) 
  
  data_value <- data %>%
    select(geog_code, statistic, VALUE, source)
  
  df_school_value <- rbind(df_school_value, data_value)
  
  
  dataset_long <- "DESCPPLGD"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "STATISTIC", "selection": {"filter": "item", "values": ["FSME", "All", "SENNonStatemented", "SENStatement"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "lgd",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  categories <- factor(json_data$dimension$STATISTIC$category$index,
                       levels = json_data$dimension$STATISTIC$category$index)
  
  data <- data.frame(geog_code = rep(json_data$dimension$LGD2014$category$index, length(categories))) %>%
    mutate(statistic = sort(rep_len(categories, nrow(.))),
           VALUE = json_data$value,
           source = dataset_short) %>%
    group_by(geog_code) 
  
  data_value <- data %>%
    select(geog_code, statistic, VALUE, source)
  
  
  df_school_value <- rbind(df_school_value, data_value)
  
  
  ##### SEN ####
  
  dataset_short <- "SEN"
  dataset_subject <- "76/SCEN"
  
  dataset_long <- "DESCSDEA"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "STATISTIC", "selection": {"filter": "item", "values": ["SENNonStatemented", "SENStatement"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "dea",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  categories <- factor(json_data$dimension$STATISTIC$category$index,
                       levels = json_data$dimension$STATISTIC$category$index)
  
  data <- data.frame(geog_code = rep(json_data$dimension$DEA2014$category$index, length(categories))) %>%
    mutate(statistic = sort(rep_len(categories, nrow(.))),
           VALUE = json_data$value,
           source = dataset_short)
  
  df_school_value <- unique(rbind(df_school_value, data))
  
  dataset_long <- "DESCSLGD"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "STATISTIC", "selection": {"filter": "item", "values": ["All", "SENNonStatemented", "SENStatement"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "lgd",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  categories <- factor(json_data$dimension$STATISTIC$category$index,
                       levels = json_data$dimension$STATISTIC$category$index)
  
  data <- data.frame(geog_code = rep(json_data$dimension$LGD2014$category$index, length(categories))) %>%
    mutate(statistic = sort(rep_len(categories, nrow(.))),
           VALUE = json_data$value,
           source = dataset_short)
  
  df_school_value <- unique(rbind(df_school_value, data))
  
  
  df_school_FSME <- df_school_value %>% 
    filter(statistic %in% c('FSME', 'All')) %>% 
    filter(source != "SEN") %>%  
    group_by(geog_code, source) %>%
    mutate(perc = VALUE / VALUE[statistic == "All"] *100) 
  
  df_school_SEN = df_school_value %>%
    filter(statistic != 'FSME') %>% replace(is.na(.), 0) %>% 
    mutate(statistic = case_when(statistic %in% c("SENNonStatemented", "SENStatement") ~ 'SEN',
                                 TRUE ~ statistic)) %>%
    group_by(geog_code, statistic) %>% summarise(VALUE = sum(VALUE)) %>% 
    mutate(perc = VALUE / VALUE[statistic == "All"] *100) %>% 
    filter(statistic != "All") %>%  
    mutate(source = "AllSchools") 
  
  
  df_school_values <- unique(rbind(df_school_FSME %>% select(-perc), df_school_SEN %>% select(-perc)))
  
  df_school_perc <- unique(rbind(df_school_FSME, df_school_SEN))
  
  
  
  
  
  
  
  ##### Pupil / teacher ratio #####
  df_school_classsize <- list()
  dataset_short <- "ClassSize"
  dataset_subject <- "76/SWF"
  
  dataset_long <- "DETNPTRLGD"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "TNschooltype", "selection": {"filter": "item", "values": ["All"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "lgd",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  data <- data.frame(geog_code = json_data$dimension$LGD2014$category$index,
                     VALUE = json_data$value,
                     source = dataset_short)
  
  df_school_classsize <- rbind(df_school_classsize, data)
  ##### GCSEs #####
  df_school_attainment <- list()
  dataset_short <- "Attainment"
  dataset_subject <- "76/SL"
  
  dataset_long <- "DESLSALGD"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "FSME", "selection": {"filter": "item", "values": ["All"]}},',
      '{"code": "STATISTIC", "selection": {"filter": "item", "values": ["fivegcseatocincengmathpct"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "lgd",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  data <- data.frame(geog_code = json_data$dimension$LGD2014$category$index,
                     VALUE = json_data$value,
                     source = dataset_short)
  
  
  df_school_attainment <- rbind(df_school_attainment, data)
  
  dataset_long <- "DESLSADEA"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "FSME", "selection": {"filter": "item", "values": ["All"]}},',
      '{"code": "STATISTIC", "selection": {"filter": "item", "values": ["fivegcseatocincengmathpct"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "dea",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  data <- data.frame(geog_code = json_data$dimension$DEA2014$category$index,
                     VALUE = json_data$value,
                     source = dataset_short)
  
  
  df_school_attainment <- rbind(df_school_attainment, data)
  ##### Colleges and Universities #####
  
  df_FEHE <- list()
  dataset_short <- "FE"
  dataset_subject <- "77/FES"
  
  dataset_long <- "FEENROLLGD"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "lgd",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  data <- data.frame(geog_code = json_data$dimension$LGD2014$category$index,
                     VALUE = json_data$value,
                     source = dataset_short)
  
  df_FEHE <- rbind(df_FEHE, data)
  
  dataset_long <- "FEENROLDEA"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "dea",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  data <- data.frame(geog_code = json_data$dimension$DEA2014$category$index,
                     VALUE = json_data$value,
                     source = dataset_short)
  
  df_FEHE <- rbind(df_FEHE, data)
  
  dataset_short <- "HE"
  dataset_subject <- "77/HES"
  
  dataset_long <- "HEENROLLGD"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "lgd",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  data <- data.frame(geog_code = json_data$dimension$LGD2014$category$index,
                     VALUE = json_data$value,
                     source = dataset_short)
  
  df_FEHE <- rbind(df_FEHE, data)
  
  dataset_long <- "HEENROLDEA"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "dea",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  data <- data.frame(geog_code = json_data$dimension$DEA2014$category$index,
                     VALUE = json_data$value,
                     source = dataset_short)
  
  df_FEHE <- rbind(df_FEHE, data)
  
  
  ##### Destination #####
  
  df_school_destination <- list()
  dataset_short <- "Destination"
  dataset_subject <- "76/SL"
  
  dataset_long <- "DESLSDDEA"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "STATISTIC", "selection": {"filter": "item", "values": ["destHEpct", "destFEpct", "destEmploypct", "destTrainpct", "destUnempUnkpct"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "dea",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  categories <- factor(json_data$dimension$STATISTIC$category$index,
                       levels = json_data$dimension$STATISTIC$category$index)
  
  data <- data.frame(geog_code = rep(json_data$dimension$DEA2014$category$index, length(categories))) %>%
    mutate(statistic = sort(rep_len(categories, nrow(.))),
           VALUE = json_data$value,
           source = dataset_short)
  
  df_school_destination <- unique(rbind(df_school_destination, data))
  
  
  dataset_long <- "DESLSDLGD"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "STATISTIC", "selection": {"filter": "item", "values": ["destHEpct", "destFEpct", "destEmploypct", "destTrainpct", "destUnempUnkpct"]}},',
      '{"code": "FSME", "selection": {"filter": "item", "values":["All"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "lgd",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  categories <- factor(json_data$dimension$STATISTIC$category$index,
                       levels = json_data$dimension$STATISTIC$category$index)
  
  data <- data.frame(geog_code = rep(json_data$dimension$LGD2014$category$index, length(categories))) %>%
    mutate(statistic = sort(rep_len(categories, nrow(.))),
           VALUE = json_data$value,
           source = dataset_short)
  
  df_school_destination <- unique(rbind(df_school_destination, data))
  df_school_destination_perc = df_school_destination %>% rename(perc = VALUE) %>% mutate(VALUE = NA)
  
  
  
  
  
  #### Environment ####
  df_env <- list()
  df_env_perc <- list()
  
  ##### Concern #####
  
  dataset_short <- "Env_concern"
  dataset_subject <- "82/PA"
  
  dataset_long <- "CHSCONCERNLGD"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "STATISTIC", "selection": {"filter": "item", "values": ["CONCERNENVI", "NOTCONCERNENVI"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long,
    "year" = latest_year,
    "geog_level" = "lgd",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", dataset_long),
    "last_updated" = format(substring(updated[which(matrices == dataset_long)], 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = data_portal$label[which(matrices == dataset_long)],
    "note" = json_data$note
  )))
  
  categories <- factor(json_data$dimension$STATISTIC$category$index,
                       levels = json_data$dimension$STATISTIC$category$index)
  
  data <- data.frame(geog_code = rep(json_data$dimension$LGD2014$category$index, length(categories))) %>%
    mutate(statistic = sort(rep_len(categories, nrow(.))),
           VALUE = json_data$value,
           source = dataset_short) %>%
    mutate(perc = VALUE )
  
  df_env_perc <- rbind(df_env_perc, data)
  
  
  
  dataset_short <- "Env_problem"
  dataset_subject <- "82/PA"
  
  dataset_long <- "CHSENVIPROBLGD"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}}],',
      ##'{"code": "STATISTIC", "selection": {"filter": "item", "values": ["CONCERNENVI", "NOTCONCERNENVI"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long,
    "year" = latest_year,
    "geog_level" = "lgd",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", dataset_long),
    "last_updated" = format(substring(updated[which(matrices == dataset_long)], 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = data_portal$label[which(matrices == dataset_long)],
    "note" = json_data$note
  )))
  
  categories <- factor(json_data$dimension$STATISTIC$category$index,
                       levels = json_data$dimension$STATISTIC$category$index)
  
  data <- data.frame(geog_code = rep(json_data$dimension$LGD2014$category$index, length(categories))) %>%
    mutate(statistic = sort(rep_len(categories, nrow(.))),
           VALUE = json_data$value) %>%
    mutate(problem_reason = case_when(statistic =='POLRIVER' ~ 'Pollution in rivers',
                                      statistic =='POLBWB' ~ 'Pollution in bathing waters and beaches',
                                      statistic =='TREXUS' ~ 'Traffic exhaust and urban smog',
                                      statistic =='LOSSPA' ~ 'Loss of plants and animals in NI',
                                      statistic =='OZLADE' ~ 'Ozone layer depletion',
                                      statistic =='TRFODE' ~ 'Tropical forest destruction',
                                      statistic =='CLICHA' ~ 'Climate change',
                                      statistic =='LOSSTH' ~ 'Loss of trees and hedgerows in NI',
                                      statistic =='FUMSMO' ~ 'Fumes and smoke from factories',
                                      statistic =='TRACON' ~ 'Traffic congestion',
                                      statistic =='PESFER' ~ 'Use of pesticides and fertilisers',
                                      statistic =='ACIRAI' ~ 'Acid rain',
                                      statistic =='WASLAN' ~ 'Waste send to landfill',
                                      statistic =='ILDUWA' ~ 'Illegal dumping of waste',
                                      statistic =='NOISE' ~ 'Noise',
                                      statistic =='FRACK' ~ 'Fracking',
                                      statistic =='LITTER' ~ 'Litter',
                                      statistic =='RENORE' ~ 'Recyclable waste not being recycled',
                                      statistic =='OTHER' ~ 'Other',
                                      statistic =='NONE' ~ 'None of these',
                                      TRUE ~ ""),
  
           perc = VALUE ,
           source = dataset_short) %>%
    
    group_by(geog_code, source) %>% slice_max(VALUE, n=3) %>%
  
    
    summarise(reason = paste0(problem_reason, collapse = "; "))
  
  df_env_problems = data
  
  
  dataset_short <- "Env_waste"
  dataset_subject <- "82/W"
  
  ##### waste #####
  dataset_long <- "WASTELGD"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "STATISTIC", "selection": {"filter": "item", "values": ["LACMWR","LACMWL","LACMWER"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long,
    "year" = latest_year,
    "geog_level" = "lgd",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", dataset_long),
    "last_updated" = format(substring(updated[which(matrices == dataset_long)], 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = data_portal$label[which(matrices == dataset_long)],
    "note" = json_data$note
  )))
  
  categories <- factor(json_data$dimension$STATISTIC$category$index,
                       levels = json_data$dimension$STATISTIC$category$index)
  
  data <- data.frame(geog_code = rep(json_data$dimension$LGD2014$category$index, length(categories))) %>%
    mutate(statistic = sort(rep_len(categories, nrow(.))),
           VALUE = json_data$value,
           source = dataset_short,
           perc = VALUE)
  
  df_env_perc <- rbind(df_env_perc, data)
  
  
  
  
  ##### GHG #####
  
  dataset_short <- "Env_ghg"
  dataset_subject <- "82/GHG"
  
  dataset_long <- "GHGALL"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "GHGSECTOR", "selection": {"filter": "item", "values": ["GTALL"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long,
    "year" = latest_year,
    "geog_level" = "lgd",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", dataset_long),
    "last_updated" = format(substring(updated[which(matrices == dataset_long)], 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = data_portal$label[which(matrices == dataset_long)],
    "note" = json_data$note
  )))
  
  categories <- factor(json_data$dimension$STATISTIC$category$index,
                       levels = json_data$dimension$STATISTIC$category$index)
  
  data <- data.frame(geog_code = rep(json_data$dimension$LGD2014$category$index, length(categories))) %>%
    mutate(statistic = sort(rep_len(categories, nrow(.))),
           VALUE = json_data$value,
           source = dataset_short)
  
  df_env <- rbind(df_env, data)
  
  
  
  
  json_data_base <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["2005"]}},',
      '{"code": "STATISTIC", "selection": {"filter": "item", "values": ["GHGALL"]}},',
      '{"code": "GHGSECTOR", "selection": {"filter": "item", "values": ["GTALL"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  
  
  
  categories <- factor(json_data_base$dimension$STATISTIC$category$index,
                       levels = json_data_base$dimension$STATISTIC$category$index)
  
  data <- data.frame(geog_code = rep(json_data_base$dimension$LGD2014$category$index, length(categories))) %>%
    mutate(statistic = "GHGALL_BASE",
           VALUE = json_data_base$value,
           source = dataset_short)
  
  df_env <- rbind(df_env, data)
  
  ##### active travel #####
  
  dataset_short <- "Env_active"
  dataset_subject <- "72/AST"
  
  dataset_long <- "JMWCPTLGD"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "STATISTIC", "selection": {"filter": "item", "values": ["JWCPT"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long,
    "year" = latest_year,
    "geog_level" = "lgd",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", dataset_long),
    "last_updated" = format(substring(updated[which(matrices == dataset_long)], 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = data_portal$label[which(matrices == dataset_long)],
    "note" = json_data$note
  )))
  
  categories <- factor(json_data$dimension$STATISTIC$category$index,
                       levels = json_data$dimension$STATISTIC$category$index)
  
  data <- data.frame(geog_code = rep(json_data$dimension$LGD2014$category$index, length(categories))) %>%
    mutate(statistic = sort(rep_len(categories, nrow(.))),
           VALUE = json_data$value,
           source = dataset_short)
  
  df_env <- rbind(df_env, data)
  
  
  #### Crime ####
  ##### PSNI recorded crime ####
  
  df_crime <- list()
  dataset_short <- "crime"
  dataset_subject <- "67/PRC"
  
  dataset_long <- "PRCDEA"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  
  # csv_data = read.csv(paste0("https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.ReadDataset/",dataset_long,"/CSV/1.0/")) %>%
  #   filter(`TLIST.A1.` == latest_year) %>% 
  #   mutate(crime_group = case_when(crmclass %in% c(1,2,3,4,5) ~ 'person',
  #                                  crmclass %in% c(6, 7, 8, 9, 10, 11, 12, 13, 14, 15) ~ 'btcd',
  #                                  crmclass %in% c(16, 17, 18, 19, 20) ~ 'other',
  #                                  crmclass == 'All' ~ 'allcrime',
  #                                  TRUE ~ crmclass)) %>% 
  #   select(DEA2014, crime_group, VALUE) %>% group_by(DEA2014, crime_group) %>% 
  #   summarise(VALUE = sum(VALUE, na.rm = TRUE)) %>% 
  #   rename(geog_code = DEA2014, statistic = crime_group) %>% mutate(source = dataset_short)
  
  
  csv_data = read.csv(paste0("https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.ReadDataset/",dataset_long,"/CSV/1.0/")) %>%
    filter(`TLIST.A1.` == latest_year) %>% 
    mutate(crime_group = case_when(crmclass %in% c(1,2,3) ~ 'person',
                                   crmclass %in% c(4) ~ 'sexual',
                                   crmclass %in% c(5) ~ 'robbery',
                                   crmclass %in% c(6,7,8,9) ~ 'theft_burglary',
                                   crmclass %in% c(10,11,12,13,14) ~ 'theft',
                                   crmclass %in% c(15) ~ 'criminal',
                                   crmclass %in% c(16, 17, 18, 19, 20) ~ 'other',
                                   crmclass == 'All' ~ 'allcrime',
                                   TRUE ~ crmclass)) %>% 
    select(DEA2014, crime_group, VALUE) %>% group_by(DEA2014, crime_group) %>% 
    summarise(VALUE = sum(VALUE, na.rm = TRUE)) %>% 
    rename(geog_code = DEA2014, statistic = crime_group) %>% mutate(source = dataset_short)
  
  
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "dea",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  # 
  # categories <- factor(json_data$dimension$crmclass$category$index,
  #                      levels = json_data$dimension$crmclass$category$index)
  # 
  # data <- data.frame(statistic = rep(categories, length(json_data$dimension$DEA2014$category$index))) %>%
  #   mutate(geog_code = sort(rep_len(json_data$dimension$DEA2014$category$index, nrow(.))),
  #          VALUE = json_data$value,
  #          source = dataset_short)
  
    df_crime <- rbind(df_crime, csv_data)
  
  
  
  csv_data = read.csv(paste0("https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.ReadDataset/",dataset_long,"/CSV/1.0/")) %>%
    filter(`TLIST.A1.` == latest_year & crmclass %in% c(6,7) ) %>% 
    mutate(crime_group = 'burglary') %>% 
    select(DEA2014, crime_group, VALUE) %>% group_by(DEA2014, crime_group) %>% 
    summarise(VALUE = sum(VALUE, na.rm = TRUE)) %>% 
    rename(geog_code = DEA2014, statistic = crime_group) %>% mutate(source = dataset_short)
  
  
  df_crime <- rbind(df_crime, csv_data)
  
  
  
  dataset_long <- "PRCLGD"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "crmclass", "selection": {"filter": "item", "values": ["All"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
      
    ))
  )
  # 
  # 
  # csv_data = read.csv(paste0("https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.ReadDataset/",dataset_long,"/CSV/1.0/")) %>%
  #   filter(`TLIST.A1.` == latest_year) %>% 
  #   mutate(crime_group = case_when(crmclass %in% c(1,2,3,4,5) ~ 'person',
  #                                  crmclass %in% c(6, 7, 8, 9, 10, 11, 12, 13, 14, 15) ~ 'btcd',
  #                                  crmclass %in% c(16, 17, 18, 19, 20) ~ 'other',
  #                                  crmclass == 'All' ~ 'allcrime',
  #                                  TRUE ~ crmclass)) %>% 
  #   select(LGD2014, crime_group, VALUE) %>% group_by(LGD2014, crime_group) %>% 
  #   summarise(VALUE = sum(VALUE, na.rm = TRUE)) %>% 
  #   rename(geog_code = LGD2014, statistic = crime_group) %>% mutate(source = dataset_short)
  
  csv_data = read.csv(paste0("https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.ReadDataset/",dataset_long,"/CSV/1.0/")) %>%
    filter(`TLIST.A1.` == latest_year) %>% 
    mutate(crime_group = case_when(crmclass %in% c(1,2,3) ~ 'person',
                                   crmclass %in% c(4) ~ 'sexual',
                                   crmclass %in% c(5) ~ 'robbery',
                                   crmclass %in% c(6,7,8,9) ~ 'theft_burglary',
                                   crmclass %in% c(10,11,12,13,14) ~ 'theft',
                                   crmclass %in% c(15) ~ 'criminal',
                                   crmclass %in% c(16, 17, 18, 19, 20) ~ 'other',
                                   crmclass == 'All' ~ 'allcrime',
                                   TRUE ~ crmclass)) %>% 
    select(LGD2014, crime_group, VALUE) %>% group_by(LGD2014, crime_group) %>% 
    summarise(VALUE = sum(VALUE, na.rm = TRUE)) %>% 
    rename(geog_code = LGD2014, statistic = crime_group) %>% mutate(source = dataset_short)
  
  
  
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "lgd",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  # categories <- factor(json_data$dimension$STATISTIC$category$index,
  #                      levels = json_data$dimension$STATISTIC$category$index)
  # 
  # data <- data.frame(geog_code = rep(json_data$dimension$LGD2014$category$index, length(categories))) %>%
  #   mutate(statistic = sort(rep_len(categories, nrow(.))),
  #          VALUE = json_data$value,
  #          source = dataset_short)
  
  df_crime <- unique(rbind(df_crime, csv_data))
  
  
  
  csv_data = read.csv(paste0("https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.ReadDataset/",dataset_long,"/CSV/1.0/")) %>%
    filter(`TLIST.A1.` == latest_year & crmclass %in% c(6,7) ) %>% 
    mutate(crime_group = 'burglary') %>% 
    select(LGD2014, crime_group, VALUE) %>% group_by(LGD2014, crime_group) %>% 
    summarise(VALUE = sum(VALUE, na.rm = TRUE)) %>% 
    rename(geog_code = LGD2014, statistic = crime_group) %>% mutate(source = dataset_short)
  
  df_crime <- unique(rbind(df_crime, csv_data))
  
  df_crime_perc <- df_crime %>%  group_by(geog_code) %>% filter(statistic != "burglary") %>% 
    mutate(perc = VALUE / VALUE[statistic == "allcrime"] *100) 
  
  df_crime_perc %>% filter(geog_code == "N92000002")
  
  ##### Worry ####
  dataset_short <- "crimeworry"
  dataset_subject <- "65/NISCTS"
  
  dataset_long <- "TWORRYCRMLGD"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "STATISTIC", "selection": {"filter": "item", "values": ["WorryC1","WorryC2","WorryC3","WorryC4"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "lgd",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  categories <- factor(json_data$dimension$STATISTIC$category$index,
                       levels = json_data$dimension$STATISTIC$category$index)
  
  data <- data.frame(geog_code = rep(json_data$dimension$LGD2014$category$index, length(categories))) %>%
    mutate(statistic = sort(rep_len(categories, nrow(.))),
           VALUE = json_data$value,
           source = dataset_short) %>% group_by(geog_code) %>% 
    slice_max(VALUE) %>%
    mutate(reason = case_when(statistic == "WorryC1" ~ "Car crime",
                              statistic == "WorryC2" ~ "Crime overall",
                              statistic == "WorryC3" ~ "Burglary",
                              statistic == "WorryC4" ~ "Violent crime",
                              TRUE ~ "")) %>% select(geog_code, reason, source)
  
  
  df_crime_text  <- data
  
  
  data <- data.frame(geog_code = rep(json_data$dimension$LGD2014$category$index, length(categories))) %>%
    mutate(statistic = sort(rep_len(categories, nrow(.))),
           VALUE = json_data$value,
           source = dataset_short) %>% 
    filter( statistic == "WorryC2")
  
  
  
  df_crime <- unique(rbind(df_crime, data))
  
  
  
  ##### perception ####
  dataset_short <- "crimeperception"
  dataset_subject <- "65/NISCTS"
  
  dataset_long <- "TNISCSASBLGD"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "STATISTIC", "selection": {"filter": "item", "values": ["ASB8"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "lgd",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  categories <- factor(json_data$dimension$STATISTIC$category$index,
                       levels = json_data$dimension$STATISTIC$category$index)
  
  data <- data.frame(geog_code = rep(json_data$dimension$LGD2014$category$index, length(categories))) %>%
    mutate(statistic = sort(rep_len(categories, nrow(.))),
           VALUE = json_data$value,
           source = dataset_short)
  
  
  df_crime <- unique(rbind(df_crime, data))
  
  #### business sectors ####
  # Number of businesses  - https://data.nisra.gov.uk/table/BUSINESSBIGLGD
  # Type of businesses (4 broad groups) https://data.nisra.gov.uk/table/BUSINESSBIGLGD
  # Size of businesses https://data.nisra.gov.uk/table/BUSINESSBANDLGD
  # One box for tourism (jobs? to be updated later in the year - just 2019 available atm)
  # Agriculture - size of farms 
  
  
  ##### business sectors and size #####
  
  df_business <- list()
  dataset_short <- "business"
  dataset_subject <- "6/IDBR"
  
  dataset_long <- "BUSINESSBIGLGD"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "STATISTIC", "selection": {"filter": "item", "values": ["BCOUNTS"]}},',
      '{"code": "BIG", "selection": {"filter": "item", "values": ["All"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "lgd",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  categories <- factor(json_data$dimension$STATISTIC$category$index,
                       levels = json_data$dimension$STATISTIC$category$index)
  
  data <- data.frame(geog_code = rep(json_data$dimension$LGD2014$category$index, length(categories))) %>%
    mutate(statistic = sort(rep_len(categories, nrow(.))),
           VALUE = json_data$value,
           source = dataset_short)
  
  df_business <- rbind(df_business, data)
  
  
  dataset_short <- "businesstype"
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "STATISTIC", "selection": {"filter": "item", "values": ["BCOUNTS"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  categories <- factor(json_data$dimension$BIG$category$index,
                       levels = json_data$dimension$BIG$category$index)
  
  
  data <- data.frame(statistic = rep(categories, length(json_data$dimension$LGD2014$category$index))) %>%
    mutate(geog_code = sort(rep_len(json_data$dimension$LGD2014$category$index, nrow(.))),
           VALUE = json_data$value,
           source = dataset_short) %>%
    mutate(big_group = case_when(statistic %in% c(1) ~ 'agr',
                                 statistic %in% c(4) ~ 'cons',
                                 statistic %in% c(3) ~ 'prod',
                                 statistic %in% c(5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18) ~ 'serv',
                                 TRUE ~ statistic) ) %>% 
    group_by(geog_code, big_group, source) %>% summarise(VALUE = sum(VALUE, na.rm=TRUE)) %>%
    rename(statistic = "big_group" )
  
  
  
  
  df_business <- rbind(df_business, data)
  
  
  dataset_subject <- "6/IDBR"
  dataset_short <- "businessband"
  dataset_long <- "BUSINESSBANDLGD"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  
  
  json_data_E <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "BIG", "selection": {"filter": "item", "values": ["All"]}},',
      '{"code": "TOBAND", "selection": {"filter": "item", "values": ["All"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "lgd",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data_E$extension$matrix),
    "last_updated" = format(substring(json_data_E$updated, 1, 10), format = "%a"),
    "email" = json_data_E$extension$contact$email,
    "title" = json_data_E$label,
    "note" = json_data_E$note
  )))
  
  categories_E <- factor(json_data_E$dimension$EMPBAND$category$index,
                         levels = json_data_E$dimension$EMPBAND$category$index)
  
  
  data <- data.frame(statistic = rep(categories_E, length(json_data_E$dimension$LGD2014$category$index))) %>%
    mutate(geog_code = sort(rep_len(json_data_E$dimension$LGD2014$category$index, nrow(.))),
           VALUE = json_data_E$value,
           source = dataset_short)%>%
    group_by(geog_code)
  
  
  df_business <- rbind(df_business, data)
  
  
  
  
  
  json_data_T <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "BIG", "selection": {"filter": "item", "values": ["All"]}},',
      '{"code": "EMPBAND", "selection": {"filter": "item", "values": ["All"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  categories_T <- factor(json_data_T$dimension$TOBAND$category$index,
                         levels = json_data_T$dimension$TOBAND$category$index)
  
  
  data <- data.frame(statistic = rep(categories_T, length(json_data_T$dimension$LGD2014$category$index))) %>%
    mutate(geog_code = sort(rep_len(json_data_T$dimension$LGD2014$category$index, nrow(.))),
           VALUE = json_data_T$value,
           source = dataset_short)%>%
    group_by(geog_code)
  
  
  df_business <- rbind(df_business, data)
  
  
  
  
  
  ##### farms #####
  dataset_subject <- "89/FS"
  
  dataset_short <- "farms"
  dataset_long <- "FCLGD"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "STATISTIC", "selection": {"filter": "item", "values": ["F", "FA"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "lgd",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  categories <- factor(json_data$dimension$STATISTIC$category$index,
                       levels = json_data$dimension$STATISTIC$category$index)
  
  data <- data.frame(geog_code = rep(json_data$dimension$LGD2014$category$index, length(categories))) %>%
    mutate(statistic = sort(rep_len(categories, nrow(.))),
           VALUE = json_data$value,
           source = dataset_short)
  
  df_business <- rbind(df_business, data)
  
  
  
  
  dataset_subject <- "89/FS"
  
  dataset_short <- "farms"
  dataset_long <- "FCDEA"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "STATISTIC", "selection": {"filter": "item", "values": ["F", "FA"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "dea",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  categories <- factor(json_data$dimension$STATISTIC$category$index,
                       levels = json_data$dimension$STATISTIC$category$index)
  
  data <- data.frame(geog_code = rep(json_data$dimension$DEA2014$category$index, length(categories))) %>%
    mutate(statistic = sort(rep_len(categories, nrow(.))),
           VALUE = json_data$value,
           source = dataset_short)
  
  df_business <- rbind(df_business, data)
  
  ##### tourism #####
  dataset_subject <- "72/TOU"
  
  dataset_short <- "tourism"
  dataset_long <- "EJOBSLGD"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "STATISTIC", "selection": {"filter": "item", "values": ["EMJOBS"]}},',
      '{"code": "EMJOBS", "selection": {"filter": "item", "values": ["All", "TJ"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "lgd",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  
  csv_data = read.csv(paste0("https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.ReadDataset/",dataset_long,"/CSV/1.0/")) %>%
    filter(`TLIST.A1.` == latest_year & EMJOBS %in% c('All', 'TJ')) %>% 
    select(LGD2014, EMJOBS, VALUE) %>% group_by(LGD2014, EMJOBS) %>% 
    summarise(VALUE  = sum(VALUE, na.rm = TRUE)) %>% 
    rename(geog_code = LGD2014, statistic = EMJOBS) %>% #mutate(source = dataset_short, statistic = EMJOBS) %>%
    mutate(statistic = gsub("All","AllJobs",statistic),
           statistic = gsub("TJ","TourismJobs",statistic),
           source = dataset_short
    )
  
  # categories <- factor(json_data$dimension$EMJOBS$category$index,
  #                      levels = json_data$dimension$EMJOBS$category$index)
  # 
  # data <- data.frame(geog_code = rep(json_data$dimension$LGD2014$category$index, length(categories))) %>%
  #   mutate(statistic = sort(rep_len(categories, nrow(.))),
  #          VALUE = json_data$value,
  #          source = dataset_short) %>% 
  #   mutate(statistic = gsub("All","AllJobs",statistic),
  #          statistic = gsub("TJ","TourismJobs",statistic),
  #   )
  
  df_business <- rbind(df_business, csv_data)
  
  
  dataset_short <- "tourism_estab"
  dataset_long <- "CASLGD"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "STATISTIC", "selection": {"filter": "item", "values": ["All"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  )
  
  
  csv_data = read.csv(paste0("https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.ReadDataset/",dataset_long,"/CSV/1.0/")) %>%
    filter(`TLIST.A1.` == latest_year & STATISTIC == "All") %>% 
    select(LGD2014, VALUE) %>% group_by(LGD2014) %>% 
    summarise(VALUE  = sum(VALUE, na.rm = TRUE)) %>% 
    rename(geog_code = LGD2014) %>% mutate(source = dataset_short, statistic = 'estab')
  
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "lgd",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  df_business <- rbind(df_business, csv_data)
  
  
  
  df_business_perc <- df_business %>%  group_by(geog_code) %>% 
    filter(statistic %in% c('agr', 'cons', 'prod', 'serv', 
                            'E1','E2', 'E3', 'E4', 'E5', 
                            'T1', 'T2', 'T3', 'T4', 'T5', 'All')) %>%
    mutate(perc = VALUE / VALUE[statistic == "All"] *100) 
  
  
  ##### niets #####
  
  dataset_subject <- "6/NIETS"
  
  dataset_short <- "niets_sales"
  dataset_long <- "NIETS05"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "STATISTIC", "selection": {"filter": "item", "values": ["BESESVALUE"]}},',
      '{"code": "FLOW", "selection": {"filter": "item", "values": ["SALES"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  ) 
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "lgd",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  categories <- factor(json_data$dimension$BROADDEST$category$index,
                       levels = json_data$dimension$BROADDEST$category$index)
  
  data <- data.frame(geog_code = rep(json_data$dimension$LGD$category$index, length(categories))) %>%
    mutate(statistic = sort(rep_len(categories, nrow(.))),
           VALUE = json_data$value,
           source = dataset_short)
  
  data_ni <- data %>% group_by(statistic, source) %>% 
    summarise(VALUE = sum(VALUE, na.rm = TRUE)) %>% 
    mutate(geog_code = "N92000002") 
  
  data <- rbind(data, data_ni)
  
  df_business <- rbind(df_business, data)
  
  
  dataset_short <- "niets_purch"
  dataset_long <- "NIETS05"
  latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)
  
  json_data <- jsonlite::fromJSON(
    txt = transform_URL(paste0(
      'https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.PxAPIv1/en/',
      dataset_subject, '/', dataset_long,
      '?query={"query": [{"code": "TLIST(A1)", "selection": {"filter": "item", "values": ["', latest_year, '"]}},',
      '{"code": "STATISTIC", "selection": {"filter": "item", "values": ["BESESVALUE"]}},',
      '{"code": "FLOW", "selection": {"filter": "item", "values": ["PURCH"]}}],',
      '"response": {"format": "json-stat2", "pivot": null}}'
    ))
  ) 
  
  df_meta_data <- rbind(df_meta_data, t(c(
    dataset = dataset_short,
    "table_code" = dataset_long, "year" = latest_year,
    "geog_level" = "lgd",
    "dataset_url" = paste0("https://data.nisra.gov.uk/table/", json_data$extension$matrix),
    "last_updated" = format(substring(json_data$updated, 1, 10), format = "%a"),
    "email" = json_data$extension$contact$email,
    "title" = json_data$label,
    "note" = json_data$note
  )))
  
  categories <- factor(json_data$dimension$BROADDEST$category$index,
                       levels = json_data$dimension$BROADDEST$category$index)
  
  data <- data.frame(geog_code = rep(json_data$dimension$LGD$category$index, length(categories))) %>%
    mutate(statistic = sort(rep_len(categories, nrow(.))),
           VALUE = json_data$value,
           source = dataset_short)
  
  data_ni <- data %>% group_by(statistic, source) %>% 
    summarise(VALUE = sum(VALUE, na.rm = TRUE)) %>% 
    mutate(geog_code = "N92000002") 
  
  data <- rbind(data, data_ni)
  
  df_business <- rbind(df_business, data)
  
  
  df_business_perc_niets <- df_business %>%  group_by(geog_code, source) %>% 
    filter(statistic %in% c('ALL', 'NI','GB','IE','REU', 'ROW')  ) %>%
    mutate(perc = VALUE / VALUE[statistic == "ALL"] *100) 
  
  
  
  
  #### Bind rows ####
  
  df_dp_all_values <- unique(bind_rows(
    rbind(
      df_le, df_dental, df_gps, df_lmr_value, df_bs,
      #df_school_destination, 
      df_popchange, df_school_values, 
      df_env,
      df_crime,
      df_business, df_lps
    ),
    rbind(
      df_satisfy, df_happy, df_lonely, 
      df_admissions_all, df_ashe,
      df_school_classsize, df_school_attainment, df_FEHE, df_pop
    )
  ))
  
  
  df_dp_all_text <- bind_rows(df_admissions_top, df_crime_text, df_env_problems)
  
  df_dp_all_perc <- unique(rbind( df_lmr_perc, df_indust, df_school_perc, df_popage, 
                                  df_school_destination_perc, df_env_perc, df_business_perc, 
                                  df_crime_perc, df_business_perc_niets))
  
  

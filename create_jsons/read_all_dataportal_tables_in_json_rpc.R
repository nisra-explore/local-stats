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

##### MYE by LGD #####
dataset_long <- "MYE01T06"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

json_data <- json_data_from_rpc(
  query = paste0(
  '{
  	"jsonrpc": "2.0",
  	"method": "PxStat.Data.Cube_API.ReadDataset",
  	"params": {
  		"class": "query",
  		"id": [
  			"TLIST(A1)",
  			"rounded_unrounded"
  		],
  		"dimension": {
  			"TLIST(A1)": {
  				"category": {
  					"index": [
  						"', latest_year, '"
  					]
  				}
  			},
  			"rounded_unrounded": {
  				"category": {
  					"index": [
  						"Unrounded"
  					]
  				}
  			}
  		},
  		"extension": {
  			"pivot": null,
  			"codes": true,
  			"language": {
  				"code": "en"
  			},
  			"format": {
  				"type": "JSON-stat",
  				"version": "2.0"
  			},
  			"matrix": "', dataset_long, '"
  		},
  		"version": "2.0"
  	}
  }')
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

json_data <- json_data_from_rpc(
  query = paste0(
   '{
  	"jsonrpc": "2.0",
  	"method": "PxStat.Data.Cube_API.ReadDataset",
  	"params": {
  		"class": "query",
  		"id": [
  			"TLIST(A1)"
  		],
  		"dimension": {
  			"TLIST(A1)": {
  				"category": {
  					"index": [
  						"', latest_year, '"
  					]
  				}
  			}
  		},
  		"extension": {
  			"pivot": null,
  			"codes": false,
  			"language": {
  				"code": "en"
  			},
  			"format": {
  				"type": "JSON-stat",
  				"version": "2.0"
  			},
  			"matrix": "', dataset_long, '"
  		},
  		"version": "2.0"
  	}
  }')
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

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"TLIST(A1)",
			"broadage4",
			"Sex"
		],
		"dimension": {
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			},
			"broadage4": {
				"category": {
					"index": [
						"All"
					]
				}
			},
			"Sex": {
				"category": {
					"index": [
						"All"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": false,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}')
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

json_data <- json_data_from_rpc(
  query = paste0(
    '{
  	"jsonrpc": "2.0",
  	"method": "PxStat.Data.Cube_API.ReadDataset",
  	"params": {
  		"class": "query",
  		"id": [
  			"TLIST(A1)",
  			"broadage4",
  			"Sex"
  		],
  		"dimension": {
  			"TLIST(A1)": {
  				"category": {
  					"index": [
  						"', latest_year, '"
  					]
  				}
  			},
  			"broadage4": {
  				"category": {
  					"index": [
  						"All"
  					]
  				}
  			},
  			"Sex": {
  				"category": {
  					"index": [
  						"All"
  					]
  				}
  			}
  		},
  		"extension": {
  			"pivot": null,
  			"codes": false,
  			"language": {
  				"code": "en"
  			},
  			"format": {
  				"type": "JSON-stat",
  				"version": "2.0"
  			},
  			"matrix": "', dataset_long, '"
  		},
  		"version": "2.0"
  	}
  }')
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

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"TLIST(A1)",
			"Sex"
		],
		"dimension": {
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			},
			"Sex": {
				"category": {
					"index": [
						"All"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": false,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}')
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

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"TLIST(A1)",
			"broadage4",
			"Sex"
		],
		"dimension": {
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			},
			"broadage4": {
				"category": {
					"index": [
						"1",
						"2",
						"3",
						"4"
					]
				}
			},
			"Sex": {
				"category": {
					"index": [
						"All"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": false,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}')
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

# Allowing for whatever order geog codes appear in raw data
geog_codes <- c()
for (i in 1:length(json_data$dimension$SDZ2021$category$index)) {
  geog_codes <- c(geog_codes, rep(json_data$dimension$SDZ2021$category$index[i], length(categories)))
}

data <- data.frame(geog_code = geog_codes) %>%
  mutate(statistic = rep_len(categories, nrow(.)),
         VALUE = json_data$value) %>%
  group_by(geog_code) %>%
  mutate(perc = VALUE / sum(VALUE) * 100,
         source = dataset_short) %>%
  filter(geog_code != "N92000002") %>%
  arrange(geog_code, statistic)

df_popage <- rbind(df_popage, data)

##### Age band by LGD ####
dataset_long <- "MYE01T04"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"TLIST(A1)",
			"Sex"
		],
		"dimension": {
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			},
			"Sex": {
				"category": {
					"index": [
						"All"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": false,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}')
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

# Allowing for whatever order geog codes appear in raw data
geog_codes <- c()
for (i in 1:length(json_data$dimension$LGD2014$category$index)) {
  geog_codes <- c(geog_codes, rep(json_data$dimension$LGD2014$category$index[i], length(categories)))
}

data <- data.frame(geog_code = geog_codes) %>%
  mutate(statistic = rep_len(categories, nrow(.)),
         VALUE = json_data$value) %>%
  group_by(geog_code) %>%
  mutate(perc = VALUE / sum(VALUE) * 100,
         source = dataset_short) %>%
  arrange(geog_code, statistic)

df_popage <- rbind(df_popage, data)

dataset_long <- "MYE01T010"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

json_data <- json_data_from_rpc(
  query = paste0(
    '{
  	"jsonrpc": "2.0",
  	"method": "PxStat.Data.Cube_API.ReadDataset",
  	"params": {
  		"class": "query",
  		"id": [
  			"TLIST(A1)",
  			"broadage4",
  			"Sex"
  		],
  		"dimension": {
  			"TLIST(A1)": {
  				"category": {
  					"index": [
  						"', latest_year, '"
  					]
  				}
  			},
  			"broadage4": {
  				"category": {
  					"index": [
  						"1",
  						"2",
  						"3",
  						"4"
  					]
  				}
  			},
  			"Sex": {
  				"category": {
  					"index": [
  						"All"
  					]
  				}
  			}
  		},
  		"extension": {
  			"pivot": null,
  			"codes": false,
  			"language": {
  				"code": "en"
  			},
  			"format": {
  				"type": "JSON-stat",
  				"version": "2.0"
  			},
  			"matrix": "', dataset_long, '"
  		},
  		"version": "2.0"
  	}
  }')
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

# Allowing for whatever order geog codes appear in raw data
geog_codes <- c()
for (i in 1:length(json_data$dimension$DEA2014$category$index)) {
  geog_codes <- c(geog_codes, rep(json_data$dimension$DEA2014$category$index[i], length(categories)))
}

data <- data.frame(geog_code = geog_codes) %>%
  mutate(statistic = rep_len(categories, nrow(.)),
         VALUE = json_data$value) %>%
  group_by(geog_code) %>%
  mutate(perc = VALUE / sum(VALUE) * 100,
         source = dataset_short) %>%
  filter(geog_code != "N92000002") %>%
  arrange(geog_code, statistic)

df_popage <- rbind(df_popage, data)

df_popage <- unique(df_popage)
##### population growth ####
df_popchange <- list()
dataset_short <- "PopChange"

dataset_long <- "MYE01T06"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"rounded_unrounded"
		],
		"dimension": {
			"rounded_unrounded": {
				"category": {
					"index": [
						"Unrounded"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": false,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}')
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
dataset_long <- "LPSHPI01"
#latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)


latest_year <- data_portal$dimension$`TLIST(Q1)`$category$index[[which(matrices == dataset_long)]] %>% tail(1)

dataset_short <- "houseprices"

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"TLIST(Q1)"
		],
		"dimension": {
			"TLIST(Q1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": false,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}')
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

dataset_long <- "LEDEA"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"TLIST(A1)"
		],
		"dimension": {
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": false,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}')
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

geog_codes <- c()
for (i in 1:length(json_data$dimension$DEA2014$category$index)) {
  geog_codes <- c(geog_codes, rep(json_data$dimension$DEA2014$category$index[i], length(categories)))
}

data <- data.frame(geog_code = geog_codes) %>%
  mutate(statistic = rep_len(categories, nrow(.)),
         VALUE = json_data$value,
         source = dataset_short) %>%
  arrange(geog_code, statistic)

df_le <- rbind(df_le, data)
###### LE by LGD ######
dataset_long <- "LELGD"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"TLIST(A1)"
		],
		"dimension": {
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": false,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}')
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

geog_codes <- c()
for (i in 1:length(json_data$dimension$LGD2014$category$index)) {
  geog_codes <- c(geog_codes, rep(json_data$dimension$LGD2014$category$index[i], length(categories)))
}

data <- data.frame(geog_code = geog_codes) %>%
  mutate(statistic = rep_len(categories, nrow(.)),
         VALUE = json_data$value,
         source = dataset_short) %>%
  arrange(geog_code, statistic)

df_le <- unique(rbind(df_le, data))


##### Happiness #####

dataset_long <- "WBPERSWLGD"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

dataset_short <- "wellbeing"

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"STATISTIC",
			"TLIST(A1)"
		],
		"dimension": {
			"STATISTIC": {
				"category": {
					"index": [
						"WBLIFE",
						"WBHAP"
					]
				}
			},
			"TLIST(A1)": {
				"category": {
					"index": [
						"2022/23"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": true,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "WBPERSWLGD"
		},
		"version": "2.0"
	}
}'
  )
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

geog_codes <- json_data$dimension$LGD2014$category$index

categories <- c()
for (i in 1:length(json_data$dimension$STATISTIC$category$index)) {
  categories <- c(categories, rep(json_data$dimension$STATISTIC$category$index[i], length(geog_codes)))
}

data <- data.frame(geog_code = rep(geog_codes, length(unique(categories)))) %>%
  mutate(STATISTIC = categories,
         VALUE = json_data$value)

dataset_long <- "WBPERSWOTHR"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"STATISTIC",
			"TLIST(A1)",
			"OTHRCAT"
		],
		"dimension": {
			"STATISTIC": {
				"category": {
					"index": [
						"WBLIFE",
						"WBHAP"
					]
				}
			},
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			},
			"OTHRCAT": {
				"category": {
					"index": [
						"N92000002"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": false,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long,'"
		},
		"version": "2.0"
	}
}'
  )
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

dataset_long <- "WBLONLGD"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

dataset_short <- "lonely"

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"TLIST(A1)"
		],
		"dimension": {
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": false,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}'
  )
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

data <- data.frame(geog_code = json_data$dimension$LGD2014$category$index) %>%
  mutate(STATISTIC = json_data$dimension$STATISTIC$category$index,
         VALUE = json_data$value)


dataset_long <- "WBLONOTHR"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"TLIST(A1)",
			"OTHRCAT"
		],
		"dimension": {
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			},
			"OTHRCAT": {
				"category": {
					"index": [
						"N92000002"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": false,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}'
  )
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

dataset_long <- "ADMITDEA"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

dataset_short <- "Admiss"

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"TLIST(A1)"
		],
		"dimension": {
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": false,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}'
  )
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

geog_codes <- c()
for (i in 1:length(json_data$dimension$DEA2014$category$index)) {
  geog_codes <- c(geog_codes, rep(json_data$dimension$DEA2014$category$index[i], length(pdiag)))
}

data <- data.frame(geog_code = geog_codes,
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

dataset_long <- "GPPRACPATLGD"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

dataset_short <- "GP"

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"STATISTIC",
			"TLIST(A1)"
		],
		"dimension": {
			"STATISTIC": {
				"category": {
					"index": [
						"PRACS",
						"GPS",
						"REGPAT",
						"PRACLIST"
					]
				}
			},
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": true,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}'
  )
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

geog_codes <- json_data$dimension$LGD2014$category$index

categories <- c()
for (i in 1:length(json_data$dimension$STATISTIC$category$index)) {
  categories <- c(categories, rep(json_data$dimension$STATISTIC$category$index[i], length(geog_codes)))
}

data <- data.frame(geog_code = rep(geog_codes, length(unique(categories))),
                   VALUE = json_data$value,
                   statistic = categories,
                   source = dataset_short)

df_gps <- rbind(df_gps, data)

dataset_long <- "GPPRACPATDEA"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

dataset_short <- "GP"

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"STATISTIC",
			"TLIST(A1)"
		],
		"dimension": {
			"STATISTIC": {
				"category": {
					"index": [
						"PRACS",
						"GPS",
						"REGPAT",
						"PRACLIST"
					]
				}
			},
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": true,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}'
  )
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



geog_codes <- json_data$dimension$DEA2014$category$index

categories <- c()
for (i in 1:length(json_data$dimension$STATISTIC$category$index)) {
  categories <- c(categories, rep(json_data$dimension$STATISTIC$category$index[i], length(geog_codes)))
}

data <- data.frame(geog_code = rep(geog_codes, length(unique(categories))),
                   VALUE = json_data$value,
                   statistic = categories,
                   source = dataset_short) %>%
  arrange(statistic, geog_code)

df_gps <- rbind(df_gps, data)


df_dental <- list()
dataset_short <- "DEN"

dataset_long <- "FPSGDSDSDEA"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"TLIST(A1)"
		],
		"dimension": {
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": false,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}'
  )
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

geog_codes <- json_data$dimension$DEA2014$category$index

categories <- c()
for (i in 1:length(json_data$dimension$STATISTIC$category$index)) {
  categories <- c(categories, rep(json_data$dimension$STATISTIC$category$index[i], length(geog_codes)))
}

data <- data.frame(geog_code = rep(geog_codes, length(unique(categories))),
                   statistic = categories,
                   VALUE = json_data$value,
                   source = dataset_short)

df_dental <- rbind(df_dental, data)


dataset_long <- "FPSGDSDSLGD"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"TLIST(A1)"
		],
		"dimension": {
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": false,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long,'"
		},
		"version": "2.0"
	}
}'
  )
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

geog_codes <- json_data$dimension$LGD2014$category$index

categories <- c()
for (i in 1:length(json_data$dimension$STATISTIC$category$index)) {
  categories <- c(categories, rep(json_data$dimension$STATISTIC$category$index[i], length(geog_codes)))
}

data <- data.frame(geog_code = rep(geog_codes, length(unique(categories))),
                   statistic = categories,
                   VALUE = json_data$value,
                   source = dataset_short)

df_dental <- rbind(df_dental, data)

dataset_short <- "DEN_REG"

dataset_long <- "FPSGDSDRLGD"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"TLIST(A1)",
			"Age"
		],
		"dimension": {
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			},
			"Age": {
				"category": {
					"index": [
						"All"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": false,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}'
  )
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

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"TLIST(A1)",
			"Age"
		],
		"dimension": {
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			},
			"Age": {
				"category": {
					"index": [
						"All"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": false,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}'
  )
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

dataset_long <- "LMSLGD"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"STATISTIC",
			"TLIST(A1)"
		],
		"dimension": {
			"STATISTIC": {
				"category": {
					"index": [
						"EMPN",
						"EMPR",
						"UNEMPR",
						"INACTR"
					]
				}
			},
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": true,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}'
  )
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

geog_codes <- json_data$dimension$LGD2014$category$index

categories <- c()
for (i in 1:length(json_data$dimension$STATISTIC$category$index)) {
  categories <- c(categories, rep(json_data$dimension$STATISTIC$category$index[i], length(geog_codes)))
}

data <- data.frame(geog_code = rep(geog_codes, length(unique(categories))),
                   statistic = categories,
                   VALUE = json_data$value,
                   source = dataset_short)

df_lmr <- rbind(df_lmr, data)

df_lmr_perc = df_lmr  %>% filter(statistic != "EMPN") %>% rename(perc = VALUE) %>% mutate(VALUE = NA)
df_lmr_value = df_lmr %>% filter(statistic == "EMPN")

##### ASHE #####
df_ashe <- list()
dataset_short <- "ASHE"

dataset_long <- "GAPLGD"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"STATISTIC",
			"TLIST(A1)",
			"WP",
			"Sex"
		],
		"dimension": {
			"STATISTIC": {
				"category": {
					"index": [
						"Median"
					]
				}
			},
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			},
			"WP": {
				"category": {
					"index": [
						"FT"
					]
				}
			},
			"Sex": {
				"category": {
					"index": [
						"All"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": false,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}'
  )
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

dataset_long <- "GHWPLGD"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"STATISTIC",
			"TLIST(A1)",
			"PR",
			"WP",
			"Sex"
		],
		"dimension": {
			"STATISTIC": {
				"category": {
					"index": [
						"Median"
					]
				}
			},
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			},
			"PR": {
				"category": {
					"index": [
						"Wkly"
					]
				}
			},
			"WP": {
				"category": {
					"index": [
						"All"
					]
				}
			},
			"Sex": {
				"category": {
					"index": [
						"All"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": true,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}'
  )
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

dataset_long <- "BRESHEADLGD"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"TLIST(A1)",
			"GENWP",
			"HEADLINE"
		],
		"dimension": {
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year,'"
					]
				}
			},
			"GENWP": {
				"category": {
					"index": [
						"All"
					]
				}
			},
			"HEADLINE": {
				"category": {
					"index": [
						"Construction",
						"Manufacturing",
						"Services",
						"Other"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": false,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}'
  )
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

categories <- json_data$dimension$HEADLINE$category$index

geog_codes <- c()
for(i in 1:length(json_data$dimension$LGD2014$category$index)) {
  geog_codes <- c(geog_codes, rep(json_data$dimension$LGD2014$category$index[i], length(categories)))
}

data <- data.frame(geog_code = geog_codes) %>%
  mutate(statistic = rep_len(categories, nrow(.)),
         VALUE = json_data$value,
         source = dataset_short) %>%
  group_by(geog_code) %>%
  mutate(perc = VALUE / sum(VALUE) * 100)


df_indust <- rbind(df_indust, data)


##### Benefits #####
df_bs <- list()
dataset_short <- "BS"

dataset_long <- "BSDEA"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"TLIST(A1)"
		],
		"dimension": {
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": false,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}'
  )
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
    
geog_codes <- json_data$dimension$DEA2014$category$index

categories <- c()
for (i in 1:length(json_data$dimension$STATISTIC$category$index)) {
  categories <- c(categories, rep(json_data$dimension$STATISTIC$category$index[i], length(geog_codes)))
}

data <- data.frame(geog_code = rep(geog_codes, length(unique(categories))),
                   VALUE = json_data$value,
                   statistic = categories,
                   source = dataset_short)

df_bs <- rbind(df_bs, data)

dataset_long <- "BSLGD"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"TLIST(A1)"
		],
		"dimension": {
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": false,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}'
  )
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

geog_codes <- json_data$dimension$LGD2014$category$index

categories <- c()
for (i in 1:length(json_data$dimension$STATISTIC$category$index)) {
  categories <- c(categories, rep(json_data$dimension$STATISTIC$category$index[i], length(geog_codes)))
}

data <- data.frame(geog_code = rep(geog_codes, length(unique(categories))),
                   VALUE = json_data$value,
                   statistic = categories,
                   source = dataset_short)

df_bs <- rbind(df_bs, data)

dataset_long <- "BSSDZ"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"TLIST(A1)"
		],
		"dimension": {
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": false,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}'
  )
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

geog_codes <- json_data$dimension$SDZ2021$category$index

categories <- c()
for (i in 1:length(json_data$dimension$STATISTIC$category$index)) {
  categories <- c(categories, rep(json_data$dimension$STATISTIC$category$index[i], length(geog_codes)))
}

data <- data.frame(geog_code = rep(geog_codes, length(unique(categories))),
                   VALUE = json_data$value,
                   statistic = categories,
                   source = dataset_short)

df_bs <- rbind(df_bs, data)


dataset_long <- "BSDZ"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"TLIST(A1)"
		],
		"dimension": {
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": false,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}'
  )
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

geog_codes <- json_data$dimension$DZ2021$category$index

categories <- c()
for (i in 1:length(json_data$dimension$STATISTIC$category$index)) {
  categories <- c(categories, rep(json_data$dimension$STATISTIC$category$index[i], length(geog_codes)))
}

data <- data.frame(geog_code = rep(geog_codes, length(unique(categories))),
                   VALUE = json_data$value,
                   statistic = categories,
                   source = dataset_short)

df_bs <- rbind(df_bs, data)

#### Education ####

##### Schools #####
##### FSME #####


df_school_value <- list()
df_school_perc <- list()
dataset_short <- "Primary"

dataset_long <- "DESCPDEA"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)



json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"STATISTIC",
			"TLIST(A1)"
		],
		"dimension": {
			"STATISTIC": {
				"category": {
					"index": [
						"FSME",
						"SENNonStatemented",
						"SENStatement",
						"All"
					]
				}
			},
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": true,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}'
  )
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
  
geog_codes <- json_data$dimension$DEA2014$category$index

categories <- c()
for (i in 1:length(json_data$dimension$STATISTIC$category$index)) {
  categories <- c(categories, rep(json_data$dimension$STATISTIC$category$index[i], length(geog_codes)))
}

data <- data.frame(geog_code = rep(geog_codes, length(unique(categories))),
                   VALUE = json_data$value,
                   statistic = categories,
                   source = dataset_short) %>%
  group_by(geog_code)


data_value <- data %>%
  select(geog_code, statistic, VALUE, source)


df_school_value <- rbind(df_school_value, data_value)


dataset_long <- "DESCPLGD"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"STATISTIC",
			"TLIST(A1)"
		],
		"dimension": {
			"STATISTIC": {
				"category": {
					"index": [
						"FSME",
						"SENNonStatemented",
						"SENStatement",
						"All"
					]
				}
			},
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": false,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}'
  )
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

geog_codes <- json_data$dimension$LGD2014$category$index

categories <- c()
for (i in 1:length(json_data$dimension$STATISTIC$category$index)) {
  categories <- c(categories, rep(json_data$dimension$STATISTIC$category$index[i], length(geog_codes)))
}

data <- data.frame(geog_code = rep(geog_codes, length(unique(categories))),
                   VALUE = json_data$value,
                   statistic = categories,
                   source = dataset_short) %>%
  group_by(geog_code)

data_value <- data %>%
  select(geog_code, statistic, VALUE, source)


df_school_value <- rbind(df_school_value, data_value)


dataset_short <- "PostPrimary"

dataset_long <- "DESCPPDEA"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)


json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"STATISTIC",
			"TLIST(A1)"
		],
		"dimension": {
			"STATISTIC": {
				"category": {
					"index": [
						"FSME",
						"SENNonStatemented",
						"SENStatement",
						"All"
					]
				}
			},
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": false,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long,'"
		},
		"version": "2.0"
	}
}'
  )
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
 
geog_codes <- json_data$dimension$DEA2014$category$index

categories <- c()
for (i in 1:length(json_data$dimension$STATISTIC$category$index)) {
  categories <- c(categories, rep(json_data$dimension$STATISTIC$category$index[i], length(geog_codes)))
}

data <- data.frame(geog_code = rep(geog_codes, length(unique(categories))),
                   VALUE = json_data$value,
                   statistic = categories,
                   source = dataset_short) %>%
  group_by(geog_code)

data_value <- data %>%
  select(geog_code, statistic, VALUE, source)

df_school_value <- rbind(df_school_value, data_value)


dataset_long <- "DESCPPLGD"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"STATISTIC",
			"TLIST(A1)"
		],
		"dimension": {
			"STATISTIC": {
				"category": {
					"index": [
						"FSME",
						"SENNonStatemented",
						"SENStatement",
						"All"
					]
				}
			},
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": false,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}'
  )
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
   
geog_codes <- json_data$dimension$LGD2014$category$index

categories <- c()
for (i in 1:length(json_data$dimension$STATISTIC$category$index)) {
  categories <- c(categories, rep(json_data$dimension$STATISTIC$category$index[i], length(geog_codes)))
}

data <- data.frame(geog_code = rep(geog_codes, length(unique(categories))),
                   VALUE = json_data$value,
                   statistic = categories,
                   source = dataset_short) %>%
  group_by(geog_code)

data_value <- data %>%
  select(geog_code, statistic, VALUE, source)


df_school_value <- rbind(df_school_value, data_value)


##### SEN ####

dataset_short <- "SEN"

dataset_long <- "DESCSDEA"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"STATISTIC",
			"TLIST(A1)"
		],
		"dimension": {
			"STATISTIC": {
				"category": {
					"index": [
						"SENNonStatemented",
						"SENStatement"
					]
				}
			},
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": false,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}'
  )
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

geog_codes <- json_data$dimension$DEA2014$category$index

categories <- c()
for (i in 1:length(json_data$dimension$STATISTIC$category$index)) {
  categories <- c(categories, rep(json_data$dimension$STATISTIC$category$index[i], length(geog_codes)))
}

data <- data.frame(geog_code = rep(geog_codes, length(unique(categories))),
                   VALUE = json_data$value,
                   statistic = categories,
                   source = dataset_short)

df_school_value <- unique(rbind(df_school_value, data))

dataset_long <- "DESCSLGD"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"STATISTIC",
			"TLIST(A1)"
		],
		"dimension": {
			"STATISTIC": {
				"category": {
					"index": [
						"SENNonStatemented",
						"SENStatement",
						"All"
					]
				}
			},
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": false,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long,'"
		},
		"version": "2.0"
	}
}'
  )
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

geog_codes <- json_data$dimension$LGD2014$category$index

categories <- c()
for (i in 1:length(json_data$dimension$STATISTIC$category$index)) {
  categories <- c(categories, rep(json_data$dimension$STATISTIC$category$index[i], length(geog_codes)))
}

data <- data.frame(geog_code = rep(geog_codes, length(unique(categories))),
                   VALUE = json_data$value,
                   statistic = categories,
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

dataset_long <- "DETNPTRLGD"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"TLIST(A1)",
			"TNschooltype"
		],
		"dimension": {
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			},
			"TNschooltype": {
				"category": {
					"index": [
						"All"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": false,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}'
  )
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

dataset_long <- "DESLSALGD"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"STATISTIC",
			"TLIST(A1)",
			"FSME"
		],
		"dimension": {
			"STATISTIC": {
				"category": {
					"index": [
						"fivegcseatocincengmathpct"
					]
				}
			},
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			},
			"FSME": {
				"category": {
					"index": [
						"All"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": true,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}'
  )
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

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"STATISTIC",
			"TLIST(A1)",
			"FSME"
		],
		"dimension": {
			"STATISTIC": {
				"category": {
					"index": [
						"fivegcseatocincengmathpct"
					]
				}
			},
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			},
			"FSME": {
				"category": {
					"index": [
						"All"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": true,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}'
  )
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

dataset_long <- "FEENROLLGD"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"TLIST(A1)"
		],
		"dimension": {
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year,'"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": false,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}'
  )
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

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"TLIST(A1)"
		],
		"dimension": {
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": false,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}'
  )
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

dataset_long <- "HEENROLLGD"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"TLIST(A1)"
		],
		"dimension": {
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": false,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}'
  )
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

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"TLIST(A1)"
		],
		"dimension": {
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": false,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}'
  )
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

dataset_long <- "DESLSDDEA"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"STATISTIC",
			"TLIST(A1)"
		],
		"dimension": {
			"STATISTIC": {
				"category": {
					"index": [
						"destHEpct",
						"destFEpct",
						"destEmploypct",
						"destTrainpct",
						"destUnempUnkpct"
					]
				}
			},
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": true,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long,'"
		},
		"version": "2.0"
	}
}'
  )
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

geog_codes <- json_data$dimension$DEA2014$category$index

categories <- c()
for (i in 1:length(json_data$dimension$STATISTIC$category$index)) {
  categories <- c(categories, rep(json_data$dimension$STATISTIC$category$index[i], length(geog_codes)))
}

data <- data.frame(geog_code = rep(geog_codes, length(unique(categories))),
                   statistic = categories,
                   VALUE = json_data$value,
                   source = dataset_short)

df_school_destination <- unique(rbind(df_school_destination, data))

dataset_long <- "DESLSDLGD"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"STATISTIC",
			"TLIST(A1)",
			"FSME"
		],
		"dimension": {
			"STATISTIC": {
				"category": {
					"index": [
						"destHEpct",
						"destFEpct",
						"destEmploypct",
						"destTrainpct",
						"destUnempUnkpct"
					]
				}
			},
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			},
			"FSME": {
				"category": {
					"index": [
						"All"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": false,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}'
  )
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

geog_codes <- json_data$dimension$LGD2014$category$index

categories <- c()
for (i in 1:length(json_data$dimension$STATISTIC$category$index)) {
  categories <- c(categories, rep(json_data$dimension$STATISTIC$category$index[i], length(geog_codes)))
}

data <- data.frame(geog_code = rep(geog_codes, length(unique(categories))),
                   statistic = categories,
                   VALUE = json_data$value,
                   source = dataset_short)

df_school_destination <- unique(rbind(df_school_destination, data))
df_school_destination_perc = df_school_destination %>% rename(perc = VALUE) %>% mutate(VALUE = NA)

#### Environment ####
df_env <- list()
df_env_perc <- list()

##### Concern #####

dataset_short <- "Env_concern"

dataset_long <- "CHSCONCERNLGD"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"TLIST(A1)"
		],
		"dimension": {
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": false,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}'
  )
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

geog_codes <- json_data$dimension$LGD2014$category$index

categories <- c()
for (i in 1:length(json_data$dimension$STATISTIC$category$index)) {
  categories <- c(categories, rep(json_data$dimension$STATISTIC$category$index[i], length(geog_codes)))
}

data <- data.frame(geog_code = rep(geog_codes, length(unique(categories))),
                   statistic = categories,
                   VALUE = json_data$value,
                   source = dataset_short,
                   perc = json_data$value)

df_env_perc <- rbind(df_env_perc, data)



dataset_short <- "Env_problem"

dataset_long <- "CHSENVIPROBLGD"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)


json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"TLIST(A1)"
		],
		"dimension": {
			"TLIST(A1)": {
				"category": {
					"index": [
						"2019/20"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": false,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "CHSENVIPROBLGD"
		},
		"version": "2.0"
	}
}'
  )
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

geog_codes <- json_data$dimension$LGD2014$category$index

categories <- c()
for (i in 1:length(json_data$dimension$STATISTIC$category$index)) {
  categories <- c(categories, rep(json_data$dimension$STATISTIC$category$index[i], length(geog_codes)))
}

data <- data.frame(geog_code = rep(geog_codes, length(unique(categories))),
                   statistic = categories,
                   VALUE = json_data$value,
                   source = dataset_short,
                   perc = json_data$value) %>%
  mutate(problem_reason = factor(statistic,
                                 levels = json_data$dimension$STATISTIC$category$index,
                                 labels = unlist(json_data$dimension$STATISTIC$category$label))) %>%
  group_by(geog_code, source) %>%
  slice_max(VALUE, n = 3) %>%
  summarise(reason = paste(problem_reason, collapse = "; "))


df_env_problems = data


dataset_short <- "Env_waste"

##### waste #####
dataset_long <- "WASTELGD"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)


json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"STATISTIC",
			"TLIST(A1)"
		],
		"dimension": {
			"STATISTIC": {
				"category": {
					"index": [
						"LACMWR",
						"LACMWL",
						"LACMWER"
					]
				}
			},
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": true,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}'
  )
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

geog_codes <- json_data$dimension$LGD2014$category$index

categories <- c()
for (i in 1:length(json_data$dimension$STATISTIC$category$index)) {
  categories <- c(categories, rep(json_data$dimension$STATISTIC$category$index[i], length(geog_codes)))
}

data <- data.frame(geog_code = rep(geog_codes, length(unique(categories))),
                   statistic = categories,
                   VALUE = json_data$value,
                   source = dataset_short,
                   perc = json_data$value)

df_env_perc <- rbind(df_env_perc, data)

##### GHG #####

dataset_short <- "Env_ghg"

dataset_long <- "GHGALL"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"TLIST(A1)",
			"GHGSECTOR"
		],
		"dimension": {
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			},
			"GHGSECTOR": {
				"category": {
					"index": [
						"GTALL"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": false,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}'
  )
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

geog_codes <- json_data$dimension$LGD2014$category$index

categories <- c()
for (i in 1:length(json_data$dimension$STATISTIC$category$index)) {
  categories <- c(categories, rep(json_data$dimension$STATISTIC$category$index[i], length(geog_codes)))
}

data <- data.frame(geog_code = rep(geog_codes, length(unique(categories))),
                   statistic = categories,
                   VALUE = json_data$value,
                   source = dataset_short)

df_env <- rbind(df_env, data)


json_data_base <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"STATISTIC",
			"TLIST(A1)",
			"GHGSECTOR"
		],
		"dimension": {
			"STATISTIC": {
				"category": {
					"index": [
						"GHGALL"
					]
				}
			},
			"TLIST(A1)": {
				"category": {
					"index": [
						"2005"
					]
				}
			},
			"GHGSECTOR": {
				"category": {
					"index": [
						"GTALL"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": true,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "GHGALL"
		},
		"version": "2.0"
	}
}'
  )
)

data <- data.frame(geog_code = json_data_base$dimension$LGD2014$category$index,
                   statistic = "GHGALL_BASE",
                   VALUE = json_data_base$value,
                   source = dataset_short)

df_env <- rbind(df_env, data)

##### active travel #####

dataset_short <- "Env_active"

dataset_long <- "JMWCPTLGD"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"TLIST(A1)"
		],
		"dimension": {
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": false,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}'
  )
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
                   statistic = json_data$dimension$STATISTIC$category$index,
                   VALUE = json_data$value,
                   source = dataset_short)

df_env <- rbind(df_env, data)


#### Crime ####
##### PSNI recorded crime ####

df_crime <- list()
dataset_short <- "crime"

dataset_long <- "PRCDEA"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"TLIST(A1)"
		],
		"dimension": {
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year,'"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": false,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}'
  )
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

categories <- json_data$dimension$crmclass$category$index

geog_codes <- c()
for (i in 1:length(json_data$dimension$DEA2014$category$index)) {
  geog_codes <- c(geog_codes, rep(json_data$dimension$DEA2014$category$index[i], length(categories)))
}

data <- data.frame(geog_code = geog_codes,
                   statistic = rep(categories, length(unique(geog_codes))),
                   VALUE = json_data$value) %>%
  mutate(crime_group = case_when(as.numeric(statistic) <= 3 ~ "person",
                                 as.numeric(statistic) == 4 ~ "sexual",
                                 as.numeric(statistic) == 5 ~ "robbery",
                                 as.numeric(statistic) <= 9 ~ "theft_burglary",
                                 as.numeric(statistic) <= 14 ~ "theft",
                                 as.numeric(statistic) == 15 ~ "criminal",
                                 as.numeric(statistic) <= 20 ~ "other",
                                 statistic == "All" ~ "allcrime",
                                 TRUE ~ statistic)) %>%
  group_by(geog_code, crime_group) %>%
  summarise(VALUE = sum(VALUE, na.rm = TRUE)) %>%
  mutate(source = dataset_short) %>%
  rename(statistic = crime_group)

df_crime <- rbind(df_crime, data)

burglary_data <- data.frame(geog_code = geog_codes,
                            statistic = rep(categories, length(unique(geog_codes))),
                            VALUE = json_data$value) %>%
  filter(as.numeric(statistic) %in% 6:7) %>%
  mutate(crime_group = "burglary") %>%
  group_by(geog_code, crime_group) %>%
  summarise(VALUE = sum(VALUE, na.rm = TRUE)) %>%
  mutate(source = dataset_short) %>%
  rename(statistic = crime_group)

df_crime <- rbind(df_crime, burglary_data)


dataset_long <- "PRCLGD"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"TLIST(A1)"
		],
		"dimension": {
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": false,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}'
  )
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

categories <- json_data$dimension$crmclass$category$index

geog_codes <- c()
for (i in 1:length(json_data$dimension$LGD2014$category$index)) {
  geog_codes <- c(geog_codes, rep(json_data$dimension$LGD2014$category$index[i], length(categories)))
}

data <- data.frame(geog_code = geog_codes,
                   statistic = rep(categories, length(unique(geog_codes))),
                   VALUE = json_data$value) %>%
  mutate(crime_group = case_when(as.numeric(statistic) <= 3 ~ "person",
                                 as.numeric(statistic) == 4 ~ "sexual",
                                 as.numeric(statistic) == 5 ~ "robbery",
                                 as.numeric(statistic) <= 9 ~ "theft_burglary",
                                 as.numeric(statistic) <= 14 ~ "theft",
                                 as.numeric(statistic) == 15 ~ "criminal",
                                 as.numeric(statistic) <= 20 ~ "other",
                                 statistic == "All" ~ "allcrime",
                                 TRUE ~ statistic)) %>%
  group_by(geog_code, crime_group) %>%
  summarise(VALUE = sum(VALUE, na.rm = TRUE)) %>%
  mutate(source = dataset_short) %>%
  rename(statistic = crime_group)

df_crime <- unique(rbind(df_crime, data))

burglary_data <- data.frame(geog_code = geog_codes,
                            statistic = rep(categories, length(unique(geog_codes))),
                            VALUE = json_data$value) %>%
  filter(as.numeric(statistic) %in% 6:7) %>%
  mutate(crime_group = "burglary") %>%
  group_by(geog_code, crime_group) %>%
  summarise(VALUE = sum(VALUE, na.rm = TRUE)) %>%
  mutate(source = dataset_short) %>%
  rename(statistic = crime_group)

df_crime <- unique(rbind(df_crime, burglary_data))

df_crime_perc <- df_crime %>%  group_by(geog_code) %>% filter(statistic != "burglary") %>% 
  mutate(perc = VALUE / VALUE[statistic == "allcrime"] *100) 

df_crime_perc %>% filter(geog_code == "N92000002")

##### Worry ####
dataset_short <- "crimeworry"

dataset_long <- "TWORRYCRMLGD"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"STATISTIC",
			"TLIST(A1)"
		],
		"dimension": {
			"STATISTIC": {
				"category": {
					"index": [
						"WorryC1",
						"WorryC2",
						"WorryC3",
						"WorryC4"
					]
				}
			},
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": true,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}'
  )
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

geog_codes <- json_data$dimension$LGD2014$category$index

categories <- c()
for (i in 1:length(json_data$dimension$STATISTIC$category$index)) {
  categories <- c(categories, rep(json_data$dimension$STATISTIC$category$index[i], length(geog_codes)))
}

data <- data.frame(geog_code = rep(geog_codes, length(unique(categories))),
                   statistic = categories,
                   VALUE = json_data$value,
                   source = dataset_short) %>%
  group_by(geog_code) %>% 
  slice_max(VALUE) %>%
  mutate(reason = factor(statistic,
                         levels = json_data$dimension$STATISTIC$category$index,
                         labels = gsub("High level of Worry: ",
                                       "",
                                       unlist(json_data$dimension$STATISTIC$category$label)))) %>%
  select(geog_code, reason, source)


df_crime_text  <- data

data <- data.frame(geog_code = rep(geog_codes, length(unique(categories))),
                   statistic = categories,
                   VALUE = json_data$value,
                   source = dataset_short) %>% 
  filter( statistic == "WorryC2")


df_crime <- unique(rbind(df_crime, data))


##### perception ####
dataset_short <- "crimeperception"

dataset_long <- "TNISCSASBLGD"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"STATISTIC",
			"TLIST(A1)"
		],
		"dimension": {
			"STATISTIC": {
				"category": {
					"index": [
						"ASB8"
					]
				}
			},
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": true,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}'
  )
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

dataset_long <- "BUSINESSBIGLGD"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"TLIST(A1)",
			"BIG"
		],
		"dimension": {
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			},
			"BIG": {
				"category": {
					"index": [
						"All"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": false,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}'
  )
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

df_business <- rbind(df_business, data)


dataset_short <- "businesstype"

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"TLIST(A1)"
		],
		"dimension": {
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": false,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}'
  )
)

categories <- json_data$dimension$BIG$category$index

geog_codes <- c()
for (i in 1:length(json_data$dimension$LGD2014$category$index)) {
  geog_codes <- c(geog_codes, rep(json_data$dimension$LGD2014$category$index[i], length(categories)))
}

data <- data.frame(statistic = rep(categories, length(unique(geog_codes)))) %>%
  mutate(geog_code = geog_codes,
         VALUE = json_data$value,
         source = dataset_short) %>%
  mutate(big_group = case_when(statistic %in% c(1) ~ 'agr',
                               statistic %in% c(4) ~ 'cons',
                               statistic %in% c(3) ~ 'prod',
                               statistic %in% c(5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18) ~ 'serv',
                               TRUE ~ statistic)) %>% 
  group_by(geog_code, big_group, source) %>% summarise(VALUE = sum(VALUE, na.rm=TRUE)) %>%
  rename(statistic = "big_group" )

df_business <- rbind(df_business, data)

dataset_short <- "businessband"
dataset_long <- "BUSINESSBANDLGD"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)


json_data_E <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"TLIST(A1)",
			"BIG",
			"TOBAND"
		],
		"dimension": {
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			},
			"BIG": {
				"category": {
					"index": [
						"All"
					]
				}
			},
			"TOBAND": {
				"category": {
					"index": [
						"All"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": false,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long,'"
		},
		"version": "2.0"
	}
}'
  )
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

categories_E <- json_data_E$dimension$EMPBAND$category$index
                
geog_codes <- c()
for (i in 1:length(json_data_E$dimension$LGD2014$category$index)) {
  geog_codes <- c(geog_codes, rep(json_data_E$dimension$LGD2014$category$index[i], length(categories_E)))
}

data <- data.frame(statistic = rep(categories_E, length(unique(geog_codes))),
                   geog_code = geog_codes,
                   VALUE = json_data_E$value,
                   source = dataset_short) %>%
  group_by(geog_code)


df_business <- rbind(df_business, data)

json_data_T <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"TLIST(A1)",
			"BIG",
			"EMPBAND"
		],
		"dimension": {
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			},
			"BIG": {
				"category": {
					"index": [
						"All"
					]
				}
			},
			"EMPBAND": {
				"category": {
					"index": [
						"All"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": true,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}'
  )
)

categories_T <- json_data_T$dimension$TOBAND$category$index

geog_codes <- c()
for (i in 1:length(json_data_T$dimension$LGD2014$category$index)) {
  geog_codes <- c(geog_codes, rep(json_data_T$dimension$LGD2014$category$index[i], length(categories_T)))
}

data <- data.frame(statistic = rep(categories_T, length(unique(geog_codes))),
                   geog_code = geog_codes,
                   VALUE = json_data_T$value,
                   source = dataset_short) %>%
  group_by(geog_code)


df_business <- rbind(df_business, data)



##### farms #####
dataset_short <- "farms"
dataset_long <- "FCLGD"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"STATISTIC",
			"TLIST(A1)"
		],
		"dimension": {
			"STATISTIC": {
				"category": {
					"index": [
						"F",
						"FA"
					]
				}
			},
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year,'"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": true,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long,'"
		},
		"version": "2.0"
	}
}'
  )
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


geog_codes <- json_data$dimension$LGD2014$category$index

categories <- c()
for (i in 1:length(json_data$dimension$STATISTIC$category$index)) {
  categories <- c(categories, rep(json_data$dimension$STATISTIC$category$index[i], length(geog_codes)))
}

data <- data.frame(geog_code = rep(geog_codes, length(unique(categories))),
                   statistic = categories,
                   VALUE = json_data$value,
                   source = dataset_short)

df_business <- rbind(df_business, data)

dataset_short <- "farms"
dataset_long <- "FCDEA"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"STATISTIC",
			"TLIST(A1)"
		],
		"dimension": {
			"STATISTIC": {
				"category": {
					"index": [
						"F",
						"FA"
					]
				}
			},
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": true,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}'
  )
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

geog_codes <- json_data$dimension$DEA2014$category$index

categories <- c()
for (i in 1:length(json_data$dimension$STATISTIC$category$index)) {
  categories <- c(categories, rep(json_data$dimension$STATISTIC$category$index[i], length(geog_codes)))
}

data <- data.frame(geog_code = rep(geog_codes, length(unique(categories))),
                   statistic = categories,
                   VALUE = json_data$value,
                   source = dataset_short)

df_business <- rbind(df_business, data)

##### tourism #####

dataset_short <- "tourism"
dataset_long <- "EJOBSLGD"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"TLIST(A1)",
			"EMJOBS"
		],
		"dimension": {
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			},
			"EMJOBS": {
				"category": {
					"index": [
						"All",
						"TJ"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": true,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long ,'"
		},
		"version": "2.0"
	}
}'
  )
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


categories <- json_data$dimension$EMJOBS$category$index

geog_codes <- c()
for (i in 1:length(json_data$dimension$LGD2014$category$index)) {
  geog_codes <- c(geog_codes, rep(json_data$dimension$LGD2014$category$index[i], 
                                  length(categories)))
}

data <- data.frame(geog_code = geog_codes,
                   statistic = rep(categories, length(unique(geog_codes))),
                   VALUE = json_data$value,
                   source = dataset_short) %>%
  mutate(statistic = factor(statistic,
                            levels = c("All", "TJ"),
                            labels = c("AllJobs", "TourismJobs"))) %>%
  arrange(geog_code)

df_business <- rbind(df_business, data)


dataset_short <- "tourism_estab"
dataset_long <- "CASLGD"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"STATISTIC",
			"TLIST(A1)"
		],
		"dimension": {
			"STATISTIC": {
				"category": {
					"index": [
						"All"
					]
				}
			},
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": true,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}'
  )
)


categories <- json_data$dimension$Estb$category$index

geog_codes <- c()
for (i in 1:length(json_data$dimension$LGD2014$category$index)) {
  geog_codes <- c(geog_codes, rep(json_data$dimension$LGD2014$category$index[i], length(categories)))
}

data <- data.frame(geog_code = geog_codes,
                   statistic = rep(categories, length(unique(geog_codes))),
                   VALUE = json_data$value) %>%
  group_by(geog_code) %>%
  summarise(VALUE = sum(VALUE, na.rm = TRUE)) %>%
  mutate(source = dataset_short,
         statistic = "estab")


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

df_business <- rbind(df_business, data)

df_business <- unique(df_business)

df_business_perc <- df_business %>%  group_by(geog_code) %>% 
  filter(statistic %in% c('agr', 'cons', 'prod', 'serv', 
                          'E1','E2', 'E3', 'E4', 'E5', 
                          'T1', 'T2', 'T3', 'T4', 'T5', 'All')) %>%
  mutate(perc = VALUE / VALUE[statistic == "All"] *100) 


##### niets #####

dataset_short <- "niets_sales"
dataset_long <- "NIETS05"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"STATISTIC",
			"TLIST(A1)",
			"FLOW"
		],
		"dimension": {
			"STATISTIC": {
				"category": {
					"index": [
						"BESESVALUE"
					]
				}
			},
			"TLIST(A1)": {
				"category": {
					"index": [
						"', latest_year, '"
					]
				}
			},
			"FLOW": {
				"category": {
					"index": [
						"SALES"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": true,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "', dataset_long, '"
		},
		"version": "2.0"
	}
}'
  )
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

geog_codes <- json_data$dimension$LGD$category$index

categories <- c()
for (i in 1:length(json_data$dimension$BROADDEST$category$index)) {
  categories <- c(categories, rep(json_data$dimension$BROADDEST$category$index[i], length(geog_codes)))
}

data <- data.frame(geog_code = rep(geog_codes, length(unique(categories))),
                   statistic = categories,
                   VALUE = json_data$value,
                   source = dataset_short)

data_ni <- data %>%
  group_by(statistic, source) %>% 
  summarise(VALUE = sum(VALUE, na.rm = TRUE)) %>% 
  mutate(geog_code = "N92000002") 

data <- rbind(data, data_ni)

df_business <- rbind(df_business, data)


dataset_short <- "niets_purch"
dataset_long <- "NIETS05"
latest_year <- years[[which(matrices == dataset_long)]] %>% tail(1)

json_data <- json_data_from_rpc(
  query = paste0(
    '{
	"jsonrpc": "2.0",
	"method": "PxStat.Data.Cube_API.ReadDataset",
	"params": {
		"class": "query",
		"id": [
			"STATISTIC",
			"TLIST(A1)",
			"FLOW"
		],
		"dimension": {
			"STATISTIC": {
				"category": {
					"index": [
						"BESESVALUE"
					]
				}
			},
			"TLIST(A1)": {
				"category": {
					"index": [
						"2022"
					]
				}
			},
			"FLOW": {
				"category": {
					"index": [
						"PURCH"
					]
				}
			}
		},
		"extension": {
			"pivot": null,
			"codes": true,
			"language": {
				"code": "en"
			},
			"format": {
				"type": "JSON-stat",
				"version": "2.0"
			},
			"matrix": "NIETS05"
		},
		"version": "2.0"
	}
}'
  )
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

geog_codes <- json_data$dimension$LGD$category$index

categories <- c()
for (i in 1:length(json_data$dimension$BROADDEST$category$index)) {
  categories <- c(categories, rep(json_data$dimension$BROADDEST$category$index[i], length(geog_codes)))
}

data <- data.frame(geog_code = rep(geog_codes, length(unique(categories))),
                   statistic = categories,
                   VALUE = json_data$value,
                   source = dataset_short)

data_ni <- data %>% 
  group_by(statistic, source) %>% 
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

df_dp_all_perc$statistic <- as.factor(df_dp_all_perc$statistic)



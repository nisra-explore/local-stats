# print(df_geog_codes_for_loop[i, 1])
df_all_data_portal_subset <- df_dp_all_values %>%
  subset(geog_code == df_geog_codes_for_loop[i, 1] %>% pull()) %>% arrange(desc(geog_code))

df_all_data_portal_subset_perc <- df_dp_all_perc %>%
  subset(geog_code == df_geog_codes_for_loop[i, 1] %>% pull()) %>% arrange(desc(geog_code))


# df_all_data_portal_subset_incl_ni = df_dp_all_values %>%
#   subset(geog_code == df_geog_codes_for_loop[i, 1] %>% pull() | geog_code == "N92000002") # %>% subset(source_short == "BS")

df_all_data_portal_subset_incl_ni <- df_dp_all_perc %>%
  subset(geog_code == df_geog_codes_for_loop[i, 1] %>% pull() | geog_code == "N92000002") %>%
  mutate(geog_name = case_when(
    geog_code == "N92000002" ~ "Northern Ireland",
    TRUE ~ geog_name_loop
  )) %>%
  ungroup() %>% arrange(desc(geog_code))



# Loop for value data
if (nrow(df_all_data_portal_subset) > 0) {
  assign(paste0("v_", "source"), unique(df_all_data_portal_subset[["source"]]))

  for (s in 1:length(v_source)) {
    df_temp1 <- df_all_data_portal_subset %>% filter(source == v_source[s])

    assign(paste0("v_", "statistic_code"), unique(df_temp1[["statistic"]]))


    for (t in 1:length(v_statistic_code)) {
      if (!is.na(v_statistic_code[t]) & !is.na(v_source[s])) {
        #   print(v_statistic_code[t])
        #    print(t)
        if (!is.na(as.numeric(v_statistic_code[t]))) {
          v_statistic_code_value <- paste0("`", v_statistic_code[t], "`")
        } else {
          v_statistic_code_value <- v_statistic_code[t]
        }

        json_text <- paste0("df_json_template$data$", v_source[s], "$value$", v_statistic_code_value)
        data_value <- df_all_data_portal_subset %>%
          subset(source == v_source[s] & statistic == v_statistic_code[t]) %>%
          pull(VALUE)
        r_string <- paste0(json_text, " = ", as.character(data_value))
        eval(parse(text = r_string))
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


if (nrow(df_all_data_portal_subset_perc) > 0) {
  assign(paste0("v_", "source"), unique(df_all_data_portal_subset_perc[["source"]]))
  
  for (s in 1:length(v_source)) {
    df_temp1 <- df_all_data_portal_subset_perc %>% filter(source == v_source[s])
    
    assign(paste0("v_", "statistic_code"), unique(df_temp1[["statistic"]]))
    
    
    for (t in 1:length(v_statistic_code)) {
      if (!is.na(v_statistic_code[t]) & !is.na(v_source[s])) {
        #   print(v_statistic_code[t])
        #    print(t)
        if (!is.na(as.numeric(v_statistic_code[t]))) {
          v_statistic_code_value <- paste0("`", v_statistic_code[t], "`")
        } else {
          v_statistic_code_value <- v_statistic_code[t]
        }
        
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
# 
# # Loop for perc data
# assign(paste0("v_", "source"), unique(df_all_data_portal_subset_incl_ni[["source"]]))
# for (t in 1:length(v_source)) {
# 
#   df_temp1 <- df_all_data_portal_subset_incl_ni %>% subset(source == v_source[t]) %>% arrange(desc(geog_code))
#   df_temp_areaonly <- df_all_data_portal_subset_incl_ni %>% subset(source == v_source[t] & geog_code == df_geog_codes_for_loop[i, 1] %>% pull() )
#   
#   assign(paste0("v_", "statistic_code"), unique(df_temp1[["statistic"]]))
# 
# 
#   if (geog_code_loop != "N92000002") {
#     json_text_areacompare <- paste0(
#       "df_json_template$grouped_data_areacompare$", v_source[t],
#       ' = df_temp1 %>% subset( source == "', v_source[t],
#       '") %>%   select(geog_name, statistic, perc) %>% rename(group = "geog_name", category = "statistic")'
#     )
#   } else {
#     json_text_areacompare <- paste0(
#       "df_json_template$grouped_data_areacompare$", v_source[t], "= list()"
#     )
#   }
#   eval(parse(text = json_text_areacompare))
#   
#   json_text_nocompare <- paste0(
#     "df_json_template$grouped_data_nocompare$", v_source[t],
#   ' = df_temp_areaonly %>% subset( source == "', v_source[t],
#   '") %>%   select(geog_name, statistic, perc) %>% rename(geography = "geog_name", category = "statistic")'
#   )
#   
#   eval(parse(text = json_text_nocompare))
# 
# }


df_meta_data <- df_meta_data %>%
  mutate(geog_level = factor(geog_level, levels = c('ni', 'lgd', 'dea', 'sdz', 'dz'))) %>%
           arrange(geog_level)
         
         
if (geog_type_loop != "ni") {
  df_temp2 <- df_meta_data %>%
    filter(geog_level == geog_type_loop)

  assign("v_datasets", unique(df_temp2[["dataset"]]))
  for (d in 1:length(v_datasets)) {
    print(d)
    print(v_datasets[d])
    json_text <- paste0(
      "df_json_template$meta_data$", v_datasets[d],
      " = ",
      "df_temp2 %>% filter(dataset =='", v_datasets[d],
      "') %>%  select(table_code, dataset_url, geog_level, last_updated, email, title, year)"
    )
    eval(parse(text = json_text)) # evaluate the string
  }
} else {
  assign("v_datasets", unique(df_meta_data[["dataset"]]))
  for (d in 1:length(v_datasets)) {
    print("ni meta data")
    print(d)
    print(v_datasets[d])
    json_text <- paste0(
      "df_json_template$meta_data$", v_datasets[d],
      " = ",
      "df_meta_data %>% filter(dataset =='", v_datasets[d],
      "') %>%  select(table_code, dataset_url, geog_level, last_updated, email, title, year) %>% head(1)"
    )
    eval(parse(text = json_text)) # evaluate the string
  }
  
 
}

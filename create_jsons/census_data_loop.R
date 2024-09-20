# Census data loop

df_data_subset <- df_data %>% subset(geocode == geog_code_loop) %>% arrange(desc(geocode))


v_topic <- unique(df_data_subset$topic)
v_topic <- move_population_households(v_topic)


df_data_subset_inc_ni <- df_data %>%
  subset(geocode == geog_code_loop | geocode == "N92000002") %>%
  subset(topic %in% v_topic) %>% arrange(desc(geocode))



for (t in 1:length(v_topic)) {
  # t = 1
  df_category_subset <- df_data_subset %>%
    subset(topic == v_topic[t]) %>%
    select(category)
  df_category_subset <- unique(df_category_subset$category)


  #   print(v_topic[t])
  # v_year_short = df_data_subset %>% subset(topic == v_topic[t] ) %>% select(year)
  # v_year_short = unique(v_year_short$year)
  v_year_short <- unique(c(2011, 2021)) # df_data_subset$year)

  for (y in 1:length(v_year_short)) {
    for (j in 1:length(df_category_subset)) {
      # j = 1
      # y = 1

      json_text <- paste0("df_json_template$data$", v_topic[t], "$perc$`", v_year_short[y], "`$", df_category_subset[j])
      data_value_perc <- df_data_subset %>%
        subset(year == v_year_short[y] & topic == v_topic[t] & category == df_category_subset[j]) %>%
        select(perc) %>%
        pull()


      data_value_perc <- df_data_subset %>%
        subset(year == v_year_short[y] & topic == v_topic[t] & category == df_category_subset[j]) %>%
        select(perc) %>%
        pull()


      if (length(data_value_perc) == 0) {
        data_value_perc <- 100
      }

      r_string <- paste0(json_text, " = ", as.character(data_value_perc))
      # prepare a string with the json item and the value

      eval(parse(text = r_string)) # evaluate the string

      ### if no new chart data needed - the following lines can be removed
      # No compare - note hard-coded year
      # json_text_nocompare <- paste0(
      #   "df_json_template$grouped_data_nocompare$", v_topic[t],
      #   ' = df_data_subset_inc_ni %>% subset( topic == "', v_topic[t],
      #   '" & geocode == geog_code_loop & year == 2021) %>%   select(geography, category, perc) %>% rename(group = geography)'
      # )
      # 
      # eval(parse(text = json_text_nocompare)) # evaluate the string
      # 
      # 
      # # time compare - note hard-coded year
      # json_text_timecompare <- paste0(
      #   "df_json_template$grouped_data_timecompare$", v_topic[t],
      #   ' = df_data_subset_inc_ni %>% subset( topic == "', v_topic[t],
      #   '" & geocode == geog_code_loop ) %>%   select(year, category, perc) %>% rename(group = year)'
      # )
      # 
      # eval(parse(text = json_text_timecompare)) # evaluate the string
      # 
      # 
      # # area compare - only include if not NI
      # if (geog_code_loop != "N92000002") {
      #   # note hard-coded year
      #   json_text_areacompare <- paste0(
      #     "df_json_template$grouped_data_areacompare$", v_topic[t],
      #     ' = df_data_subset_inc_ni %>% subset( topic == "', v_topic[t],
      #     '" & year == 2021) %>%   select(geography, category, perc)%>% rename(group = geography)'
      #   )
      # 
      #   eval(parse(text = json_text_areacompare)) # evaluate the string
      # } else {
      #   json_text_areacompare <- paste0(
      #     "df_json_template$grouped_data_areacompare$", v_topic[t], "= list()"
      #   )
      # 
      #   json_text_areacompare
      #   eval(parse(text = json_text_areacompare))
      # }


      ## for population need to add values, change and ranks
      if (v_topic[t] == "population" & df_category_subset[j] == "all") {
        data_value_count <- df_data_subset %>%
          subset(year == v_year_short[y] & topic == v_topic[t] & category == df_category_subset[j]) %>%
          select(count) %>%
          pull()
        json_text <- paste0("df_json_template$data$", v_topic[t], "$value$`", v_year_short[y], "`$", df_category_subset[j])
        if (length(data_value_count) == 0) {
          data_value_count <- 0
        }
        r_string <- paste0(json_text, " = ", as.character(data_value_count))
        eval(parse(text = r_string))

        data_value_rank <- df_data_subset %>%
          subset(year == v_year_short[y] & topic == v_topic[t] & category == df_category_subset[j]) %>%
          select(value_rank) %>%
          pull()
        json_text <- paste0("df_json_template$data$", v_topic[t], "$value_rank$`", v_year_short[y], "`$", df_category_subset[j])
        if (length(data_value_rank) == 0) {
          data_value_rank <- 0
        }
        r_string <- paste0(json_text, " = ", as.character(data_value_rank))
        eval(parse(text = r_string))


        if (length(df_json_template$data$population$value$`2011`$all) != 0) {
          df_json_template$data$population$value$change$all <- (df_json_template$data$population$value$`2021`$all / df_json_template$data$population$value$`2011`$all - 1) * 100
        }
      }



      ## for households  need to add values, change and ranks
      if (v_topic[t] == "households") {
        data_value_count <-
          df_data_subset %>%
          subset(year == v_year_short[y] & topic == v_topic[t] & category == df_category_subset[j]) %>%
          select(count) %>%
          pull()

        if (length(data_value_count) == 0) {
          data_value_count <- 0
        }
        if (length(data_value_rank) == 0) {
          data_value_rank <- 0
        }


        json_text <- paste0("df_json_template$data$", v_topic[t], "$value$`", v_year_short[y], "`$", df_category_subset[j])
        r_string <- paste0(json_text, " = ", as.character(data_value_count))
        eval(parse(text = r_string))


        if (length(df_json_template$data$households$value$`2011`$all_households) != 0) {
          df_json_template$data$households$value$change$all_households <- ((df_json_template$data$households$value$`2021`$all_households / df_json_template$data$households$value$`2011`$all_households) - 1) * 100
        }
      }
    }
  }
}

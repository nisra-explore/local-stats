# I would like a csv file with a list of datasets (no time limits) that includes the code, date last updated,
# table name, years and geography and any other content that is in the coloured boxes under the table title
# e.g. Broad age band (7 cat), Sex, Type (in MIG01T02) and the R code that you use to create it.  Thanks

library(jsonlite)
library(dplyr)

data_portal <- jsonlite::fromJSON(txt = "https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.ReadCollection")$link$item

time <- unlist(data_portal$role$time)

years <- data_portal$dimension$`TLIST(A1)`$category$index
quarters <- data_portal$dimension$`TLIST(Q1)`$category$index
months <- data_portal$dimension$`TLIST(M1)`$category$index
year_range <- c()

categories <- data_portal$id
cat_column <- c()

for (i in 1:length(years)) {
  
  year_range[i] <-
    if (time[i] == "TLIST(A1)") {
      if (length(years[[i]]) == 1) years[[i]][1] else paste(years[[i]][1], "-", tail(years[[i]], 1))
    } else if (time[i] == "TLIST(Q1)") {
      if (length(quarters[[i]]) == 1) quarters[[i]][1] else paste(quarters[[i]][1], "-", tail(quarters[[i]], 1))
    } else if (time[i] == "TLIST(M1)") {
      if (length(months[[i]]) == 1) months[[i]][1] else paste(months[[i]][1], "-", tail(months[[i]], 1))
    }
  
  cat_column[i] <- paste(categories[[i]], collapse = "; ") %>%
    gsub("TLIST(A1); ", "", ., fixed = TRUE) %>%
    gsub("TLIST(Q1); ", "", ., fixed = TRUE) %>%
    gsub("TLIST(M1); ", "", ., fixed = TRUE) %>%
    gsub("STATISTIC; ", "", ., fixed = TRUE)
  
}

datasets <- data.frame(
  name = data_portal$label,
  code = data_portal$extension$matrix,
  updated = as.Date(substr(data_portal$updated, 1, 10)),
  years = year_range,
  categories = cat_column
)

write.csv(datasets, paste0("All NISRA Data Portal Tables as at ", as.Date(Sys.time()), ".csv"), row.names = FALSE)
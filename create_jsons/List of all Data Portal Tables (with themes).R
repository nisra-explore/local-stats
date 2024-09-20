# I would like a csv file with a list of datasets (no time limits) that includes the code, date last updated,
# table name, years and geography and any other content that is in the coloured boxes under the table title
# e.g. Broad age band (7 cat), Sex, Type (in MIG01T02) and the R code that you use to create it.  Thanks
library(jsonlite)
library(dplyr)

api_key <- "801aaca4bcf0030599c019f4efa8b89032e5e6aa1de4a629a7f7e9a86db7fb8c"

data_portal <- jsonlite::fromJSON(txt = "https://ws-data.nisra.gov.uk/public/api.restful/PxStat.Data.Cube_API.ReadCollection")$link$item

matrices <- data_portal$extension$matrix

time <- unlist(data_portal$role$time)

years <- data_portal$dimension$`TLIST(A1)`$category$index
quarters <- data_portal$dimension$`TLIST(Q1)`$category$index
months <- data_portal$dimension$`TLIST(M1)`$category$index

subject <- c()
product <- c()
year_range <- c()

categories <- data_portal$id
cat_column <- c()

for (i in 1:length(matrices)) {
  
  if (time[i] == "TLIST(A1)") {
    latest_date <- tail(years[[i]], 1)
    year_range[i] <- if (length(years[[i]]) == 1) latest_date else paste(years[[i]][1], "-", latest_date)
  } else if (time[i] == "TLIST(Q1)") {
    latest_date <- tail(quarters[[i]], 1)
    year_range[i] <- if (length(quarters[[i]]) == 1) latest_date else paste(quarters[[i]][1], "-", latest_date)
  } else if (time[i] == "TLIST(M1)") {
    latest_date <- tail(months[[i]], 1)
    year_range[i] <- if (length(months[[i]]) == 1) latest_date else paste(months[[i]][1], "-", latest_date)
  }
  
  cat_column[i] <- paste(categories[[i]], collapse = "; ") %>%
    gsub("TLIST(A1); ", "", ., fixed = TRUE) %>%
    gsub("TLIST(Q1); ", "", ., fixed = TRUE) %>%
    gsub("TLIST(M1); ", "", ., fixed = TRUE) %>%
    gsub("STATISTIC; ", "", ., fixed = TRUE)
  
  fetch_error <- TRUE
  
  while (fetch_error) {
    
    json_data <- jsonlite::fromJSON(txt = paste0("https://ws-data.nisra.gov.uk/public/api.jsonrpc?data=%7B%22jsonrpc%22:%222.0%22,%22method%22:%22PxStat.Data.Cube_API.ReadDataset%22,%22params%22:%7B%22class%22:%22query%22,%22id%22:%5B%22TLIST(A1)%22%5D,%22dimension%22:%7B%22",
                                                 time[i], "%22:%7B%22category%22:%7B%22index%22:%5B%22", gsub(" ", "%20", latest_date, fixed = TRUE),
                                                 "%22%5D%7D%7D%7D,%22extension%22:%7B%22pivot%22:null,%22codes%22:false,%22language%22:%7B%22code%22:%22en%22%7D,%22format%22:%7B%22type%22:%22JSON-stat%22,%22version%22:%222.0%22%7D,%22matrix%22:%22",
                                                 matrices[i], "%22%7D,%22version%22:%222.0%22%7D%7D&apiKey=", api_key))
    
    fetch_error <- "error" %in% names(json_data)
    
    if (fetch_error) print(paste0("Error fetching ", matrices[i], ". Trying again..."))
    
  }
  
  subject[i] <- json_data$result$extension$subject$value
  product[i] <- json_data$result$extension$product$value
  
}


datasets <- data.frame(
  name = data_portal$label,
  subject,
  product,
  code = matrices,
  updated = as.Date(substr(data_portal$updated, 1, 10)),
  years = year_range,
  categories = cat_column
)

write.csv(datasets, file = paste0("All NISRA Data Portal Tables as at ", as.Date(Sys.time()), ".csv"), row.names = FALSE)
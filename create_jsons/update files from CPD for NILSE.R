#### code to create the appropriate CPD light with lat & long

library(tidyverse)
library(sp)


convert_irish_grid_to_latlon <- function(easting, northing) {
  a <- 6377340.189
  b <- 6356034.447
  
  e0 <- 200000
  n0 <- 250000
  
  phi0 <- 53.5 * pi/180
  lambda0 <- -8 * pi/180
  
  n <- (a - b) / (a + b)
  e2 <- (2 * n - n^2)
  n2 <- n / (1 - n^2)
  
  phi1 <- phi0 - (northing - n0) / (a * 1)
  
  M <- (b * (1 - e2)) / (1 - e2 * sin(phi1)^2)^1.5
  mu <- M / (a * (1 - e2))
  
  phi2 <- (phi1 + 
             (3 * n / 2 - 27 * n^3 / 32) * sin(2 * phi1) +
             (21 * n^2 / 16 - 55 * n^4 / 32) * sin(4 * phi1) +
             (151 * n^3 / 96) * sin(6 * phi1) +
             (1097 * n^4 / 512) * sin(8 * phi1))
  
  lambda <- lambda0 + 
    (easting - e0) / (a * 1 * cos(phi1)) - 
    (1 + 2 * n + 1.5 * n^2 + 2 * n^3) * sin(phi1) * cos(phi1) *
    ((easting - e0) / (a * 1 * cos(phi1)))^2 +
    (1.5 * n + 2 * n^2 + 2.625 * n^3) * sin(phi1) * cos(phi1) *
    ((easting - e0) / (a * 1 * cos(phi1)))^4
  
  phi2 * 180 / pi
  lambda * 180 / pi
}


dataLookup<- "T:/General TL/Resources/cpdjul2024/CPDJul2024txt/CPDJul2024txt/"
data = read.csv("T:/General Tl/Resources/cpdjul2024/CPDJul2024csv/CPDJul2024csv/CPD_LIGHT.csv")




# Apply the conversion function to create new columns for latitude and longitude
df_cpd_light = data %>% mutate(latitude = convert_irish_grid_to_latlon(X, Y)[1],
                               longitude = convert_irish_grid_to_latlon(X, Y)[2]) %>%
  rename(postcode = "PC3")


# order by PC5
df_cpd_light <- df_cpd_light[order(df_cpd_light$postcode),]




# write out cpd_light file
write.csv(df_cpd_light, "CPD_LIGHT_JULY_2024.csv",
          row.names = FALSE, quote=FALSE)



full_data = read.csv("T:/General Tl/Resources/cpdjul2024/CPDJul2024csv/CPDJul2024csv/POSTCODES_JUL2024.csv")

cpd_data_for_places = full_data %>% select(PC3, DEA2014) %>%
          filter(DEA2014 != "000000000")


write.csv(cpd_data_for_places, "POSTCODES_FOR_PLACES_JULY_2024.csv",
          row.names = FALSE)

## this file needs to be manually added to the places.csv file in use.

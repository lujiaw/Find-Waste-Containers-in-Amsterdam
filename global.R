library(httr)
library(jsonlite)
library(dplyr)
library(tidyr)
library(shinydashboard)
library(shiny)
library(shinyWidgets)
library(leaflet)

# change it to FALSE if first time
load_data = TRUE

if (load_data) {
  load("data.RData")
} else {
  #import data
  url_base = 'https://api.data.amsterdam.nl/vsd/afvalcontainers/'
  data <- NULL
  # 724 pages
  for (i in 1:724) {
    url = if_else(i == 1, url_base, paste0(url_base,'?page=',i))
    request <- GET(url)
    response <- content(request, as = 'text', encoding = "UTF-8")
    df <- fromJSON(response, flatten = TRUE)$results %>% data.frame()
    data <- rbind(data, df)
    if (i %% 100 == 0) {print(paste0(i,' pages imported'))}
  }
  print(paste0('all pages imported successfully'))
  save(data,file="data.RData")
}

# select useful information
# keep id, district, geo location, type, status, operation date, expire date
container_data <- data %>% select(container_id,container_afvalfractie
                                  ,container_datum_operationeel
                                  ,container_datum_aflopen_garantie
                                  ,container_eigenaar_naam
                                  ,container_wgs84_lat,container_wgs84_lon 
                                  ,container_status, gbd_buurt_naam)
container_data <- container_data %>% rename(id = container_id
                                            , type = container_afvalfractie
                                            , operate_date = container_datum_operationeel
                                            , expire_date = container_datum_aflopen_garantie
                                            , district = container_eigenaar_naam
                                            , lat = container_wgs84_lat
                                            , lon = container_wgs84_lon
                                            , status = container_status
                                            , neighborhood_name = gbd_buurt_naam)
container_data <- container_data %>% mutate(district = substr(district,3,nchar(district))) %>% drop_na(lat,lon,type)

cols.num <- c("lat","lon")
container_data[cols.num] <- sapply(container_data[cols.num],as.numeric)
container_data$type <- as.factor(container_data$type)
containertype <- unique(container_data$type)
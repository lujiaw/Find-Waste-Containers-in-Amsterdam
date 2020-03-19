server <- function(input, output){
  output$manual0 <- renderText({
    paste('<font color=\"#131313\"><font size=4>This App is designed for residents in Amsterdam city to find different types of waste containers.',
          'The data is gathered by <a href=\"https://data.amsterdam.nl/">Amsterdam OIS department</a> and the API of the dataset can be found <a href=\"https://api.data.amsterdam.nl/vsd/afvalcontainers/">here</a>.</font></br>')
  })
  output$manual1 <- renderText({
    paste('<font color=\"#131313\"><font size=4>Have you ever encounter a situation that you have a full bag of empty plastic bottles but not knowing where to dispose them?</br></br>',
          "Have you ever encounter a situation that the only container for cardboard downstairs is full and you don't know what to do with your used amazon boxes?</br></br>",
          "Now you have a solution by simply entering your location and check few filters and a list of applicable waste containers in your neighborhood will show on map and you can choose the nearest ones!</br></br>",
          "You can also checkout the detailed instructions on household waste disposal in your area <a href=\'https://www.amsterdam.nl/en/waste-recycling/household-waste/'>here</a>.</font></br></br>")
  })
  output$guide0 <- renderText({
    paste('Waste Guide')
  })
  filter_react <- eventReactive(input$submit, {
    return(list(
      district = input$citydistrict,
      type = input$containertype,
      postcode = input$postcode
    ))
  }, ignoreNULL = FALSE)
  
  output$waste_map <- renderLeaflet({
    filters = filter_react()
    #filter data
    plot_data <- container_data %>% filter(type %in% filters[["type"]])
    #map default geo location
    # if no postcode is entered, show amsterdam center
    # if postcode is entered, show post code area
    postcode = filters[['postcode']]
    if (postcode=="") {
      map_geo = c(4.8945,52.3667)
    } else {
      postcode_request <- GET(paste0("https://api.data.amsterdam.nl/atlas/search/postcode/?q=",postcode))
      postcode_response <- content(postcode_request, as = 'text', encoding = "UTF-8")
      postcode_df <- fromJSON(postcode_response, flatten = TRUE)$results
      map_geo <- postcode_df$centroid[[1]]
    }
    # Color Brew for different type of container
    getColor <- function(container_data) {
      sapply(container_data$type, function(type) {
        if(type == "Papier") {
          "green"
        } else if(type == "Rest") {
          "orange"
        } else if(type == "Textiel") {
          "red"
        } else if(type == "Plastic") {
          "cadetblue"
        } else if(type == "Glas") {
          "purple"
        } else {
          "blue"
        } })
    }
    #icon for containers
    icons <- makeAwesomeIcon(
      icon = "flag",
      library = 'ion',
      markerColor = getColor(plot_data)
    )
    #pop-up content generator
    content.fun <- function(selected) {
      content <- paste(
        sep = "<br/>",
        paste0("<font size=1.8><font color=green><b>",selected$id,"</b>"),
        paste0("<font size=1>Container Type: ", "<font color=black>", as.character(selected$type)),
        paste0("<b>Neighborhood:</b> ",selected$neighborhood_name),
        paste0("<b>Operation Date:</b> ",as.character(selected$operate_date))
      )}
    leaflet(plot_data) %>% setView(lat = map_geo[2], lng = map_geo[1],zoom=if_else(postcode=="",15,18)) %>%
      addProviderTiles("CartoDB",options = providerTileOptions(opacity = 0.99))%>%
      addAwesomeMarkers(lng = ~ lon,lat = ~ lat,icon=icons,popup = content.fun(plot_data)) %>%
      addAwesomeMarkers(lng = map_geo[1], lat = map_geo[2], icon=icon('home'),popup = "<b>You Are Here!<b>")
      
  })
}

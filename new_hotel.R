# Load necessary libraries
if(!require(shiny)) install.packages("shiny")
if(!require(ggplot2)) install.packages("ggplot2")
if(!require(dplyr)) install.packages("dplyr")
if(!require(plotly)) install.packages("plotly")
if(!require(shinythemes)) install.packages("shinythemes")
if(!require(readr)) install.packages("readr")
if(!require(tidyr)) install.packages("tidyr")
if(!require(stringr)) install.packages("stringr")
if(!require(leaflet)) install.packages("leaflet")
if(!require(sf)) install.packages("sf")
if(!require(shinyWidgets)) install.packages("shinyWidgets")
if(!require(bslib)) install.packages("bslib")
if(!require(highcharter)) install.packages("highcharter")

# Read the data files
listings <- read_csv("Melbourne_Airbnb/listings.csv")
listings_cleaned <- read_csv("Melbourne_Airbnb/listings_cleaned.csv")
neighbourhoods <- st_read("Melbourne_Airbnb/neighbourhoods.geojson")

# Combine the two datasets using the host_id from listings_cleaned and id from listings
combined_listings <- listings_cleaned %>%
  left_join(listings %>% select(id, listing_url), by = c("host_id" = "id"))

# Check for NA values in listing_url
if (any(is.na(combined_listings$listing_url))) {
  warning("Some listing URLs are NA. Check the join operation.")
}

# Define choices for visualization
neighbourhood_choices <- unique(combined_listings$neighbourhood_cleansed)

##################
# USER INTERFACE #
##################
ui <- page_navbar(
  title = "Melbourne Airbnb Listings",
  theme = bs_theme(
    bootswatch = "cerulean",
    navbar_bg = "#d3d3d3"
  ),
  
  nav_panel("Overview",
            fluidPage(
              actionLink("overview_title", 
                         value_box(
                           title = "Overview of Melbourne Airbnb Listings",
                           value = "",
                           theme = "bg-gradient-cyan-green"
                         )),
              hr(),
              h5(strong("Select Neighborhood to explore listings on the map."),
                 style = "font-size:16px;"),
              
              # Sidebar for neighborhood selection
              sidebarLayout(
                sidebarPanel(
                  selectInput("neighbourhood", "Choose Neighborhood:",
                              choices = neighbourhood_choices)
                ),
                mainPanel(
                  leafletOutput("listings_map", height = "600px")
                )
              ),
              hr(),
              h5('Data Source: Melbourne Airbnb', 
                 style = "font-size:12px;")
            )
  ),
  
  nav_panel("Details",
            fluidPage(
              actionLink("details_title", 
                         value_box(
                           title = "Details of Selected Neighborhood",
                           value = "",
                           theme = "bg-gradient-teal-blue"
                         )),
              hr(),
              h5(strong("Select a neighborhood to see detailed information."),
                 style = "font-size:16px;"),
              
              # Sidebar for neighborhood selection
              sidebarLayout(
                sidebarPanel(
                  selectInput("detail_neighbourhood", "Choose Neighborhood:",
                              choices = neighbourhood_choices)
                ),
                mainPanel(
                  highchartOutput("neighbourhood_details_chart", height = "600px")
                )
              ),
              hr(),
              h5('Data Source: Melbourne Airbnb',
                 style = "font-size:12px;")
            )
  )
)

################
# SHINY SERVER #
################
server <- function(input, output) {
  
  ########################
  # Overview Tab - Map #
  ########################
  output$listings_map <- renderLeaflet({
    filtered_data <- combined_listings %>%
      filter(neighbourhood_cleansed == input$neighbourhood)
    
    # Create a leaflet map
    leaflet() %>%
      addTiles() %>%
      setView(lng = mean(filtered_data$longitude), lat = mean(filtered_data$latitude), zoom = 12) %>%
      addCircleMarkers(
        data = filtered_data,
        lat = ~latitude, lng = ~longitude,
        radius = ~sqrt(price) / 10,
        color = "blue",
        popup = ~paste(
          "Price: $", price, 
          "<br>Room Type: ", room_type, 
          "<br>Accommodates: ", accommodates,
          "<br>Bathrooms: ", bathrooms_text,
          "<br>Listing URL: ", listing_url
        )
      )
  })
  
  ###############################
  # Details Tab - Highchart Chart #
  ###############################
  output$neighbourhood_details_chart <- renderHighchart({
    filtered_data <- combined_listings %>%
      filter(neighbourhood_cleansed == input$detail_neighbourhood)
    
    # Create a bar chart for price distribution
    highchart() %>%
      hc_chart(type = "column") %>%
      hc_title(text = paste("Price Distribution in", input$detail_neighbourhood)) %>%
      hc_xAxis(categories = filtered_data$room_type) %>%
      hc_add_series(name = "Price", data = filtered_data$price, color = "#3498DB") %>%
      hc_plotOptions(column = list(
        dataLabels = list(enabled = TRUE)
      )) %>%
      hc_legend(enabled = FALSE)
  })
  
  ##########################
  # Observe link click events
  ##########################
  observeEvent(input$overview_title, {
    updateSelectInput(session, "neighbourhood", selected = neighbourhood_choices[1])
  })
  
  observeEvent(input$details_title, {
    updateSelectInput(session, "detail_neighbourhood", selected = neighbourhood_choices[1])
  })
}

#############
# SHINY EXECUTION #
#############
shinyApp(ui, server)
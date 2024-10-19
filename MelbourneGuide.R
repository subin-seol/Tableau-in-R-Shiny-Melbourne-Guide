library(shiny)
library(shinythemes)
library(shinyjs)

source('tableau-in-shiny-v1.2.R')

overview_tab <- tabPanel(
  title="Overview",
  h2("Welcome to Melbourne City Guide"),
  p("Here you will find information you need to know before your visit to Melbourne City!")
)

transportation_tab <- tabPanel(
  title="Transportation"
)

restaurant_tab <- tabPanel(
  title="Restaurants"
)

attraction_tab <- tabPanel(
  title="Attractions",
  h2("Attractions in Melbourne"),
  tableauPublicViz(
    id="AttractionMap",
    url="https://public.tableau.com/views/Attraction_17292557361430/Sheet1?:language=en-GB&publish=yes&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link",
    height="500px"
  )
  
)

accomodation_tab <- tabPanel(
  title="Accomodation"
)

ui <- navbarPage(
  theme = shinytheme("flatly"), # other themes: cerulean, cosmo, lumen, flatly
  header=setUpTableauInShiny(),
  title = "Melbourne City Guide",
  
  overview_tab,
  transportation_tab,
  restaurant_tab,
  attraction_tab,
  accomodation_tab
  
)

# Server logic
server <- function(input, output, session) {
  # Placeholder for future visualizations and map integrations
}

# Run the application
shinyApp(ui, server, options=list(launch.browser=TRUE))

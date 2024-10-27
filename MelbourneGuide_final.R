# Load required libraries with individual install commands
if (!require(shiny)) install.packages("shiny"); library(shiny)
if (!require(shinythemes)) install.packages("shinythemes"); library(shinythemes)
if (!require(shinyjs)) install.packages("shinyjs"); library(shinyjs)
if (!require(readr)) install.packages("readr"); library(readr)
if (!require(gt)) install.packages("gt"); library(gt)
if (!require(dplyr)) install.packages("dplyr"); library(dplyr)
if (!require(tidyr)) install.packages("tidyr"); library(tidyr)
if (!require(bslib)) install.packages("bslib"); library(bslib)
if (!require(highcharter)) install.packages("highcharter"); library(highcharter)
if (!require(fontawesome)) install.packages("fontawesome"); library(fontawesome)
if (!require(shinyWidgets)) install.packages("shinyWidgets"); library(shinyWidgets)
if (!require(jsonlite)) install.packages("jsonlite"); library(jsonlite)
if (!require(leaflet)) install.packages("leaflet"); library(leaflet)
if (!require(geojsonio)) install.packages("geojsonio"); library(geojsonio)
if (!require(stringr)) install.packages("stringr"); library(stringr)
if (!require(sf)) install.packages("sf"); library(sf)

source('tableau-in-shiny-v1.2.R')

##################
#      DATA      #
##################

data <- read_csv("data/melbourne_weather.csv", show_col_types = FALSE)

melbourne_weather <- data.frame(
  Month = c("Dec", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov"),
  MaximumTemp = c(24.2, 25.9, 25.8, 23.9, 20.3, 16.7, 14.0, 13.4, 15.0, 20.5, 22.5, 24.0),
  MinimumTemp = c(12.9, 14.3, 14.6, 13.2, 10.8, 8.6, 6.9, 6.0, 6.7, 10.3, 13.1, 15.3)
)
################## Hotel Data load ##################

airbnb_data <- read.csv("data/top-rated_rentals.csv")
hotel_data <- read.csv("data/hotel.csv")


################## Transportation Data load ##################
tram_data <- read_csv("data/tram_stop.csv")
train_data <- read_csv("data/train_station.csv")

# Touristic Stations
shuttle_data <- read_csv("data/visitor_shuttle.csv")
skybus_data <- read_csv("data/skybus_stop.csv")
citytram_data <- read_csv("data/city_tram.csv")

# Overview of Tram 
tram_length_data <- read_csv("data/tram_length.csv")

# Tourist data
tourist_data <- read_csv("data/australia_tourist.csv")

# Convert the data from wide to long format
tourist_data_long <- tourist_data %>%
  pivot_longer(cols = -Year, names_to = "Country", values_to = "Value")

# Function to get data for a specific year
get_data_for_year <- function(year) {
  tourist_data_long <- tourist_data %>%
    filter(Year == year) %>%  # Year 필터 적용
    pivot_longer(cols = -Year, names_to = "Country", values_to = "Value") %>%  # 열 변환
    arrange(desc(Value)) %>%  # Value 값으로 내림차순 정렬
    head(10)  # 상위 10개 국가만 반환
  return(tourist_data_long)
}

# Prepare list of data for each year
years <- sort(unique(tourist_data_long$Year))
yearly_data <- lapply(years, get_data_for_year)

# GeoJSON file (Melbourne)
melbourne_geojson <- st_read("data/melbourne_city.geojson")

# Filter tram stops and train stations
state_choiceVec <- c("All Stops", "Tram Stops", "Train Stations")

# Touristic transportation choices
touristic_choiceVec <- c("All Touristic Stops", "Visitor Shuttle", "SkyBus", "City Circle Tram")

# Tram route numbers
tram_numbers <- sort(unique(tram_data$routeussp))
train_lines <- sort(unique(train_data$routeussp))


################## Restaurant Data load ##################
restaurant_data1 <- read_csv("data/new_restaurant_data.csv")
restaurant_data2 <- read_csv("data/melbourne_restaurant_reviews.csv")
restaurant_data <- left_join(restaurant_data1, restaurant_data2, by = c("Trading name" = "name"))

##################
# USER INTERFACE #
##################

scrollToTopJS <- "
shinyjs.scrollToTop = function() {
  window.scrollTo(0, 0);
}
"
###### Home tab UI ######
home_tab <- nav_panel(
  title = "Home",
  
  tags$div(
    style = "
    background-image: url('https://upload.wikimedia.org/wikipedia/commons/7/74/Melbourne_skyline_sor.jpg');
    background-attachment: fixed;
    background-size: cover;
    background-position: center;
    height: 100vh;
    color: white;
    text-align: center;
    position: relative;
  ",
    
    tags$div(
      style = "
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        font-family: 'Avenir', sans-serif;
      ",
      
      # Main Welcome Text
      h1("Welcome to Melbourne!", style = "font-size: 4em; font-weight: bold; color: white;"),
      
      # Sub-Text
      p("Discover the best places to visit and things to do in the city.", style = "font-size: 1.5em; color: white;")
    )
  ),
  
  fluidRow(
    column(2), 
    column(8, align = "left", 
           h2("Welcome"),
           HTML("
             <p><strong>Melbourne is Australia's mecca for all things trendy and tasty. With exquisite dining, exhilarating sport, and abundant art experiences, there are plenty of brilliant things to do in Melbourne.</strong></p>
             <p>A perfect blend of rich cultural history and new age trends is waiting for you in Melbourne. As the sun goes down, the city comes to life with a vibrant dining scene as well as events and exhibitions. Explore its bustling laneways, trendy neighbourhoods, and sophisticated foodie scene to get a taste of what Melbourne is all about.</p>
             <h3>Getting to Melbourne</h3>
             <p>Getting to Melbourne is easy with flights arriving directly at two airports:</p>
             <ul>
               <li>Melbourne Airport at Tullamarine (MEL) is 22km (14mi) from the city and services international and domestic arrivals.</li>
               <li>Avalon Airport (AVV) is 55km (34mi) from the city and services international and domestic flights.</li>
             </ul>
             <p>Hire cars, taxis, rideshares, and a shuttle service are available from both airports. Getting around is just as easy as finding a great cup of coffee in Melbourne. The city offers clean, reliable, and affordable public transport services. There is even a free City Circle tram line with historical commentary.</p>
             <h3>When to visit:</h3>
             <p>Despite having four distinct seasons, Melbourne's weather is known for being a bit unpredictable. Summers are generally warm and winters cold, but just ask a local and they’ll tell you that it’s not uncommon to experience all four seasons in a single day. So whenever you decide to visit, be sure to pack layers and carry an umbrella in your day bag.</p>
             <ul>
               <li><strong>High season:</strong> Spring and summer (November to February)</li>
               <li><strong>Low season:</strong> Winter (June to August)</li>
               <li><strong>Don’t miss:</strong> Melbourne’s world-class festivals and events.</li>
             </ul>
           ")
    ),
    column(2)
  ),
  
  ##### weather chart ####
  fluidRow(
    tags$head(
      tags$script(src = "https://public.tableau.com/javascripts/api/tableau-2.8.0.min.js"),
      tags$script(HTML("
      var tableauViz;
      function initTableau() {
        var containerDiv = document.getElementById('tableauViz');
        var url = 'https://public.tableau.com/views/Book2_17299442399530/Dashboard1?:language=en-US&publish=yes&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link';
  
        var options = {
          hideTabs: true,
          onFirstInteractive: function () {
            console.log('Tableau Viz has loaded.');
          }
        };
  
        tableauViz = new tableau.Viz(containerDiv, url, options);
      }

      Shiny.addCustomMessageHandler('updateMonthFilter', function(month) {
        if (tableauViz) {
          tableauViz.getWorkbook().getActiveSheet().applyFilterAsync(
            'Month Character',
            month, 
            tableau.FilterUpdateType.REPLACE
          ).then(function() {
            console.log('Filter applied: ' + month);
          }).catch(function(err) {
            console.error('Error applying filter:', err);
          });
        }
      });
    "))
    ),
    tags$body(onload = "initTableau()"),  
    
    fluidRow(
      column(8, offset = 2,
             titlePanel("Melbourne Monthly Temperature Range"),
      )
    ),
    
    # Dumbbell 차트 영역
    fluidRow(
      column(8, offset = 2,
             div(class = "chart-container",
                 highchartOutput("dumbbell_chart", width = "900px", height = "400px")  # 차트
             )
      )
    ),
    
    # Tableau 시각화 포함할 div
    fluidRow(
      column(8, offset = 2,
             div(id = "tableauViz", style = "width: 100%; height: 600px;")
      )
    )
  ),
  br(),
  
  ##### Bar race chart #####
  fluidRow(
    column(8, offset =2, 
           div(class = "chart-container",
               highchartOutput("bar_race_chart", width = "900px", height = "600px"),  # 차트
               actionButton("play_pause_button", label = icon("play"), class = "btn-lg")  # 버튼에 아이콘 추가
           )
    )
  ),
  
  br(),
  
  # 슬라이더 추가
  fluidRow(
    column(8, offset = 2,
           sliderInput("year_slider", "Select Year:",
                       min = min(years), max = max(years), 
                       value = min(years), step = 1),
    )
  ),
  
  br(), br(),
  
  fluidRow(
    column(3,
           actionButton("btn1", "Transportation", class = "btn-primary", style = "width: 100%;")
    ),
    column(3,
           actionButton("btn2", "Restaurants", class = "btn-primary", style = "width: 100%;")
    ),
    column(3,
           actionButton("btn3", "Attractions", class = "btn-primary", style = "width: 100%;")
    ),
    column(3,
           actionButton("btn4", "Accomodation", class = "btn-primary", style = "width: 100%;")
    )
  ),
  
  br(), br()
)

###### Transportation tab UI ######
transportation_tab <- nav_panel(
  title="Transportation",
  
  # 제목과 스타일링 추가
  h2("Transportation in Melbourne", style = "text-align: center; font-size: 2.5em; font-weight: bold; margin-bottom: 20px;"),
  
  # 소개 문구 추가
  p(
    "Explore Melbourne's Transport System. Convenient, Efficient, Accessible!",
    style = "text-align: center; font-size: 1.5em; font-weight: bold; color: #555; margin-bottom: 15px;"
  ),
  
  p(
    "Melbourne boasts the world’s largest tram network, with over 250 km of tracks.",
    style = "text-align: center; font-size: 1.3em; color: #777; line-height: 1.7; margin-bottom: 30px;"
  ),
  
  fluidPage(
    
    # 추가하려는 Tram System Length 차트
    h3("Tram System Length by City", style = "text-align: center;"),
    
    # 여러 개의 국가 선택이 가능한 드롭다운 메뉴
    selectizeInput("country_filter", "Select Country", 
                   choices = c("All", unique(tram_length_data$country)),
                   selected = "All", multiple = TRUE,
                   options = list(plugins = list("remove_button"))),  # 선택 항목 제거 버튼 추가
    
    highchartOutput("tram_length_bar_chart", height = "600px"),  # 차트 추가
    hr(),
    
    p(
      "Flinders Street Station", br(),
      "Opened in 1854, this station holds over 160 years of history.", br(),
      "The building is designed in Baroque style, with its distinctive green dome and clock tower serving as Melbourne’s most recognizable landmarks.", br(),
      "Flinders Street Station is a vital part of Melbourne’s transport system and cultural heritage.", br(),
      style = "text-align: center; font-size: 1.3em; color: #777; line-height: 1.7; margin-bottom: 30px;"
    ),
    
    p(
      "Melbourne Central Station", br(), 
      "Melbourne Central’s Coop's Shot Tower was originally used to manufacture lead shot in the 19th century, representing Melbourne’s industrial past.", br(),
      "The clock tower at Melbourne Central chimes every hour, accompanied by an animated show featuring mechanical figurines.", br(),
      "The building is designed in Baroque style, with its distinctive green dome and clock tower serving as Melbourne’s most recognizable landmarks.", br(),
      style = "text-align: center; font-size: 1.3em; color: #777; line-height: 1.7; margin-bottom: 30px;"
    ),
    
    # Title for Tram and Train Stations
    actionLink("tram_title", 
               value_box(
                 title = NULL,
                 value = "Overview of Melbourne Tram and Train Stations",
                 theme = "bg-gradient-cyan-green",
                 showcase = bsicons::bs_icon("map"),
                 showcase_layout = "top right"
               )),
    hr(),
    h5(strong("Select Stop Type, Map View, and Zoom to explore stations on the map."),
       style = "font-size:16px;"),
    
    # Value boxes for Tram, Train, and Bus Stops
    layout_columns(
      actionLink("tram_link",
                 value_box(
                   title = "Total Tram Stops",
                   value = nrow(tram_data),
                   theme = "bg-gradient-cyan-green",
                   showcase = bsicons::bs_icon("train-lightrail-front"),
                   showcase_layout = "top right"
                 )),
      actionLink("train_link",
                 value_box(
                   title = "Total Train Stations",
                   value = nrow(train_data),
                   theme = "bg-gradient-teal-blue",
                   showcase = bsicons::bs_icon("train-front"),
                   showcase_layout = "top right"
                 ))
    ),
    hr(),
    
    # Filter options and map for Transportation
    sidebarLayout(
      sidebarPanel(
        radioButtons("stop_type", 
                     label = tags$p(fa("filter", fill = "#244f76"), 
                                    "Select Stop Type"),
                     choices = list("All Stops" = "All Stops", 
                                    "Tram Stops" = "Tram Stops", 
                                    "Train Stations" = "Train Stations"),
                     selected = "All Stops"),
        # Conditional inputs for tram, train
        conditionalPanel(
          condition = "input.stop_type == 'Tram Stops'",
          pickerInput(
            inputId = "tram_number",
            label = "Select Tram Number:",
            choices = tram_numbers,
            selected = tram_numbers,
            multiple = TRUE,
            options = list(`actions-box` = TRUE)
          )
        ),
        conditionalPanel(
          condition = "input.stop_type == 'Train Stations'",
          pickerInput(
            inputId = "train_lines",
            label = "Select Train Line:",
            choices = train_lines,
            selected = train_lines,
            multiple = TRUE,
            options = list(`actions-box` = TRUE)
          )
        ),
      ),
      mainPanel(
        leafletOutput("station_map", height = "600px")
      )
    ),
    hr(),
    
    p(
      "The Melbourne City Tour Bus", br(), 
      "It offers a convenient sightseeing option, making it the best way to explore various attractions across Melbourne in one go.", br(),
      "With the Hop-On Hop-Off service, you can enjoy flexible touring and listen to audio guides that provide information about each landmark, allowing you to fully experience the charm of Melbourne.", br(),
      style = "text-align: center; font-size: 1.3em; color: #777; line-height: 1.7; margin-bottom: 30px;"
    ),
    
    p(
      "Route 35 Tram", br(), 
      "This free tourist tram circles the city, offering the most convenient and attractive way to visit Melbourne’s major attractions. ", br(),
      "WWith its vintage tramcars, audio commentary, and flexible hop-on hop-off service, anyone visiting Melbourne can easily experience the city’s rich history and culture through this tram ride.", br(),
      style = "text-align: center; font-size: 1.3em; color: #777; line-height: 1.7; margin-bottom: 30px;"
    ),
    
    # Touristic Transportation Section
    actionLink("touristic_title", 
               value_box(
                 title = NULL,
                 value = "Overview of Touristic Transportation",
                 theme = "bg-gradient-purple-cyan",
                 showcase = bsicons::bs_icon("person-arms-up"),
                 showcase_layout = "top right"
               )),
    hr(),
    h5(strong("Select Stop Type and Zoom to explore touristic transportation on the map."),
       style = "font-size:16px;"),
    
    # Value boxes for touristic stops
    layout_columns(
      actionLink("visitor_shuttle_link",
                 value_box(
                   title = "Total Visitor Shuttle Stops",
                   value = nrow(shuttle_data),
                   theme = "bg-gradient-purple-blue",
                   showcase = bsicons::bs_icon("bus-front"),
                   showcase_layout = "top right"
                 )),
      actionLink("skybus_link",
                 value_box(
                   title = "Total SkyBus Stops",
                   value = nrow(skybus_data),
                   theme = "bg-gradient-purple-pink",
                   showcase = bsicons::bs_icon("airplane"),
                   showcase_layout = "top right"
                 )),
      actionLink("citytram_link",
                 value_box(
                   title = "Total City Circle Tram Stops",
                   value = nrow(citytram_data),
                   theme = "bg-gradient-cyan-pink",
                   showcase = bsicons::bs_icon("train-lightrail-front"),
                   showcase_layout = "top right"
                 ))
    ),
    hr(),
    
    # Map for touristic transportation
    sidebarLayout(
      position = "right",
      sidebarPanel(
        radioButtons("touristic_stop_type", 
                     label = tags$p(fa("filter", fill = "#244f76"), 
                                    "Select Touristic Stop Type"),
                     choices = touristic_choiceVec,
                     selected = "All Touristic Stops")
      ),
      mainPanel(
        leafletOutput("touristic_map", height = "600px")
      )
    ),
    hr(),
    
    h5('Data Source: Public Transport Victoria (PTV)', 
       style = "font-size:12px;")
  ),
)

###### Restaurant tab UI ######  
restaurant_tab <- nav_panel(
  title = "Restaurants",
  
  # 제목과 스타일링 추가
  h2("Restaurants in Melbourne", style = "text-align: center; font-size: 2.5em; font-weight: bold; margin-bottom: 20px;"),
  
  # 소개 문구 추가
  p(
    "Welcome to Melbourne's culinary paradise, where a vibrant mix of cultures meets on the dining table!",
    style = "text-align: center; font-size: 1.5em; font-weight: bold; color: #555; margin-bottom: 15px;"
  ),
  
  p(
    "As one of the world’s most diverse cities, Melbourne offers an endless variety of international cuisines. ",
    "Here, you’ll experience flavors from every corner of the globe, reflecting the city’s rich immigrant history.",
    "Melbourne is truly a 'city of gastronomy', home to world-renowned food festivals and some of the finest restaurants.",
    "No matter what you’re craving, this city is sure to satisfy any taste bud.",
    style = "text-align: justify; font-size: 1.3em; color: #777; line-height: 1.7; margin-bottom: 30px;"
  ),
  
  p(
    "Ready to embark on a food journey? Explore the map below to discover the best places to eat in Melbourne!",
    style = "text-align: center; font-size: 1.4em; font-weight: bold; color: #555; margin-bottom: 30px;"
  ),
  
  # 지도 섹션의 가운데 정렬 및 고정된 크기 설정
  div(
    style = "text-align: center; width: 100%; margin-bottom: 50px;",  # 지도의 가운데 정렬
    div(
      style = "display: inline-block; width: 800px; height: 600px; overflow: hidden;",
      tableauPublicViz(
        id = "RestaurantMap",
        url = "https://public.tableau.com/views/RestaurantMap_17295190169160/Sheet1?:language=ko-KR&publish=yes&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link"
      )
    )
  ),
  
  # 클릭된 레스토랑 정보 테이블 섹션 (위쪽에 타이틀 추가)
  div(
    h3("Selected Restaurant Information", style = "text-align: center; font-weight: bold; margin-bottom: 20px;"),
    gt_output("restaurant_info")
  ),
  
  # 제목 및 설명 추가 (레스토랑 정보 위에)
  h3("Top 5 Ranked Restaurants in Melbourne", style = "text-align: center; font-weight: bold; margin-top: 20px;"),
  p("These restaurants have received 5-star ratings from TripAdvisor.", style = "text-align: center; font-size: 1.1em; color: #888; margin-bottom: 40px;"),
  
  # 지도가 끝난 후 간격 추가
  br(), br(), br(), br(),
  
  # 레스토랑 정보 섹션 (지도 아래에 추가)
  div(
    style = "padding-top: 50px;",  # 지도와 레스토랑 사이에 간격 추가
    fluidRow(
      # 레스토랑 1
      column(4, align = "center",
             img(src = "ginger_olive.jpg", height = "150px", style = "margin-bottom: 15px;"),
             h4("Ginger Olive Restaurant and Grill"),
             p("U 2 38 Manchester Lane, Melbourne, Victoria 3000"),
             a("Website Link", href = "https://gingerolive.com.au/", target = "_blank")
      ),
      # 레스토랑 2
      column(4, align = "center",
             img(src = "hardware_club.jpg", height = "150px", style = "margin-bottom: 15px;"),
             h4("The Hardware Club"),
             p("43 Hardware Lane, Melbourne, Victoria 3000"),
             a("Website Link", href = "https://www.thehardwareclub.com/", target = "_blank")
      ),
      # 레스토랑 3
      column(4,              align = "center",
             img(src = "ten_square.jpg", height = "150px", style = "margin-bottom: 15px;"),
             h4("Ten Square Café"),
             p("120 Hardware St, Melbourne, Victoria 3000"),
             a("Website Link", href = "https://www.tensquarecafe.com.au/", target = "_blank")
      )
    ),
    
    fluidRow(
      # 레스토랑 4
      column(6, align = "center",
             img(src = "caterinas.jpg", height = "150px", style = "margin-bottom: 15px;"),
             h4("Caterina's Cucina E Bar"),
             p("221 Queen St, Melbourne, Victoria 3000"),
             a("Website Link", href = "https://www.caterinas.com.au/", target = "_blank")
      ),
      # 레스토랑 5
      column(6, align = "center",
             img(src = "tokui_sushi.jpg", height = "150px", style = "margin-bottom: 15px;"),
             h4("Tokui Sushi"),
             p("260 Lonsdale St, Melbourne, Victoria 3000"),
             a("Google Link", href = "https://g.co/kgs/fWawkKC", target = "_blank")
      )
    )
  )
)

###### Attraction tab UI ######  
attraction_tab <- nav_panel(
  title = "Attractions",
  h2("Explore Melbourne's Top Attractions", 
     style = "text-align: center; margin-bottom: 20px;"),
  
  p("Discover must-visit places across the city with our interactive map and ranking of top attractions.",
    style = "font-size: 1.2em; text-align: center; margin-bottom: 30px;"),
  
  div(
    style = "padding-bottom: 50px;",  # Add space between map and title
    tableauPublicViz(
      id = "AttractionMap",
      url = "https://public.tableau.com/views/AttractionMap/Sheet1?:language=en-GB&publish=yes&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link",
      width = "100%", 
      height = "600px"
    )
  ),
  
  h3("Top 10 Most Popular Attractions in Melbourne",
     style = "text-align: center; margin-top: 30px; margin-bottom: 20px;"),
  
  div(
    style = "padding-bottom: 50px;",  # Add bottom padding for better spacing
    tableauPublicViz(
      id = "TopAttractionChart",
      url = "https://public.tableau.com/shared/CR99P4C96?:display_count=n&:origin=viz_share_link",
      width = "100%", 
      height = "700px"
    )
  ),
  
  tags$div(
    style = "text-align: center; margin-top: 50px; margin-bottom: 50px;",
    h3("Tours"),
    
    # Container for tour cards
    tags$div(
      style = "display: flex; justify-content: center; gap: 20px; max-width: 1200px; margin: auto;",
      
      # First Tour Card
      tags$div(
        style = "width: 30%; text-align: center;",
        tags$img(src = "https://img1.wsimg.com/isteam/ip/58b25b38-2727-4821-bcc1-aa45e268de8c/melbourne%20path%20jpg.jpg/:/rs=w:365,h:365,cg:true,m/cr=w:365,h:365", style = "width: 100%; height: auto;"),
        tags$h4("Melbourne / Narrm"),
        tags$p("A perfect introduction to the city. This tour will teach you a lot about Melbourne, for visitors and locals alike..."),
        tags$button("BOOK NOW", onclick = "window.open('https://www.trybooking.com/events/landing/1191875?');", style = "padding: 10px; font-size: 16px;")
      ),
      
      # Second Tour Card
      tags$div(
        style = "width: 30%; text-align: center;",
        tags$img(src = "https://img1.wsimg.com/isteam/ip/58b25b38-2727-4821-bcc1-aa45e268de8c/docklandspath.png/:/cr=t:0%25,l:7.05%25,w:85.9%25,h:99.99%25/rs=w:365,h:365,cg:true,m", style = "width: 100%; height: auto;"),
        tags$h4("Docklands"),
        tags$p("A neighbourhood of luck and squandered opportunities. This tour will showcase some of the surprisingly..."),
        tags$button("COMING SOON", disabled = TRUE, style = "padding: 10px; font-size: 16px;")
      ),
      
      # Third Tour Card
      tags$div(
        style = "width: 30%; text-align: center;",
        tags$img(src = "https://img1.wsimg.com/isteam/ip/58b25b38-2727-4821-bcc1-aa45e268de8c/20210210_164725.png/:/rs=w:365,h:365,cg:true,m/cr=w:365,h:365", style = "width: 100%; height: auto;"),
        tags$h4("Brunswick / Bulleke-Bek"),
        tags$p("Tour the cultural inner-city neighbourhood. This tour will teach you about colonization, communist gatherings..."),
        tags$button("COMING SOON", disabled = TRUE, style = "padding: 10px; font-size: 16px;")
      )
    )
  )
)

###### Accomodation tab UI ######  
accomodation_tab <- tabPanel(
  title = "Accommodation",
  div(
    style = "text-align: center; width: 80%; margin: auto;",
    h2("Welcome to Your Melbourne Stay Guide", style = "text-align: center; margin-bottom: 30px;"),
  
    # Brief introduction to the accommodation section
    p("Explore Melbourne’s best stays! Whether you’re looking for a cozy Airbnb or a luxurious hotel experience, we’ve gathered the top recommendations across the city’s most vibrant neighborhoods. 
      Use our interactive map and data insights to find your ideal place to stay, discover nearby attractions, and compare amenities to make the most of your visit to Melbourne.",
      style = "text-align: center; font-size: 1.2em; margin-bottom: 40px;"),
    
  ),
  
  tags$div(
    style = "text-align: center; width: 100%; margin-bottom: 50px;",
    # Airbnb Section
    h3("Airbnb Stays in Melbourne", style = "text-align: center; margin-bottom: 20px;"),
  
    div(
      style = "display: inline-block; width: 80%; height: 600px; overflow: hidden; margin-bottom: 30px;",
      h4("Discover Melbourne’s Best Airbnb Stays", style = "margin-bottom: 15px;"),
      p("Use the map below to filter listings by neighborhood, accommodates, price, room type, and ratings. 
        These options help you narrow down your preferences, making it easy to find the perfect spot to suit your style and needs.",
        style = "font-size: 1.2em; margin-bottom: 20px;"),
      tableauPublicViz(
        id = "AirbnbMap",
        url = "https://public.tableau.com/shared/8D8HT7S9C?:display_count=n&:origin=viz_share_link"
      )
    ),
    
    div(
      style = "width: 85%; margin: auto;",
      # Title for Top Airbnb Picks
      h4("Our Picks: Top 4 Airbnb Stays in Melbourne", style = "text-align: center; margin-bottom: 20px;"),
      p("Looking for a unique stay experience? These top 4 Airbnb listings offer the highest ratings for cleanliness, location, and amenities, providing comfort and convenience for any traveler. 
        Perfect for those who value style and ease, each listing includes highlights and exclusive features.",
        style = "font-size: 1.2em;text-align: center; margin-bottom: 30px;"),
      
    ),

    # Create a fluid row for the cards
    
    fluidRow(
      lapply(1:nrow(airbnb_data), function(i) {
        column(3,  # Each card takes up 3 columns (4 cards in a row)
              div(class = "card",
                  style = "margin: 1px; padding: 1px; height: 500px; display: flex; flex-direction: column; border: none;",
                  h4(airbnb_data$title[i], style = "text-align: center; margin-bottom: 10px;"),
                  img(src = airbnb_data$img_url[i], style = "width: 100%; height: 195px; object-fit: cover; border-radius: 5px;margin-top: 5px;"),
                  
                  h5(airbnb_data$name[i],style = "text-align: center; margin-top: 5px;"),
                  p(paste("Score:", airbnb_data$score[i])),
                  div(style = "flex-grow: 1; overflow: hidden; text-overflow: ellipsis; display: -webkit-box; -webkit-box-orient: vertical; -webkit-line-clamp: 4;", 
                      airbnb_data$summary[i]),  # Allow summary to grow and fill space
                  actionButton(paste0("book_now_", i), "Book Now", 
                                onclick = sprintf("window.open('%s', '_blank')", airbnb_data$book_url[i]), 
                                style = "margin-top: 20px;")  # Add Book Now button
                  
              )
        )
      })
    ),
    
    p("Ready to choose? Compare prices, amenities, and perks to find your perfect Melbourne Airbnb.", 
      style = "font-size: 1.2em;text-align: center; margin-top: 20px;"),
    p("Data Source: Airbnb", style = "text-align: center; font-size: 0.9em; margin-top: 10px;")
  ),

  # Hotel Section
  tags$div(
    style = "text-align: center; width: 100%; margin-bottom: 50px;",  
    h3("Hotels in Melbourne", style = "text-align: center; margin-bottom: 20px;"),
    
    # Vertical layout for the Tableau visualizations and hotel info
    div(
      style = "display: flex; flex-direction: column; align-items: center; gap: 20px; margin-top: 20px;",
      
      
      div(
        style = "width: 100%; max-width: 1000px; height: 600px; overflow: hidden;",
        h4("Explore Melbourne’s Hotel Map for Every Traveler’s Needs", style = "margin-bottom: 15px;"),
        p("Melbourne has a range of hotels to suit all preferences and budgets. From luxurious five-star stays to budget-friendly finds, use our interactive map to explore each hotel by class, location, and rating.",
        style = "font-size: 1.2em; text-align: center; margin-bottom: 20px;"),
      
        tags$div(
          style = "width: 80%; height: 100%;",
          tableauPublicViz("tableau_viz", "https://public.tableau.com/views/Airbnb_17295563103790/HotelsinMelbourne?:language=en-US&publish=yes&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link")
        )
      ),
      
      # Hotel information section
      div(
        id = "hotelInfo",
        style = "width: 100%; max-width: 1000px; height: 400px; overflow-y: auto;",
        tags$div(
          style = "height: 100%;",
          h4("Compare Average Ratings and Amenities Across Melbourne Hotels", style = "margin-bottom: 10px;"),
          p("Whether you’re traveling solo, with family, or for business, amenities can make all the difference. Use this table to view and compare average scores for location, cleanliness, service, and value among different hotels. 
            Dive into details of each hotel’s amenities, from pools and gyms to bars, for the best fit for your trip.",
            style = "font-size: 1.2em; margin-bottom: 20px;"),
          p("Curious about specific features? Select one or multiple hotels to see their ratings and amenities side by side, ensuring a better decision.",
            style = "font-size: 1.2em; margin-top: 20px;"),
          DTOutput("hotelTable"),
          uiOutput("bookingButton")
          
        )
      ),
      
      
      div(
        style = "text-align: center; width: 100%; max-width: 1000px; height: 1000px; overflow: hidden;",
        h4("Find Your Perfect Stay Based on Nearby Attractions and Hotel Class", style = "margin-top: 20px;"),
        p("Are you a foodie, a sightseer, or both? This chart compares hotel class with the number of nearby restaurants and attractions, helping you find accommodations that meet your interests. 
        See which hotels offer the best combination of luxury, convenience, and local experiences.",
        style = "font-size: 1.2em; margin-bottom: 20px;"),
        p("Would you prefer a hotel with high-end restaurants nearby or one that’s close to major attractions? 
        Explore the balance of convenience and class to match your needs.",
        style = "font-size: 1.2em; margin-bottom: 20px;"),
        tags$div(
          style = "height: 400px; width: 80%; margin-left: 20%; overflow: auto;",  # Adjust height as needed
          tableauPublicViz("NearbyAttractions", 
                          "https://public.tableau.com/views/Airbnb_17295563103790/Sheet8?:language=en-US&publish=yes&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link", 
                          height = "100%", width = "100%")
        )
      ),
      
    )
  )
)


###### UI ######
ui <- page_navbar(
  id = "navbar",
  theme = bs_theme(
    bootswatch = "yeti"
    #navbar_bg = "#d3d3d3"
  ),
  header = tagList(
    setUpTableauInShiny(),
    # shinyjs를 사용하기 위한 태그 추가
    useShinyjs(),
    extendShinyjs(text = scrollToTopJS, functions = c("scrollToTop"))
  ),
  title = "Melbourne City Guide",
  
  home_tab,
  transportation_tab,
  restaurant_tab,
  attraction_tab,
  accomodation_tab,
  
  
  # shinyjs를 사용하기 위한 태그 추가
  #useShinyjs(),
  #extendShinyjs(text = scrollToTopJS, functions = c("scrollToTop"))
)



################
# SHINY SERVER #
################

server <- function(input, output, session) {
  
  # Home 화면 탭 이동 버튼 처리
  observeEvent(input$btn1, {
    updateTabsetPanel(session, "navbar", selected = "Transportation")
    js$scrollToTop()  # 스크롤 상단 이동
  })
  
  observeEvent(input$btn2, {
    updateTabsetPanel(session, "navbar", selected = "Restaurants")
    js$scrollToTop()  # 스크롤 상단 이동
  })
  
  observeEvent(input$btn3, {
    updateTabsetPanel(session, "navbar", selected = "Attractions")
    js$scrollToTop()  # 스크롤 상단 이동
  })
  
  observeEvent(input$btn4, {
    updateTabsetPanel(session, "navbar", selected = "Accomodation")
    js$scrollToTop()  # 스크롤 상단 이동
  })
  
  output$melbourne_intro <- renderText({
    # Assuming your text file is in the www folder
    readLines("data/melbourne_intro.txt")
  })
  
  # Home 화면 탭 이동 버튼 처리
  observeEvent(input$weather_title_click, {  # weather_table 클릭 이벤트 감지
    shinyjs::show("visitor_chart_container")  # 차트를 표시
  })
  
  ###### Melbourne weather chart ######
  # Dumbbell Chart 생성
  output$dumbbell_chart <- renderHighchart({
    highchart() %>%
      hc_chart(type = "bar") %>%
      hc_title(text = "Melbourne Monthly Temperature Range") %>%
      hc_xAxis(categories = melbourne_weather$Month, title = list(text = NULL)) %>%
      hc_yAxis(title = list(text = "Temperature (°C)")) %>%
      
      # 최소값 표시 (파란색 점)
      hc_add_series(
        type = "scatter",
        data = melbourne_weather$MinimumTemp,
        name = "Minimum Temperature",
        color = "#a2d2ff",
        marker = list(symbol = "circle", radius = 5),
        tooltip = list(pointFormat = "Temperature change: {point.y}°C ~ {point.high}°C"),
        point = list(
          events = list(
            click = JS("function() { 
            Shiny.setInputValue('selected_month', this.series.chart.xAxis[0].categories[this.index]); 
          }")
          )
        )
      ) %>%
      
      # 최대값 표시 (빨간색 점)
      hc_add_series(
        type = "scatter",
        data = melbourne_weather$MaximumTemp,
        name = "Maximum Temperature",
        color = "#e27396",
        marker = list(symbol = "circle", radius = 5),
        tooltip = list(pointFormat = "Temperature change: {point.low}°C ~ {point.y}°C"),
        point = list(
          events = list(
            click = JS("function() { 
            Shiny.setInputValue('selected_month', this.series.chart.xAxis[0].categories[this.index]); 
          }")
          )
        )
      ) %>%
      
      # 덤벨의 연결선 추가
      hc_add_series(
        type = "errorbar",
        data = purrr::map2(melbourne_weather$MinimumTemp, melbourne_weather$MaximumTemp, 
                           ~ list(low = .x, high = .y)),
        name = "Temperature Range",
        color = "#cdb4db",
        pointWidth = 3,
        tooltip = list(pointFormat = "Temperature change: {point.low}°C - {point.high}°C"),
        point = list(
          events = list(
            click = JS("function() { 
            Shiny.setInputValue('selected_month', this.series.chart.xAxis[0].categories[this.index]); 
          }")
          )
        )
      ) %>%
      
      # 툴팁 포맷을 통일하여 모든 시리즈에서 동일한 툴팁 형식 표시
      hc_tooltip(
        useHTML = TRUE,
        formatter = JS("
        function() {
          var minTemp = this.series.chart.series[0].data[this.point.index].y;
          var maxTemp = this.series.chart.series[1].data[this.point.index].y;
          return 'Temperature change: ' + minTemp + '°C ~ ' + maxTemp + '°C';
        }
      ")
      ) %>%
      
      hc_plotOptions(
        series = list(
          pointPadding = 0.1,
          groupPadding = 0.1,
          marker = list(
            enabled = TRUE,
            radius = 4
          )
        )
      )
  })
  
  
  # Dumbbell 차트에서 선택한 월에 따라 필터 작동 확인
  observeEvent(input$selected_month, {
    selected_month <- input$selected_month
    session$sendCustomMessage("updateMonthFilter", selected_month)
  })
  
  
  
  ##################################### Overview of Tourists number #####################################
  
  # Reactive value for the play/pause state
  playing <- reactiveVal(FALSE)
  
  # Function to move to the next year after animation is complete
  nextStep <- function() {
    if (input$year_slider < max(years)) {
      updateSliderInput(session, "year_slider", value = input$year_slider + 1)
    } else {
      playing(FALSE)  # Stop when it reaches the last year
    }
  }
  # 고정된 색상을 지정할 주요 국가 목록과 색상 팔레트
  fixed_countries <- c("Japan", "New Zealand", "United States of America",
                       "UK, CIs & IOM", "Singapore", "Germany", "Hong Kong",
                       "Canada", "Malaysia", "India", "Korea, South")
  
  fixed_colors <- c(
    "New Zealand" = "#feb1a9", 
    "China" = "#fed2bb",
    "United States of America" = "#fef2cd",
    "UK, CIs & IOM" = "#e7f2c3", 
    "India" = "#cff2b8",
    "Japan" = "#bbe5ca",
    "Singapore" = "#a6d8db",
    "Korea, South" = "#b2baea",
    "Indonesia" = "#bd9cf9",
    "Hong Kong" = "#b8abf2",
    "Germany" = "#91c2eb",
    "Canada" = "#91c2eb",
    "Malaysia" = "#ffccd5",
    "Taiwan" = "#ffccd5"
  )
  
  # 국가별 색상을 고정하기 위한 국가 목록
  countries <- unique(tourist_data %>% select(-Year) %>% names())
  
  # 고정된 국가 외의 국가들에 대해 색상을 생성하는 함수 (리스트로 변환)
  custom_colors <- reactive({
    # 고정된 국가들에 대한 색상 매핑
    dynamic_countries <- setdiff(countries, names(fixed_colors))  # 고정되지 않은 국가들
    dynamic_palette <- colorRampPalette(c("#4CAF50", "#FFC107", "#F44336", "#2196F3"))(length(dynamic_countries))
    
    # 고정된 국가와 동적으로 생성된 국가 색상을 결합
    color_palette_list <- c(fixed_colors, setNames(dynamic_palette, dynamic_countries))
    return(color_palette_list)
  })
  
  # 데이터 준비
  data_prepared <- reactive({
    get_data_for_year(input$year_slider)
  })
  
  # 전체 방문자 수 계산
  total_visitors <- reactive({
    total_data <- tourist_data %>% filter(Year == input$year_slider)
    total_sum <- total_data %>% select(-Year) %>% rowSums(na.rm = TRUE)  # Year를 제외하고 모든 열의 합계
    return(total_sum)
  })
  
  max_visitors <- reactive({
    max(tourist_data %>% select(-Year) %>% unlist(use.names = FALSE), na.rm = TRUE)
  })
  
  # Highchart 객체 생성 (반응형 처리)
  output$bar_race_chart <- renderHighchart({
    hc <- highchart() %>%
      hc_chart(type = "bar") %>%
      
      # 차트 제목과 서브 타이틀
      hc_title(text = "Top Tourist Origins Over Time", align = "left",
               style = list(fontSize = "24px", color = "#333333")) %>%
      hc_subtitle(text = "Source: Australian Bureau of Statistics", align = "left",
                  style = list(fontSize = "14px", color = "#666666")) %>%
      
      # X축 설정 (Country 카테고리)
      hc_xAxis(categories = data_prepared()$Country,
               title = list(text = NULL),
               gridLineWidth = 0, lineWidth = 0,
               labels = list(style = list(fontSize = "14px", color = "#444444"))) %>%
      
      # Y축 설정 (Value)
      hc_yAxis(min = 0, max = max_visitors(),
               title = list(text = "Number of Tourists", align = 'high',
                            style = list(fontSize = "16px", color = "#444444")),
               labels = list(style = list(fontSize = "14px", color = "#444444")),
               gridLineWidth = 1) %>%
      
      # 툴팁 설정 (단위를 천 단위 쉼표로 표시)
      hc_tooltip(pointFormat = 'Country: <b>{point.name}</b><br>Tourists: <b>{point.y:,.0f}</b>',
                 style = list(fontSize = "14px")) %>%
      
      # 바 차트 옵션 설정 (숫자를 차트 옆에 표시, 천단위 쉼표 추가)
      hc_plotOptions(bar = list(
        dataLabels = list(
          enabled = TRUE,
          format = '{point.y:,.0f}',  # 천 단위 쉼표를 표시
          style = list(fontSize = "12px", color = "#FFFFFF", textOutline = "none"),
          align = "right",  # 바 오른쪽에 숫자 배치
          inside = FALSE),  # 바 내부에 배치
        grouping = FALSE,
        borderRadius = 8,  # 바 모서리 둥글게
        pointPadding = 0.1,  # 바 간격
        groupPadding = 0.05,  # 그룹 간격
        colorByPoint = TRUE,  # 각 바의 색상을 다르게 적용
        animation = list(
          duration = 1  # 애니메이션 시간을 2초로 설정
        )
      )) %>%
      
      # 시리즈 데이터 추가 (각 국가별 색상 지정)
      hc_add_series(name = paste("Year", input$year_slider),
                    data = purrr::map2(data_prepared()$Country, data_prepared()$Value,
                                       ~list(name = .x, y = .y, color = custom_colors()[[.x]])))  # custom_colors() 호출
    
    # 레전드 추가
    hc <- hc %>%
      hc_legend(enabled = TRUE,
                layout = "horizontal",
                align = "center",
                verticalAlign = "top",
                title = list(
                  text = paste("Total :",
                               formatC(total_visitors(), format = "f", big.mark = ",", digits = 0)  # 모든 국가의 방문자 수 합산
                  )),
                itemStyle = list(fontSize = "14px", fontWeight = "bold", color = "#000000"))
    
    # 크레딧 비활성화
    hc <- hc %>%
      hc_credits(enabled = FALSE) %>%
      hc_size(height = 600)  # 차트 크기 설정
    
    return(hc)
  })
  
  # Reactive value for the play/pause state
  playing <- reactiveVal(FALSE)
  
  # Function to move to the next year after animation is complete
  nextStep <- function() {
    if (input$year_slider < max(years)) {
      updateSliderInput(session, "year_slider", value = input$year_slider + 1)
    } else {
      playing(FALSE)  # Stop when it reaches the last year
    }
  }
  
  # 차트를 자연스럽게 업데이트하기 위해 highchartProxy 사용
  observeEvent(input$year_slider, {
    data_prepared <- get_data_for_year(input$year_slider)
    
    # 차트 시리즈만 업데이트 (리렌더링 방지)
    highchartProxy("bar_race_chart") %>%
      hcpxy_update_series(
        id = 0,  # 시리즈가 하나일 경우 id = 0 사용
        data = data_prepared$Value,  # 데이터만 업데이트
        name = paste("Year", input$year_slider)
      ) %>%
      hcpxy_update(
        list(
          xAxis = list(categories = data_prepared$Country)
        )
      )
  })
  
  # 애니메이션이 완료된 후에만 자동으로 차트 갱신
  observeEvent(input$animationComplete, {
    if (playing()) {
      nextStep()  # 애니메이션이 끝난 후에만 다음 연도로 이동
    }
  })
  
  # 버튼의 아이콘을 Play/Pause로 전환
  observeEvent(input$play_pause_button, {
    if (playing()) {
      updateActionButton(session, "play_pause_button",
                         label = HTML(as.character(icon("play"))))  # Play 버튼으로 전환
      playing(FALSE)  # playing 상태를 FALSE로 전환
    } else {
      updateActionButton(session, "play_pause_button",
                         label = HTML(as.character(icon("pause"))))  # Pause 버튼으로 전환
      playing(TRUE)  # playing 상태를 TRUE로 전환
      nextStep()  # 바로 다음 연도로 이동
    }
  })
  
  # 자동 업데이트를 위한 observe 함수
  observe({
    if (playing()) {
      invalidateLater(0.7, session)  # 1.5초마다 다음 연도로 이동
      nextStep()  # playing 상태가 TRUE일 때만 실행
    }
  })
  
  
  ##################################### Transportation map #####################################
  output$station_map <- renderLeaflet({
    # 선택한 정류장 타입에 따른 필터링
    filtered_data <- switch(input$stop_type,
                            "Tram Stops" = {
                              tram_filtered <- tram_data %>%
                                select(stop_id, latitude, longitude, stop_name, ticketzone, routeussp) %>%
                                mutate(color = "royalblue")  # 트램은 royalblue로 설정
                              if (!is.null(input$tram_number) && length(input$tram_number) > 0) {
                                tram_filtered <- tram_filtered %>%
                                  filter(routeussp %in% input$tram_number)
                              }
                              tram_filtered
                            },
                            "Train Stations" = {
                              train_filtered <- train_data %>%
                                select(stop_id, latitude, longitude, stop_name, ticketzone, routeussp) %>%
                                mutate(color = "green")  # 기차는 green으로 설정
                              if (!is.null(input$train_lines) && length(input$train_lines) > 0) {
                                train_filtered <- train_filtered %>%
                                  filter(routeussp %in% input$train_lines)
                              }
                              train_filtered
                            },
                            "All Stops" = {
                              tram_filtered <- tram_data %>%
                                select(stop_id, latitude, longitude, stop_name, ticketzone, routeussp) %>%
                                mutate(color = "royalblue")  # 트램은 royalblue로 설정
                              train_filtered <- train_data %>%
                                select(stop_id, latitude, longitude, stop_name, ticketzone, routeussp) %>%
                                mutate(color = "green")  # 기차는 green으로 설정
                              
                              combined_data <- rbind(tram_filtered, train_filtered)
                              combined_data
                            }
    )
    
    leaflet() %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      setView(lng = 144.9631, lat = -37.8136, zoom = 13) %>%
      addCircles(
        data = filtered_data,
        lat = ~latitude, lng = ~longitude,
        popup = ~paste("Stop Name: ", stop_name, "<br>Line: ", routeussp),
        color = ~color,
        radius = 50
      )
  })
  
  
  ##################################### Touristic map #####################################
  output$touristic_map <- renderLeaflet({
    shuttle_data_mod <- shuttle_data %>%
      mutate(routeussp = NA, color = "orchid") %>% 
      select(stop_id, stop_name, latitude, longitude, routeussp, color)
    
    skybus_data_mod <- skybus_data %>%
      mutate(color = "orchid") %>%
      select(stop_id, stop_name, latitude, longitude, routeussp, color)
    
    citytram_data_mod <- citytram_data %>%
      mutate(stop_id = row_number(), routeussp = NA, color="skyblue") %>%
      select(stop_id, stop_name, latitude, longitude, routeussp, color)
    
    tour_filtered_data <- switch(input$touristic_stop_type,
                                 "Visitor Shuttle" = shuttle_data_mod,
                                 "SkyBus" = skybus_data_mod,
                                 "City Circle Tram" = citytram_data_mod,
                                 "All Touristic Stops" = bind_rows(shuttle_data_mod, skybus_data_mod, citytram_data_mod)
    )
    
    leaflet() %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      setView(lng = 144.9631, lat = -37.8136, zoom = 15) %>%
      addCircles(
        data = tour_filtered_data,
        lat = ~latitude, lng = ~longitude,
        popup = ~paste("Stop Name: ", stop_name),
        color = ~color,
        radius = 50
      )
  })
  
  ##################################### Tram length chart #####################################  
  
  tram_length_data <- data.frame(
    rank = 1:10,
    city = c("Melbourne", "St.Petersburg", "Berlin", "Moscow", "Milan", "Katowice", "Vienna", "Budapest", "Dallas", "Lodz"),
    country = c("Australia", "Russia", "Germany", "Russia", "Italy", "Poland", "Austria", "Hungary", "US", "Poland"),
    length = c(250, 205.5, 193, 182, 181.8, 178, 176.9, 174, 149.9, 145)
  )
  
  # Highchart 출력
  output$tram_length_bar_chart <- renderHighchart({
    
    # 선택된 국가 필터링 (All 선택 시 모든 국가 포함)
    data_prepared <- if ("All" %in% input$country_filter || is.null(input$country_filter)) {
      tram_length_data
    } else {
      tram_length_data %>% filter(country %in% input$country_filter)
    }
    
    # 각 나라별 색상을 지정
    country_colors <- c(
      "Australia" = "#CFBAF0",
      "Russia" = "#90DBF4",
      "Germany" = "#F1C0E8",
      "Italy" = "#FDE4CF",
      "Poland" = "#B9FBC0",
      "Austria" = "#98F5E1",
      "Hungary" = "#FFCFD2",
      "US" = "#FBF8CC"
    )
    
    # 데이터 리스트 변환
    data_list <- purrr::pmap(list(data_prepared$city, data_prepared$length, data_prepared$country), function(city, length, country) {
      list(name = city, y = length, country = country, color = country_colors[[country]])
    })
    
    # highchart 객체 생성
    highchart() %>%
      hc_chart(type = "bar") %>%
      hc_title(text = "Tram System Length by City", align = "left") %>%
      hc_subtitle(text = 'Source: https://rail.nridigital.com/future_rail_sep23/10_largest_tram_networks', align = 'left') %>%
      
      # X축 설정 (city를 카테고리로 사용)
      hc_xAxis(categories = data_prepared$city,
               title = list(text = NULL),
               gridLineWidth = 1,  # 그리드 라인 설정
               lineWidth = 0) %>%  # X축 라인 설정
      
      # Y축 설정 (length를 y축 값으로 사용)
      hc_yAxis(min = 0,
               title = list(text = 'Length (km)', align = 'high'),
               labels = list(overflow = 'justify'),
               gridLineWidth = 0) %>%
      
      # 툴팁 설정
      hc_tooltip(pointFormat = 'Country: <b>{point.country}</b>') %>%
      
      
      # 바 차트 옵션 설정
      hc_plotOptions(bar = list(
        borderRadius = '3%',
        dataLabels = list(
          enabled = TRUE
        ),
        groupPadding = 0.1  # 바 간격 설정
      )) %>%
      
      
      # 크레딧 비활성화
      hc_credits(enabled = FALSE) %>%
      
      # 시리즈 데이터 설정 (도시별 길이 데이터)
      hc_add_series(name = "Tram System Length",
                    data = data_list,
                    colorByPoint = TRUE)  # 각 바의 색상 변경
  })
  
  
  ##################################### Restauran tab link click event #####################################
  observeEvent(input$RestaurantMap_mark_selection_changed, {
    
    # 선택된 값이 없으면 빈 테이블 출력
    if (length(input$RestaurantMap_mark_selection_changed) == 0) {
      restaurant_table <- data.frame(Info = c("Name:", "Address:", "Rating:", "Price Level:"),
                                     Value = c("", "", "", ""))
      output$restaurant_info <- render_gt({
        gt(restaurant_table) %>%
          tab_options(
            table.width = pct(60),  # 표의 너비 고정
            table.font.size = 14,   # 폰트 크기 조정
            data_row.padding = px(10),  # 행 패딩 조정
            heading.align = "left",    # 헤더 정렬
            column_labels.hidden = TRUE
          ) %>%
          cols_label(Info = "", Value = "")  # 첫 번째 행의 레이블 제거
      })
      return()  # 이 시점에서 종료
    }
    
    selected_restaurant <- input$RestaurantMap_mark_selection_changed
    selected_name <- selected_restaurant$`Trading name`
    
    # 선택된 레스토랑 데이터 필터링
    selected_info <- restaurant_data %>%
      filter(`Trading name` == selected_name) %>%
      select(`Trading name`, `Business address`, rating, priceLevel, `Industry Category`)
    
    # 데이터를 표 형식으로 구성
    if (nrow(selected_info) > 0) {
      restaurant_table <- data.frame(
        Info = c("Name:", "Address:", "Rating:", "Price Level:"),
        Value = c(selected_info$`Trading name`, selected_info$`Business address`, selected_info$rating, selected_info$priceLevel),
        Category = selected_info$`Industry Category`  # 카테고리 추가
      )
    } else {
      restaurant_table <- data.frame(Info = c("Name:", "Address:", "Rating:", "Price Level:"),
                                     Value = c("", "", "", ""),
                                     Category = "")
    }
    
    # 카테고리별로 전체 표의 색상을 변경하여 출력
    output$restaurant_info <- render_gt({
      gt(restaurant_table) %>%
        tab_options(
          table.width = pct(60),
          table.font.size = 14,
          data_row.padding = px(10),
          heading.align = "left",
          column_labels.hidden = TRUE
        ) %>%
        # 테이블 전체 배경색을 카테고리에 맞게 지정
        tab_style(
          style = list(cell_fill(color = case_when(
            restaurant_table$Category[1] == "Cafes and Restaurants" ~ "mistyrose",
            restaurant_table$Category[1] == "Pubs, Taverns and Bars" ~ "peachpuff",
            restaurant_table$Category[1] == "Takeaway Food Services" ~ "thistle",
            restaurant_table$Category[1] == "Bakery" ~ "lemonchiffon",
            restaurant_table$Category[1] == "Convenience Store" ~ "honeydew",
            restaurant_table$Category[1] == "Supermarket and Grocery Stores" ~ "azure",
            restaurant_table$Category[1] == "Others" ~ "gainsboro"
          ))),
          locations = cells_body(columns = everything())
        ) %>%
        cols_hide(columns = "Category") %>%  # Category 컬럼을 숨김
        cols_label(Info = "", Value = "")  # Info와 Value 레이블 제거
    })
  })
  
  # 기본적으로 빈 테이블을 출력
  output$restaurant_info <- render_gt({
    gt(data.frame(Info = c("Name:", "Address:", "Rating:", "Price Level:"),
                  Value = c("", "", "", ""))) %>%
      tab_options(
        table.width = pct(60),
        table.font.size = 14,
        data_row.padding = px(10),
        heading.align = "left",
        column_labels.hidden = TRUE
      ) %>%
      cols_label(Info = "", Value = "")  # Info와 Value 레이블 제거
  })
  
  ##################################### Observe link click event #####################################
  
  observeEvent(input$tram_link, {
    updateRadioButtons(session, "stop_type", selected = "Tram Stops")
  })
  
  observeEvent(input$train_link, {
    updateRadioButtons(session, "stop_type", selected = "Train Stations")
  })
  
  observeEvent(input$tram_title, {
    updateRadioButtons(session, "stop_type", selected = "All Stops")
  })
  
  # Observe link click events for touristic value boxes
  observeEvent(input$visitor_shuttle_link, {
    updateRadioButtons(session, "touristic_stop_type", selected = "Visitor Shuttle")
  })
  
  observeEvent(input$skybus_link, {
    updateRadioButtons(session, "touristic_stop_type", selected = "SkyBus")
  })
  
  observeEvent(input$citytram_link, {
    updateRadioButtons(session, "touristic_stop_type", selected = "City Circle Tram")
  })
  
  observeEvent(input$touristic_title, {
    updateRadioButtons(session, "touristic_stop_type", selected = "All Touristic Stops")
  })

  ######################### Accomodation #########################
  observeEvent(input$tableau_viz_mark_selection_changed, {
    selected_hotel <- input$tableau_viz_mark_selection_changed
    # Check if selected_hotel is a list and has data
    if (is.list(selected_hotel) && length(selected_hotel) > 0 && !is.null(selected_hotel$Name) && length(selected_hotel$Name) > 0) {
      # Process all selected hotels
      hotel_names <- selected_hotel$Name  # Get all selected hotel names
      
      # Initialize a list to store output data frames
      output_data_list <- list()
      
      for (hotel_name in hotel_names) {
        # Filter the hotel data for the selected hotel
        selected_data <- hotel_data[hotel_data$name == hotel_name, ]
        
        # Check if selected_data is not empty
        if (nrow(selected_data) > 0) {
          # Calculate the average of the specified columns
          avg_score <- mean(c(selected_data$Location, selected_data$Cleanliness, selected_data$Service, selected_data$Value), na.rm = TRUE)
          
          # Prepare data for the output data frame
          output_data <- data.frame(
            `Hotel Name` = hotel_name,  # Add hotel name column
            `Overall Score` = avg_score,
            Pool = ifelse(selected_data$Pool == 1, "Yes", "No"),
            `Bar / Lounge` = ifelse(selected_data$`Bar...lounge` == 1, "Yes", "No"),  # Adjusted to match the CSV header
            Gym = ifelse(selected_data$Gym == 1, "Yes", "No"),
            Link = sprintf('<a href="%s" target="_blank">Book Now</a>', selected_data$website)  # Create a clickable link
          )
          
          # Rename columns to have spaces instead of dots
          colnames(output_data) <- c("Hotel Name", "Overall Score", "Pool", "Bar / Lounge", "Gym", "Link")
          
          # Append the output data frame to the list
          output_data_list[[hotel_name]] <- output_data
        }
      }
      
      # Combine all output data frames into one
      if (length(output_data_list) > 0) {
        combined_output_data <- do.call(rbind, output_data_list)
        
        # Render the table
        output$hotelTable <- renderDT({
          datatable(combined_output_data, 
                    options = list(dom = 't', paging = FALSE), 
                    rownames = FALSE, 
                    escape = FALSE) %>%
            formatStyle(
              columns = colnames(combined_output_data),  # Apply to all columns
              `text-align` = 'center'  # Center the text
            )
        })
      } else {
        # Handle case where no data is found for the selected hotels
        output$hotelTable <- renderDT(NULL)  # Clear the table
      }
    } else {
      # Handle case where no hotel is selected or selected_hotel is an empty list
      output$hotelTable <- renderDT(NULL)  # Clear the table
      print("No hotel selected or selected_hotel is an empty list.")  # Debugging output
    }
  })  
}


#############
# RUN SHINY #
#############

shinyApp(ui, server, options=list(launch.browser=TRUE))


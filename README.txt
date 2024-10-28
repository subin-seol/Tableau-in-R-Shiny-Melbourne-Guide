GEOM90007 Information Visualisation Assignment 3
Group 48: Sangmoon Han, Evelyn Liu, Soyeon Park, Subin Seol

Melbourne City Guide App
This Shiny app provides an interactive guide to exploring Melbourne, Australia, with rich visualisations and dynamic data updates powered by Tableau and R Shiny. The app is organized into tab-based sections covering various topics, including home, transportation, restaurants, attractions, and accommodations. Users can easily navigate and interact with these sections to explore Melbourne's top sites and gain insights into the city's offerings.

1. App Overview
This app integrates Tableau visualizations into R Shine to create an interactive experience. Users can explore different aspects of Melbourne through five main tabs:
    - Home: Introduction to Melbourne.
    - Transportation: Explore public transportation options in Melbourne.
    - Restaurants: Discover Melbourne’s culinary scene and locate popular restaurants.
    - Attractions: Find top attractions in the city.
    - Accommodations: Access information on various accommodation options, including Airbnb and hotels.

2. Features
- Interactive Map Visualizations: Tableau maps embedded within each section enable users to visually explore locations.
- Dynamic Data Filtering: Users can filter data by attributes such as price, rating, season, and specific types (e.g., restaurant category, tram lines).
- Tab-Based Navigation: Intuitive tab structure to easily navigate between sections.
- R to Tableau and Tableau to R Interactivity: Communication between Shiny and Tableau for real-time data updates.
- Top Recommendations: Key sections feature “Top Ranked” items for quick access to the highest-rated options.

3. Installation and Setup
Prerequisites: R, RStudio (optional but recommended)
Required R Packages:
shiny, shinythemes, shinyjs, readr, gt, dplyr, tidyr, bslib, highcharter, fontawesome, shinyWidgets, jsonlite, leaflet, geojsonio, sf, DT
Tableau Public Account (for using embedded Tableau visualizations)

4. Usage
4.1. Navigating the App
    - Home Tab: Start here for a brief overview of Melbourne.
    - Transportation Tab: Explore transportation options and view tram and train stations on an interactive map.
    - Restaurants Tab: Discover Melbourne’s restaurant scene, filter by categories, and view top-rated restaurants.
    - Attractions Tab: Explore the top tourist attractions, filtered by theme and sub-theme, using a packed bubble chart.
    - Accommodations Tab: View top Airbnb and hotel options with additional information on nearby attractions.
4.2. Interactive Components
    - Tableau Map Integration: The app integrates Tableau workbooks directly into the Shiny application, enabling Tableau visualizations to respond to Shiny UI elements. Interactivity extends both ways—when users interact with Tableau visualizations, the Shiny interface updates in response.
    - Dynamic Data Tables: Selecting a restaurant or hotel displays detailed information below the map, including name, address, and ratings.
    - Highcharter Visualizations: Provides visual representation of trends over time, such as tourist origins by year, allowing users to track changes dynamically.

5. Files and Directories
MelbourneGuide_final.R: Main file containing the Shiny app code, including UI and server components.
data/: Directory containing CSV and GeoJSON files for use within the app.
tableau-in-shiny-v1.2.R: Script enabling Shiny-Tableau integration for handling embedded Tableau visualizations.
www/: Contains static assets such as images used in the app.
README.md: Documentation for setting up and using the app.

6. References
https://data.melbourne.vic.gov.au/pages/home/
https://www.data.vic.gov.au/
https://www.abs.gov.au/statistics/industry/tourism-and-transport/overseas-arrivals-and-departures-australia/aug-2024#visitor-arrivals-short-term
https://www.kaggle.com/datasets/kanchana1990/top-500-melbourne-eateries-tripadvisors-best
https://data.melbourne.vic.gov.au/explore/dataset/landmarks-and-places-of-interest-including-schools-theatres-health-services-spor/information/
https://business.vic.gov.au/__data/assets/pdf_file/0009/1865160/Melbournes-Top-Attractions-year-ending-December-2019.pdf
https://www.australia.com
https://localguidetomelbourne.com/tours

7. License
This project is licensed under the MIT License.
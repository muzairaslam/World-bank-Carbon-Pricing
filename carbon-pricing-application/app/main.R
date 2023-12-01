box::use(
  shiny[moduleServer, 
        NS, 
        fluidRow, 
        icon, 
        h1],
  semantic.dashboard[
    dashboardPage,
    dashboardHeader, dashboardBody, dashboardSidebar,
    sidebarMenu, menuItem
  ],
  leaflet[
    leafletOutput, renderLeaflet,
    leaflet, setView, addTiles
  ],
)

box::use(app/logic/plot_map)

nationals <- readRDS("data-raw/nationals.rds")
subnationals <- readRDS("data-raw/subnationals.rds")
regionals <- readRDS("data-raw/regionals.rds")

#' @export
ui <- function(id) {
  ns <- NS(id)
  dashboardPage(
    dashboardHeader(left = h1("Carbon Pricing dashboard")),
    dashboardSidebar(sidebarMenu(
      menuItem(tabName = "map", text = "Map"),
      menuItem(tabName = "ghg", text = "GHG Emission Coverage"),
      menuItem(tabName = "price", text = "Price"),
      menuItem(tabName = "revenue", text = "Revenue")
    ), side = "top", visible = FALSE),
    dashboardBody(
      fluidRow(
        leafletOutput(ns("main_map"))
      )
    )
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    output$main_map <- renderLeaflet({
      plot_map$plot_leaflet_map(nationals, regionals, subnationals)
    })
  })
}





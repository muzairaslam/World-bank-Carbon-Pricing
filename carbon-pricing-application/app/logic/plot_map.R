box::use(
  leaflet[
    leaflet, leafletOptions,
    providers, addProviderTiles, providerTileOptions,
    awesomeIcons, addAwesomeMarkers, addPolygons,
    colorFactor, highlightOptions, addLayersControl, layersControlOptions],
  dplyr[recode, pull, filter],
  sf[st_as_sf]
)

plot_leaflet_map <- function(nationals, regionals, subnationals) {
  # row bind nationals and regionals and convert to sf object
  ldf <- rbind(nationals, regionals) |>
    st_as_sf()
  # create leaflet object and provide WorldTopoMap
  lf_map <- leaflet(options = leafletOptions(minZoom = 3)) |>
    addProviderTiles(
      providers$Esri.WorldTopoMap,
      options = providerTileOptions(minZoom = 0, maxZoom = 18)
    )
  
  # add awesomeicons on the map based on the types
  for (stype in unique(subnationals$Type)) {
    icons <- awesomeIcons(icon = recode(subnationals |>
                                           filter(Type == stype) |>
                                           pull(Status),
                                         "Implemented" = "fa-check",
                                         "Scheduled" = "fa-clock-o",
                                         "Under consideration" = "fa-spinner"),
                           iconColor = "black",
                           library = "fa",
                           markerColor = recode(subnationals |>
                                                  filter(Type == stype) |>
                                                  pull(Type),
                                                "ETS" = "blue", "Carbon tax" = "green")
    )
    lf_map <- lf_map |>
      addAwesomeMarkers(data = subnationals |> filter(Type == stype),
                        lat = ~lat, lng = ~lon, icon = icons,
                        label = ~paste(`Name of the initiative`),
                        group = paste0("", stype))
  }
  
  for (ntype in unique(ldf$Type)) {
    lf_map <- lf_map |>
      addPolygons(data = ldf |> filter(Type == ntype),
                  weight = 1, group = paste0("", ntype),
                  fillColor = ~colorFactor(c("green", "blue", "gray"),
                                           domain = ldf$Type)(Type),
                  color = "white", label = ~paste(`Name of the initiative`),
                  highlightOptions = highlightOptions(color = "white",
                                                      weight = 2,
                                                      bringToFront = TRUE))
  }
  
  lf_map |>
    addLayersControl(
      overlayGroups = c(paste0("", unique(subnationals$Type)),
                        paste0("", unique(ldf$Type))),
      options = layersControlOptions(collapsed = FALSE)
    )
}
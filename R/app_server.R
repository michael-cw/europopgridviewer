#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @import mapdeck
#' @import sf
#' @import giscoR
#' @import dplyr
#' @importFrom grDevices topo.colors
#' @importFrom stats setNames
#' @noRd
#'
#'


app_server <- function(input, output, session) {

  countries_name<-reactive({

    countries_name<-countries %>% dplyr::select(c(NAME_ENGL, ISO3_CODE)) %>% sf::st_set_geometry(NULL)
    countries_name<-setNames(countries_name$ISO3_CODE, countries_name$NAME_ENGL)
    return(countries_name)
  })


  # Subset
  region_sub<-reactive({
    req(input$select1)
    if(input$select1!="None") {
      withProgress(message = 'Preparing Map', value = 0.2,
                   {
                     countries_sel<-countries %>% dplyr::filter(ISO3_CODE==input$select)
                     regions <- giscoR::gisco_get_grid(resolution = as.numeric(input$select1))
                     incProgress(0.5)
                     regions<-regions %>% sf::st_transform(4326)
                     incProgress(0.2)
                     regions<-regions[countries_sel,]
                     incProgress(0.1)
                     return(regions)
                   })
    }
  })


  # Create Mapdeck map
  output$map <- renderMapdeck({

    ## Subset to Austria for view
    crou<-countries %>% dplyr::filter(ISO3_CODE=="AUT")
    locationbb<-sf::st_as_sfc(sf::st_bbox(crou)) %>% sf::st_centroid() %>% sf::st_coordinates()
    locationbb<-as.numeric(t(locationbb))

    mapdeck(location = locationbb,
            zoom = 4,
            token = golem::get_golem_options("mapdeck_api_key"),
            style = mapdeck_style("satellite-streets")) %>%
      add_polygon(data = countries, layer_id = "layer1",
                  fill_opacity = 0.7,
                  fill_colour = "ISO3_CODE",
                  focus_layer = F, update_view = F,
                  legend = F)

  })

  # Update map based on layer selection
  SELECTORS<-reactive({ list(input$select, input$select1) })
  observeEvent(SELECTORS(), {
    req(region_sub())
    reg_sub<-region_sub()
    # Create Tooltip
    reg_sub$GRIDID_POP<-(sprintf("<b><font color ='green'>GRIDID:</font></b> %s,<br>
                                   <b><font color ='green'>Population:</font></b> %d",
                                 reg_sub$GRD_ID, reg_sub$TOT_P_2018))

    mapdeck_update(map_id = "map") %>%
      clear_polygon("layer1") %>%
      add_polygon(data = reg_sub, focus_layer = T, update_view = T,
                  tooltip = "GRIDID_POP",
                  layer_id = "layer1",
                  palette = "spectral",
                  fill_colour = "TOT_P_2018",
                  fill_opacity = 0.7,
                  stroke_colour = "#000000",
                  stroke_width = 20,
                  legend = list(fill_colour = T,
                                stroke_colour = F),
                  legend_options = list(fill_colour = list(title = "Persons"),
                                        css = "text-align: center; font-weight: bold;"),
                  legend_format = list(fill_colour = as.integer)
      )

  })

  # Render Map
  output$fullmap <- renderUI({
    mapdeckOutput("map", width  = "100%", height = ceiling(shinybrowser::get_height()*0.95))
  })

  # Render sidebar
  output$sidebar <- renderUI({
    fluidPage(
      div(class = "sidebar",
          shiny::img(src = "www/logoWBDG.png",
              class = "logo",
              height = 70, width = 220),
          h2("Eurostat Population Grid Viewer"), br(), br(),
          selectizeInput("select", "Select Province:", countries_name(), selected = "ROU",
                         multiple = FALSE), br(), br(),
          selectizeInput("select1", "Select Layer:", c("None" = "None", "Grid 10km" = "10",  "Grid 5km" = "5"),
                         multiple = FALSE), br(), br(),
          DT::dataTableOutput("table"),br(),
          downloadButton("download_pdf", "Download PDF")
      )
    )
  })

  # Render small table made with DT package
  tab<-eventReactive(SELECTORS(), {
    req(input$select1)
    if(input$select1!="None") {
      regions<-region_sub()
      n_cells<-nrow(regions)
      n_pop18<-sum(regions$TOT_P_2018)
      n_pop11<-sum(regions$TOT_P_2011)
      m_pop18<-round(n_pop18/n_cells, 2)
      m_land<-round(mean(regions$LAND_PC), 2)
      tab<-cbind(
        c("Number of cells", "Total Population 2018", "Total Population 2011",
          "Average Population per cell (2018)","Average Land"),
        c(n_cells, n_pop18, n_pop11, m_pop18, m_land)
      )
    }
  })

  output$table <- DT::renderDataTable({
    shiny::validate(need(tab(), message = F))
    DT::datatable(tab(),
                  rownames = F,
                  colnames = c("", ""),
                  options = list(dom = 't',
                                 autoWidth = TRUE,
                                 ordering = FALSE,
                                 searching = FALSE,
                                 paging = FALSE))
  })

  # Show Attribution in UI
  output$license<-renderUI({
    HTML(cptext)
  })
  # Define download handler for download_pdf button
  output$download_pdf <- downloadHandler(
    filename = "selected_layer.pdf",
    content = function(file) {
      regions<-region_sub()
      shiny::validate(need(regions, message = F))
      if (input$select1!="None") {
        regions<-region_sub()
        shiny::validate(need(regions, message = F))
        p <- ggplot2::ggplot() +
          ggspatial::annotation_map_tile(type = "osm", cachedir = tempdir()) +
          ggspatial::annotation_north_arrow(which_north = T) +
          ggspatial::annotation_scale(location = "br") +
          ggplot2::theme(legend.position="bottom", plot.title = ggplot2::element_text(hjust =  0.5),
                plot.subtitle = ggplot2::element_text(hjust =  0.5)) +
          ggplot2::scale_fill_gradientn("Persons", colors = topo.colors(6), labels = scales::comma) +
          ggplot2::ggtitle(paste("Population Grid", input$select), subtitle = paste(input$select1, "km")) +
          ggplot2::guides(fill = ggplot2::guide_legend(keywidth = ggplot2::unit(1, "cm"))) +
          ggplot2::geom_sf(data = regions,
                           ggplot2::aes(fill = TOT_P_2018),
                  alpha = 0.7)

        ggplot2::ggsave(plot = p, file = file, width = 21, height = 21, units = "cm")  # save ggplot object as PDF
      }
    }
  )

  #################################################################################################################################

}

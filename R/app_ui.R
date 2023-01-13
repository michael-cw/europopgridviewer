#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#'
#' @import shiny
#' @import mapdeck
#'
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # Your application UI logic
    # includeCSS("style.css"),
    shinybrowser::detect(),
    tabsetPanel(
      tabPanel("Map",
               fluidRow(
                 column(12,
                        uiOutput("sidebar"),
                        shinycssloaders::withSpinner(
                          uiOutput("fullmap")
                        )
                 )
               )
      ),
      tabPanel("Info",
               fluidRow(
                 column(1),
                 column(6, uiOutput("license")),
                 column(5)
               )
      )
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "europopgridviewer"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}

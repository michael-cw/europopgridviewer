#' Run the Shiny Application
#'
#' @description This will start the the population grid viewer. For details on the population grid copyright and the correct attribution,
#' retrieved through the \href{https://ropengov.github.io/giscoR/}{giscoR} package, please click on the info tab.
#'
#' @param mapboxkey mapbox key required for your basemap. If no key is provided, they different layers will still be visible, but
#' without a background map.
#'
#' @param ... arguments to pass to golem_opts.
#' See `?golem::get_golem_options` for more details.
#' @inheritParams shiny::shinyApp
#'
#' @export
#' @importFrom shiny shinyApp
#' @importFrom golem with_golem_options
run_app <- function(
  mapboxkey = NULL,
  onStart = NULL,
  options = list(),
  enableBookmarking = NULL,
  uiPattern = "/",
  ...
) {
  with_golem_options(
    app = shinyApp(
      ui = app_ui,
      server = app_server,
      onStart = onStart,
      options = list(launch.browser=T),
      enableBookmarking = enableBookmarking,
      uiPattern = uiPattern
    ),
    golem_opts = list(
      mapdeck_api_key = ifelse(is.null(mapboxkey), "nokey", mapboxkey)
    )
  )
}

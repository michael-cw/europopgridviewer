#' Copyright for giscoR
#'
#' @noRd
#'

cptext<-c(
  "<br>    <b>COPYRIGHT NOTICE for the giscoR package <br>
  used by the application. </b><br><br><br>    When data downloaded from GISCO<br>    is used in any printed or electronic
  publication,<br>    in addition to any other provisions applicable to<br>    the whole Eurostat website,
  data source will have<br>    to be acknowledged in the legend of the map and in<br>
  the introductory page of the publication with the<br>    following copyright notice:<br><br>
  - EN: (C) EuroGeographics for the administrative boundaries<br>
  - FR: (C) EuroGeographics pour les limites administratives<br>
  - DE: (C) EuroGeographics bezuglich der Verwaltungsgrenzen<br><br>
  For publications in languages other than English,<br>
  French or German, the translation of the copyright<br>
  notice in the language of the publication shall be<br>
  used.<br><br>
  If you intend to use the data commercially, please<br>
  contact EuroGeographics for information regarding<br>
  their licence agreements.<br><br>      "
)

#' Loading countries with giscoR
#'
#' @noRd
#'

countries<-giscoR::gisco_get_countries(region = "EU")



#' Global Variables with no visible binding, i.e data.table, dplyr etc.
#'
#' @noRd
#'
utils::globalVariables(c("ISO3_CODE", "NAME_ENGL", "TOT_P_2018"))

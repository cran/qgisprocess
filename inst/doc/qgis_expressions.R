## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
can_build <- qgisprocess::has_qgis() &&
  package_version(qgisprocess::qgis_version(full = FALSE)) >= "3.30.0" &&
  requireNamespace("sf", quietly = TRUE)

## ----setup, message=FALSE-----------------------------------------------------
library(qgisprocess)
library(sf)

## -----------------------------------------------------------------------------
qgis_get_argument_specs("native:fieldcalculator") |> subset(name == "FORMULA")

## -----------------------------------------------------------------------------
qgis_get_argument_specs("native:buffer") |> 
  subset(name == "DISTANCE") |> 
  dplyr::select(acceptable_values) |> 
  tidyr::unnest(cols = acceptable_values) |> 
  knitr::kable()

## -----------------------------------------------------------------------------
longlake_path <- system.file("longlake/longlake.gpkg", package = "qgisprocess")
longlake_depth_path <- system.file("longlake/longlake_depth.gpkg", package = "qgisprocess")

## -----------------------------------------------------------------------------
nrow(read_sf(longlake_depth_path))

## -----------------------------------------------------------------------------
qgis_run_algorithm(
  "native:extractbyexpression",
  INPUT = longlake_depth_path,
  EXPRESSION = '"DEPTH_M" > 1'
) |>
  st_as_sf()

## -----------------------------------------------------------------------------
lake_border_path <- qgis_run_algorithm(
  "native:polygonstolines", 
  INPUT = longlake_path
) |> 
  qgis_extract_output("OUTPUT")

## -----------------------------------------------------------------------------
expr <- glue::glue("distance(
                     @geometry, 
                     geometry(
                       get_feature_by_id(
                         load_layer('{lake_border_path}', 'ogr'), 
                         1
                       )
                     )
                    )")

## ----eval=!qgisprocess:::is_windows()-----------------------------------------
qgis_run_algorithm(
  "native:fieldcalculator",
  INPUT = longlake_depth_path,
  FIELD_NAME = "distance",
  FORMULA = expr
) |> 
  st_as_sf()

## -----------------------------------------------------------------------------
buffer <- qgis_run_algorithm(
  "native:buffer",
  INPUT = longlake_depth_path,
  DISTANCE = 'expression: "DEPTH_M" * 10'
) |> 
  st_as_sf()

## -----------------------------------------------------------------------------
st_geometry_type(buffer) |> as.character() |> table()

## -----------------------------------------------------------------------------
oldpar <- par(mar = rep(0.1, 4))
plot(read_sf(lake_border_path) |> st_geometry())
plot(buffer[, "DEPTH_M"], add = TRUE)
par(oldpar)

## ----eval=FALSE---------------------------------------------------------------
#  qgis_run_algorithm(
#    "native:buffer",
#    INPUT = longlake_depth_path,
#    DISTANCE = "field:DEPTH_M"
#  ) |>
#    st_as_sf()

## ----eval=!can_build, echo=FALSE, results="asis"------------------------------
#  cat("This vignette has been built in absence of a QGIS installation with version >= 3.30.0, or in absence of the sf package.\n\n")
#  cat("Read it online at <https://r-spatial.github.io/qgisprocess/articles/qgis_expressions.html>.")


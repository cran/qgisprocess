## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
can_build <- qgisprocess::has_qgis()

## ----setup, message=FALSE-----------------------------------------------------
library(qgisprocess)

## -----------------------------------------------------------------------------
qgis_get_argument_specs("native:joinbynearest") |> 
  subset(select = name:qgis_type)

## ----eval=!can_build, echo=FALSE, results="asis"------------------------------
#  cat("This vignette has been built in absence of a QGIS installation.\n\n")
#  cat("Read it online at <https://r-spatial.github.io/qgisprocess/articles/qgis_arguments.html>.")


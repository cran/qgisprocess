% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/qgis-function.R
\name{qgis_function}
\alias{qgis_function}
\title{Create a wrapper function that runs one algorithm}
\usage{
qgis_function(algorithm, ...)
}
\arguments{
\item{algorithm}{A qualified algorithm name
(e.g., \code{"native:buffer"}).}

\item{...}{Algorithm arguments.
These values are evaluated once and immediately, so you shouldn't
call \code{\link[=qgis_tmp_file]{qgis_tmp_file()}} here.}
}
\value{
A function.
}
\description{
As opposed to \code{\link[=qgis_run_algorithm]{qgis_run_algorithm()}}, \code{\link[=qgis_function]{qgis_function()}} creates a callable
function based on the argument metadata provided by \code{\link[=qgis_get_argument_specs]{qgis_get_argument_specs()}}.
}
\details{
The logic of \code{qgis_function()} has been implemented in R package
\href{https://github.com/JanCaha/r_package_qgis}{qgis}.
This package also provides the QGIS documentation of each processing
algorithm as corresponding R function documentation.
}
\examples{
\dontshow{if (has_qgis()) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
qgis_buffer <- qgis_function("native:buffer")
qgis_buffer(
  system.file(
    "longlake/longlake_depth.gpkg",
    package = "qgisprocess"
  ),
  DISTANCE = 10
)
\dontshow{\}) # examplesIf}
}

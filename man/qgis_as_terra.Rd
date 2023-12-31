% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/compat-terra.R
\name{qgis_as_terra}
\alias{qgis_as_terra}
\alias{qgis_as_terra.qgis_outputRaster}
\alias{qgis_as_terra.qgis_outputLayer}
\alias{qgis_as_terra.qgis_outputVector}
\alias{qgis_as_terra.qgis_result}
\title{Convert a qgis_result object or one of its elements to a terra object}
\usage{
qgis_as_terra(x, ...)

\method{qgis_as_terra}{qgis_outputRaster}(x, ...)

\method{qgis_as_terra}{qgis_outputLayer}(x, ...)

\method{qgis_as_terra}{qgis_outputVector}(x, ...)

\method{qgis_as_terra}{qgis_result}(x, ...)
}
\arguments{
\item{x}{A \code{qgis_result} object from \code{\link[=qgis_run_algorithm]{qgis_run_algorithm()}} or a
\verb{qgis_output*} object from one of the \code{\link[=qgis_extract_output]{qgis_extract_output()}} functions.}

\item{...}{Arguments passed to \code{\link[terra:rast]{terra::rast()}} or \code{\link[terra:vect]{terra::vect()}}, depending
on the output type of \code{x} (or one of its elements, if \code{x} is a
\code{qgis_result}).}
}
\value{
A \code{SpatRaster}, \code{SpatVector} or \code{SpatVectorProxy} object.
}
\description{
This function performs coercion to one of the terra classes
\code{SpatRaster}, \code{SpatVector} or \code{SpatVectorProxy} (add \code{proxy = TRUE} for the
latter).
The distinction between \code{SpatRaster} and \code{SpatVector} is based on the
output type.
}
\examples{
\dontshow{if (has_qgis() && requireNamespace("terra", quietly = TRUE)) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
\donttest{
# not running below examples in R CMD check to save time
result <- qgis_run_algorithm(
  "native:slope",
  INPUT = system.file("longlake/longlake_depth.tif", package = "qgisprocess")
)

# most direct approach, autoselecting a `qgis_outputRaster` type
# output from the `result` object and reading as SpatRaster:
qgis_as_terra(result)

# if you need more control, extract the needed output element first:
output_raster <- qgis_extract_output(result, "OUTPUT")
qgis_as_terra(output_raster)

# Same holds for coercion to SpatVector
result2 <- qgis_run_algorithm(
  "native:buffer",
  INPUT = system.file("longlake/longlake.gpkg", package = "qgisprocess"),
  DISTANCE = 100
)

qgis_as_terra(result2)
output_vector <- qgis_extract_output(result2, "OUTPUT")
qgis_as_terra(output_vector)

# SpatVectorProxy:
qgis_as_terra(result2, proxy = TRUE)
}
\dontshow{\}) # examplesIf}
}
\seealso{
Other topics about coercing processing output: 
\code{\link{qgis_as_raster}()},
\code{\link{st_as_sf}},
\code{\link{st_as_stars}}

Other topics about accessing or managing processing results: 
\code{\link{qgis_as_raster}()},
\code{\link{qgis_clean_result}()},
\code{\link{qgis_extract_output}()},
\code{\link{qgis_result_status}()},
\code{\link{st_as_sf}},
\code{\link{st_as_stars}}
}
\concept{topics about accessing or managing processing results}
\concept{topics about coercing processing output}

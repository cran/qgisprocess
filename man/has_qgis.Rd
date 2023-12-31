% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/qgis-has.R
\name{has_qgis}
\alias{has_qgis}
\alias{qgis_has_plugin}
\alias{qgis_has_provider}
\alias{qgis_has_algorithm}
\title{Check availability of QGIS, a plugin, a provider or an algorithm}
\usage{
has_qgis()

qgis_has_plugin(plugin, query = FALSE, quiet = TRUE)

qgis_has_provider(provider, query = FALSE, quiet = TRUE)

qgis_has_algorithm(algorithm, query = FALSE, quiet = TRUE)
}
\arguments{
\item{plugin}{A plugin name (e.g., \code{"native"}).
Can be a vector of names.}

\item{query}{Use \code{TRUE} to refresh the cached value.}

\item{quiet}{Use \code{FALSE} to display more information,
possibly useful for debugging.}

\item{provider}{A provider name (e.g., \code{"native"}).
Can be a vector of names.}

\item{algorithm}{A qualified algorithm name
(e.g., \code{"native:buffer"}).
Can be a vector of names.}
}
\value{
A logical, with length 1 in case of \code{has_qgis()}.
}
\description{
\code{has_qgis()} checks whether the loaded qgisprocess cache is populated,
which means that a QGIS installation was accessible and responsive when
loading the package.
\code{qgis_has_plugin()}, \code{qgis_has_provider()} and \code{qgis_has_algorithm()} check
for the availability of one or several plugins, processing providers and
algorithms, respectively.
They are vectorized.
}
\note{
Only plugins that implement processing providers are supported.
}
\examples{
has_qgis()
if (has_qgis()) qgis_has_algorithm("native:filedownloader")
if (has_qgis()) qgis_has_provider("native")
if (has_qgis()) qgis_has_plugin(c("grassprovider", "processing_saga_nextgen"))

}
\seealso{
Other topics about reporting the QGIS state: 
\code{\link{qgis_algorithms}()},
\code{\link{qgis_path}()},
\code{\link{qgis_using_json_input}()}
}
\concept{functions to manage and explore QGIS and qgisprocess}
\concept{topics about reporting the QGIS state}

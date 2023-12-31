% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/qgis-run.R
\name{qgis_run}
\alias{qgis_run}
\title{Call the 'qgis_process' command directly}
\usage{
qgis_run(args = character(), ..., env = qgis_env(), path = qgis_path())
}
\arguments{
\item{args}{Command-line arguments}

\item{...}{Passed to \code{\link[processx:run]{processx::run()}}.}

\item{env}{A \code{\link[=list]{list()}} of environment variables.
Defaults to
\code{getOption("qgisprocess.env", list(QT_QPA_PLATFORM = "offscreen"))}.}

\item{path}{A path to the 'qgis_process' executable. Defaults to
\code{\link[=qgis_path]{qgis_path()}}.}
}
\value{
A \code{\link[processx:run]{processx::run()}} return value, i.e. a list with \code{status}, \code{stdout},
\code{stderr} and \code{timeout} elements.
}
\description{
\code{qgis_run()} offers full access to 'qgis_process'.
Run \code{cat(qgis_run("--help")$stdout)} to get the command's help.
}
\examples{
\dontshow{if (has_qgis()) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
processx_list <- qgis_run(args = "--help")
cat(processx_list$stdout)
\dontshow{\}) # examplesIf}
}
\seealso{
Other topics about programming or debugging utilities: 
\code{\link{qgis_result_status}()},
\code{\link{qgis_tmp_file}()},
\code{\link{qgis_unconfigure}()},
\code{\link{qgis_using_json_input}()}

Other topics about configuring QGIS and qgisprocess: 
\code{\link{qgis_configure}()},
\code{\link{qgis_enable_plugins}()}
}
\concept{topics about configuring QGIS and qgisprocess}
\concept{topics about programming or debugging utilities}

## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
can_build <- qgisprocess::has_qgis() &&
  all(qgisprocess::qgis_has_plugin(c(
    "grassprovider",
    "processing_saga_nextgen"
  ))) &&
  requireNamespace("spDataLarge", quietly = TRUE) &&
  requireNamespace("sf", quietly = TRUE) &&
  requireNamespace("terra", quietly = TRUE) &&
  requireNamespace("mapview", quietly = TRUE)

## -----------------------------------------------------------------------------
library("qgisprocess")

## ----config-------------------------------------------------------------------
qgis_configure(use_cached_data = TRUE)

## ----win-config, eval=FALSE---------------------------------------------------
#  # specify path to QGIS installation on Windows
#  options(qgisprocess.path = "C:/Program Files/QGIS 3.28/bin/qgis_process-qgis.bat")
#  # or use the QGIS nightly version (if installed via OSGeo4W)
#  # options(qgisprocess.path = "C:/OSGeo4W64/bin/qgis_process-qgis-dev.bat")
#  qgis_configure() # or use library(qgisprocess) if package was not loaded yet

## ----vers---------------------------------------------------------------------
qgis_version()

## ----plugins------------------------------------------------------------------
qgis_plugins()

## ----enable-plugins, message=FALSE--------------------------------------------
qgis_enable_plugins(c("grassprovider", "processing_saga_nextgen"))

## ----providers----------------------------------------------------------------
qgis_providers()

## ----algs---------------------------------------------------------------------
algs <- qgis_algorithms()
algs

## ----help, eval=FALSE---------------------------------------------------------
#  qgis_show_help("native:buffer")
#  ## Buffer (native:buffer)
#  ##
#  ## ----------------
#  ## Description
#  ## ----------------
#  ## This algorithm computes a buffer area for all the features in an input layer, using a fixed or dynamic distance.
#  ##
#  ## The segments parameter controls the number of line segments to use to approximate a quarter circle when creating rounded offsets.
#  ##
#  ##...

## ----args-buffer--------------------------------------------------------------
qgis_get_argument_specs("native:buffer")

## ----buffer-------------------------------------------------------------------
# if needed, first install spDataLarge:
# remotes::install_github("Nowosad/spDataLarge")
data("random_points", package = "spDataLarge")
result <- qgis_run_algorithm("native:buffer", INPUT = random_points, DISTANCE = 50)

## ----inspect------------------------------------------------------------------
# inspect the result object
class(result)
names(result)
result # only prints the output element(s)

## ----plot-buffer, message=FALSE-----------------------------------------------
library("sf")
library("mapview")
# attach QGIS output
# either do it "manually":
buf <- read_sf(qgis_extract_output(result, "OUTPUT"))
# or use the st_as_sf.qgis_result method:
buf <- sf::st_as_sf(result)
# plot your result
mapview(buf, col.regions = "blue") + 
  mapview(random_points, col.regions = "red", cex = 3)

## ----function-creation, eval=FALSE--------------------------------------------
#  # create a function
#  qgis_buffer <- qgis_function("native:buffer")
#  # run the function
#  result <- qgis_buffer(INPUT = random_points, DISTANCE = 50)

## ----desc---------------------------------------------------------------------
qgis_get_description("grass7:r.slope.aspect")

## ----args---------------------------------------------------------------------
qgis_get_argument_specs("grass7:r.slope.aspect")

## ----outputs------------------------------------------------------------------
qgis_get_output_specs("grass7:r.slope.aspect")

## ----slopeaspect, message=FALSE-----------------------------------------------
library("terra")
# attach digital elevation model from Mt. Mongón (Peru)
dem <- rast(system.file("raster/dem.tif", package = "spDataLarge"))
# if not already done, enable the grass plugin
# qgis_enable_plugins("grassprovider")
info <- qgis_run_algorithm(alg = "grass7:r.slope.aspect", elevation = dem)

## ----info---------------------------------------------------------------------
info

## ----combine1, message=FALSE--------------------------------------------------
# just keep the names of output rasters
nms <- qgis_get_output_specs("grass7:r.slope.aspect")$name
# read in the output rasters 
r <- info[nms] |>
  unlist() |>
  rast() |>
  as.numeric()
names(r) <- nms
# plot the output
plot(r)

## ----combine2, message=FALSE, eval=FALSE--------------------------------------
#  r <- lapply(info[nms], \(x) as.numeric(qgis_as_terra(x))) |>
#    rast()

## ----addrastertopoints-args---------------------------------------------------
qgis_get_argument_specs("sagang:addrastervaluestopoints")

## ----multilayer-repeat--------------------------------------------------------
rp_tp <- qgis_run_algorithm(
  "sagang:addrastervaluestopoints",
  SHAPES = random_points,
  GRIDS = qgis_extract_output(info, "aspect"),
  GRIDS = qgis_extract_output(info, "slope"),
  GRIDS = qgis_extract_output(info, "tcurvature"),
  RESAMPLING = 0)

## ----multilayer-list, eval=FALSE----------------------------------------------
#  rp_tp <- qgis_run_algorithm(
#    "sagang:addrastervaluestopoints",
#    SHAPES = random_points,
#    GRIDS = qgis_list_input(
#      qgis_extract_output(info, "aspect"),
#      qgis_extract_output(info, "slope"),
#      qgis_extract_output(info, "tcurvature")
#    ),
#    RESAMPLING = 0)

## ----multilayer-output--------------------------------------------------------
sf::st_as_sf(rp_tp)

## ----buf-pipe-----------------------------------------------------------------
system.file("longlake/longlake_depth.gpkg", package = "qgisprocess") |>
  qgis_run_algorithm_p("native:buffer", DISTANCE = 50)

## ----qgis-pipe----------------------------------------------------------------
dem <- system.file("raster/dem.tif", package = "spDataLarge")
# in case you need to enable the SAGA next generation algorithms, run the following line:
# qgis_enable_plugins("processing_saga_nextgen")

oldopt <- options(qgisprocess.tmp_raster_ext = ".sdat")
qgis_run_algorithm(algorithm = "sagang:sinkremoval", DEM = dem,
                   METHOD = 1) |>
  qgis_run_algorithm_p("sagang:sagawetnessindex", .select = "DEM_PREPROC")

## ----native pipe--------------------------------------------------------------
result <- qgis_run_algorithm(algorithm = "sagang:sinkremoval", DEM = dem, 
                         METHOD = 1) |>
  qgis_extract_output("DEM_PREPROC") |>
  qgis_run_algorithm(algorithm = "sagang:sagawetnessindex",
                     DEM = _)

# or using an anonymous function
# result <- qgis_run_algorithm(algorithm = "sagang:sinkremoval", DEM = dem, 
#                          METHOD = 1) |>
#   (\(x) qgis_run_algorithm(algorithm = "sagang:sagawetnessindex",
#                            DEM = x$DEM_PREPROC[1])) ()

# set the default output raster format to .tif again
options(oldopt)

## ----eval=!can_build, echo=FALSE, results="asis"------------------------------
#  cat("This vignette has been built in absence of a QGIS installation, with a missing QGIS plugin, or in absence of the spDataLarge, sf, terra or mapview package.\n\n")
#  cat("Read it online at <https://r-spatial.github.io/qgisprocess/articles/qgisprocess.html>.")


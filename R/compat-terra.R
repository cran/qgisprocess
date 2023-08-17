#' Convert a qgis_result object or one of its elements to a terra object
#'
#' @family topics about coercing processing output
#' @family topics about accessing or managing processing results
#'
#' @param ... Arguments passed to [terra::rast()].
#' @inheritParams qgis_as_raster
#'
#' @returns A `SpatRaster` or a `SpatVector` object.
#'
#' @examplesIf has_qgis() && requireNamespace("terra", quietly = TRUE)
#' \donttest{
#' # not running below examples in R CMD check to save time
#' result <- qgis_run_algorithm(
#'   "native:slope",
#'   INPUT = system.file("longlake/longlake_depth.tif", package = "qgisprocess")
#' )
#'
#' # most direct approach, autoselecting a `qgis_outputRaster` type
#' # output from the `result` object and reading as SpatRaster:
#' qgis_as_terra(result)
#'
#' # if you need more control, extract the needed output element first:
#' output_raster <- qgis_extract_output(result, "OUTPUT")
#' qgis_as_terra(output_raster)
#' }
#'
#' @name qgis_as_terra

#' @rdname qgis_as_terra
#' @export
qgis_as_terra <- function(x, ...) {
  UseMethod("qgis_as_terra")
}

#' @rdname qgis_as_terra
#' @export
qgis_as_terra.qgis_outputRaster <- function(x, ...) {
  terra::rast(unclass(x), ...)
}

#' @rdname qgis_as_terra
#' @export
qgis_as_terra.qgis_outputLayer <- function(x, ...) {
  terra::rast(unclass(x), ...)
}

#' @rdname qgis_as_terra
#' @export
qgis_as_terra.qgis_result <- function(x, ...) {
  result <- qgis_extract_output_by_class(x, c("qgis_outputRaster", "qgis_outputLayer"))
  terra::rast(unclass(result), ...)
}

# @param x A [terra::rast()].
#' @keywords internal
#' @export
as_qgis_argument.SpatRaster <- function(x, spec = qgis_argument_spec(),
                                        use_json_input = FALSE) {
  as_qgis_argument_terra(x, spec, use_json_input)
}

#' @keywords internal
as_qgis_argument_terra <- function(x, spec = qgis_argument_spec(),
                                   use_json_input = FALSE) {
  if (!isTRUE(spec$qgis_type %in% c("raster", "layer", "multilayer"))) {
    abort(glue("Can't convert '{ class(x)[1] }' object to QGIS type '{ spec$qgis_type }'"))
  }

  if (terra::nlyr(x) > 1L && spec$qgis_type == "multilayer") {
    warning("You passed a multiband SpatRaster object as one of the layers for a multilayer argument.\n",
      "It is expected that only the first band will be used by QGIS!\n",
      "If you need each band to be processed, you need to extract the bands and pass them as ",
      "separate layers to the algorithm (either by repeating the argument, or by wrapping ",
      "in qgis_list_input()).",
      call. = FALSE
    )
  }

  # try to use a filename if present (behaviour changed around terra 1.5.12)
  sources <- terra::sources(x)
  if (!is.character(sources)) {
    sources <- sources$source
  }

  if (!identical(sources, "") && length(sources) == 1) {
    accepted_ext <- c("grd", "asc", "sdat", "rst", "nc", "tif", "tiff", "gtiff", "envi", "bil", "img")
    file_ext <- stringr::str_to_lower(tools::file_ext(sources))
    if (file_ext %in% accepted_ext) {
      names_match <- identical(names(x), names(terra::rast(sources)))
      if (names_match) {
        return(sources)
      } else if (terra::nlyr(x) > 1L) {
        message(glue(
          "Rewriting the multi-band SpatRaster object as a temporary file before passing to QGIS, since ",
          "its bands (names, order, selection) differ from those in the source file '{ sources }'."
        ))
      } else {
        message(glue(
          "Rewriting the '{ names(x) }' band of '{ sources }' as a temporary file, otherwise ",
          "QGIS may use another or all bands of the source file if ",
          "passing its filepath."
        ))
      }
    }
  }

  path <- qgis_tmp_raster()
  terra::writeRaster(x, path)
  structure(path, class = "qgis_tempfile_arg")
}

#' @keywords internal
#' @export
as_qgis_argument.SpatExtent <- function(x, spec = qgis_argument_spec(),
                                        use_json_input = FALSE) {
  if (!isTRUE(spec$qgis_type %in% c("extent"))) {
    abort(glue("Can't convert 'SpatExtent' object to QGIS type '{ spec$qgis_type }'"))
  }

  ex <- as.vector(terra::ext(x))

  glue("{ex[['xmin']]},{ex[['xmax']]},{ex[['ymin']]},{ex[['ymax']]}")
}
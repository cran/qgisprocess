#' Detect QGIS installations with 'qgis_process' on Windows and macOS
#'
#' Discovers existing 'qgis_process' executables on the system and returns their
#' filepath.
#' Only available for Windows and macOS systems.
#' `qgis_detect_paths()` is a shortcut to `qgis_detect_windows_paths()` on
#' Windows and `qgis_detect_macos_paths()` on macOS.
#'
#' @concept functions to manage and explore QGIS and qgisprocess
#'
#' @seealso [qgis_configure()], [qgis_path()]
#'
#' @note
#' These functions do not verify whether the discovered 'qgis_process'
#' executables successfully run.
#' You can run `qgis_path(query = TRUE, quiet = FALSE)` to discover and cache
#' the first 'qgis_process' in the list that works.
#'
#' @param drive_letter The drive letter on which to search. By default,
#'   this is the same drive letter as the R executable.
#'   Only applicable to Windows.
#'
#' @returns A character vector of possible paths to the 'qgis_process'
#' executable.
#' @export
#'
#' @examples
#' if (.Platform$OS.type == "windows") {
#'   qgis_detect_paths()
#'   identical(qgis_detect_windows_paths(), qgis_detect_paths())
#' }
#' if (Sys.info()["sysname"] == "Darwin") {
#'   qgis_detect_paths()
#'   identical(qgis_detect_macos_paths(), qgis_detect_paths())
#' }
qgis_detect_paths <- function(drive_letter = strsplit(R.home(), ":")[[1]][1]) {
  if (is_windows()) {
    qgis_detect_windows_paths(drive_letter = drive_letter)
  } else if (is_macos()) {
    qgis_detect_macos_paths()
  } else {
    abort("Can use `qgis_detect_paths()` on Windows and macOS only.")
  }
}

#' @rdname qgis_detect_paths
#' @export
qgis_detect_windows_paths <- function(drive_letter = strsplit(R.home(), ":")[[1]][1]) {
  if (!is_windows()) {
    abort("Can't use `qgis_detect_windows_paths()` on a non-windows platform.")
  }

  bat_files <- c(
    "qgis_process-qgis.bat",
    "qgis_process-qgis-ltr.bat",
    "qgis_process-qgis-dev.bat"
  )

  posssible_locs_win_df <- expand.grid(
    qgis = c(
      list.files(glue("{ drive_letter }:/Program Files"), "QGIS*", full.names = TRUE),
      file.path(glue("{ drive_letter }:"), "OSGeo4W64"),
      file.path(glue("{ drive_letter }:"), "OSGeo4W")
    ),
    file = file.path("bin", bat_files)
  )

  possible_locs_win <- file.path(posssible_locs_win_df$qgis, posssible_locs_win_df$file)
  possible_locs_win <- possible_locs_win[file.exists(possible_locs_win)]
  sort_paths(possible_locs_win)
}

#' @rdname qgis_detect_paths
#' @export
qgis_detect_macos_paths <- function() {
  if (!is_macos()) {
    abort("Can't use `qgis_detect_macos_paths()` on a non-MacOS platform.")
  }

  possible_locs_mac <- file.path(
    list.files("/Applications", "QGIS*", full.names = TRUE),
    "Contents/MacOS/bin/qgis_process"
  )

  possible_locs_mac <- possible_locs_mac[file.exists(possible_locs_mac)]
  sort_paths(possible_locs_mac)
}

#' @keywords internal
is_macos <- function() {
  (.Platform$OS.type == "unix") &&
    identical(unname(Sys.info()["sysname"]), "Darwin")
}

#' @keywords internal
is_windows <- function() {
  .Platform$OS.type == "windows"
}

#' @keywords internal
sort_paths <- function(x) {
  assert_that(is.character(x))
  extracted <- extract_version_from_paths(x)
  indexes_version <- order(
    as.package_version(extracted[!is.na(extracted)]),
    decreasing = TRUE
  )
  indexes <- c(
    which(!is.na(extracted))[indexes_version],
    which(is.na(extracted))
  )
  x[indexes]
}

#' @keywords internal
extract_version_from_paths <- function(x) {
  stringr::str_extract(x, "\\d{1,2}\\.\\d+(?:\\.\\d+)?(?=/)")
}

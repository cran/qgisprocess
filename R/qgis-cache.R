#' @keywords internal
qgis_cache_dir <- function() {
  normalizePath(rappdirs::user_cache_dir("R-qgisprocess"), mustWork = FALSE)
}

#' @keywords internal
qgis_pkgcache_file <- function() {
  version <- as.character(utils::packageVersion("qgisprocess"))
  cache_path <- file.path(
    qgis_cache_dir(),
    glue("cache-{version}.rds")
  )
}

#' Delete old cache files
#'
#' @details
#' Note that a currently used package cache file will never be deleted.
#'
#' This function is called when loading the package.
#'
#' @param type A string; either `"all"`, `"package"` or `"help"`.
#' This selects the type of cache files to delete.
#' @param age_days A number that expresses a cache file's age that must
#' be exceeded for it to be deleted, with age defined as days elapsed since the
#' file's last modification date.
#' The default value of 90 days can also be changed with the option
#' `qgisprocess.cachefiles_days_keep` or the  environment variable
#' `R_QGISPROCESS_CACHEFILES_DAYS_KEEP`.
#' @param startup Logical.
#' Is this command being run while loading the package?
#' @inheritParams qgis_path
#'
#' @note
#' This is an internal function.
#'
#' @keywords internal
qgis_delete_old_cachefiles <- function(
    type = "all",
    age_days = NULL,
    quiet = FALSE,
    startup = FALSE) {
  if (!dir.exists(qgis_cache_dir())) {
    if (!quiet) {
      msg <- "Tried to purge old cache files, but no cache directory available."
      if (!startup) message(msg) else packageStartupMessage("  \U2139 ", msg)
    }
    return(invisible(NULL))
  }

  if (is.null(age_days)) {
    opt <- getOption(
      "qgisprocess.cachefiles_days_keep",
      Sys.getenv("R_QGISPROCESS_CACHEFILES_DAYS_KEEP")
    )
    if (opt == "") opt <- 90L
    age_days <- as.integer(opt)
  }
  files <- tibble::tibble(name = list.files(
    qgis_cache_dir(),
    full.names = TRUE
  ))
  today <- Sys.Date()
  files$age <- today - as.Date(file.info(files$name)$mtime)
  files$package_cache <- grepl("cache-", files$name)

  if (type == "all") {
    files_to_delete <- files[files$age > age_days, ]
  } else if (type == "package") {
    files_to_delete <- files[files$age > age_days & files$package_cache, ]
  } else if (type == "help") {
    files_to_delete <- files[files$age > age_days & !files$package_cache, ]
  }


  # Don't delete current package cache file (regardless of age)
  files_to_delete <- files_to_delete[files_to_delete$name != qgis_pkgcache_file(), ]

  if (nrow(files_to_delete) == 0L) {
    if (!quiet && !startup) {
      message(
        glue("No purging done: no cache files older than {age_days} days.")
      )
    }
    return(invisible(NULL))
  }

  success <- FALSE
  tryCatch(
    {
      unlink(files_to_delete$name)
      success <- TRUE
    },
    error = function(e) {
      message(glue(
        "Cache files older than {age_days} days could not be deleted. ",
        "Error message was:\n\n{e}\n",
        ifelse("stderr" %in% names(e) && nchar(e$stderr) > 0, e$stderr, "")
      ))
    }
  )
  if (success && !quiet) {
    msg <- glue(
      "Deleted { nrow(files_to_delete) } cache file",
      "{ ifelse(nrow(files_to_delete) > 1, 's', '') }",
      " older than { age_days } days ",
      "(pkgcaches: { sum(files_to_delete$package_cache) } | ",
      "helpfiles: { sum(!files_to_delete$package_cache) })."
    )
    if (!startup) message(msg) else packageStartupMessage("  \U2139 ", msg)
  }
  return(invisible(NULL))
}

# environment for cache
qgisprocess_cache <- new.env(parent = emptyenv())
qgisprocess_cache$path <- NULL
qgisprocess_cache$version <- NULL
qgisprocess_cache$algorithms <- NULL
qgisprocess_cache$plugins <- NULL
qgisprocess_cache$use_json_output <- NULL
qgisprocess_cache$loaded_from <- NULL

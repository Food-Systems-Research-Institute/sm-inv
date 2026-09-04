#' Add a Magic Number
#'
#' @description Add a single value with an optional description to a
#' running named list, using the variable name passed as `val` as the
#' record name. Use with [save_magic()].
#' e.g. `add_magic(n_indicators, "Total indicators")`
#'
#' @param val value to save; its variable name is used as the record name
#' @param desc optional str description of the value
#' @param list_name str name of the list to update in env
#'
#' @return side effect only: updates `list_name` in the calling environment
#' @export
add_magic <- function(val, desc = NULL, list_name = "magic") {
  name <- deparse(substitute(val))
  record <- if (is.null(desc)) val else list(value = val, description = desc)

  env <- parent.frame()

  if (!exists(list_name, envir = env, inherits = FALSE)) {
    assign(list_name, list(), envir = env)
  }

  current <- get(list_name, envir = env)
  current[[name]] <- record
  assign(list_name, current, envir = env)

  invisible(record)
}

#' Save Magic
#'
#' @description Save one or more named values to `.yaml` for specific task.
#' File will be collected later using [create_magic_sty_file()].
#'
#' @param values named list, created with [add_magic()].
#' @param file str path to yaml file
#'
#' @return side effect only: saves `.yaml` file
#' @importFrom yaml write_yaml
#' @export
save_magic <- function(values, file) {
  if (is.null(names(values)) || any(names(values) == "")) {
    stop("`values` must be a named list")
  }

  dir.create(
    dirname(file),
    recursive = TRUE,
    showWarnings = FALSE
  )

  yaml::write_yaml(values, file)
}

#' Create Magic Sty File
#'
#' @description Turn one or more `.yaml` files into a single `magic_numbers.sty`
#' file for use with latex.
#'
#' @param input_files string path(s) of yaml files to combine
#' @param output_file str path to output `.sty` file
#'
#' @return side effect only: save yaml file
#' @importFrom yaml read_yaml
#' @export
create_magic_sty_file <- function(
  input_files,
  output_file
) {
  # Read all YAML files
  all_values <- lapply(input_files, yaml::read_yaml)

  # Combine them
  values <- unlist(all_values, recursive = FALSE)

  # Check for duplicate names
  all_names <- unlist(lapply(all_values, names))

  if (anyDuplicated(all_names)) {
    dupes <- unique(all_names[duplicated(all_names)])
    stop(
      "Duplicate paper value(s): ",
      paste(dupes, collapse = ", ")
    )
  }

  # Generate .sty
  lines <- c(
    "\\ProvidesPackage{magic_numbers}",
    ""
  )

  for (name in names(values)) {
    record <- values[[name]]

    if (is.list(record) && !is.null(record[["value"]])) {
      description <- record[["description"]]
      value <- as.character(record[["value"]])
    } else {
      description <- NULL
      value <- as.character(record)
    }

    # Escape LaTeX special characters
    value <- gsub("\\\\", "\\\\textbackslash{}", value)
    value <- gsub("%", "\\\\%", value, fixed = TRUE)
    value <- gsub("&", "\\\\&", value, fixed = TRUE)
    value <- gsub("_", "\\\\_", value, fixed = TRUE)
    value <- gsub("#", "\\\\#", value, fixed = TRUE)

    if (!is.null(description)) {
      lines <- c(lines, sprintf("%% %s", description))
    }

    lines <- c(
      lines,
      sprintf("\\newcommand{\\%s}{%s}", name, value)
    )
  }

  dir.create(dirname(output_file), recursive = TRUE, showWarnings = FALSE)

  writeLines(lines, output_file)
}

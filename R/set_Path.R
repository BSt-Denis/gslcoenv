#' @title Set the path to the folder where the data are stored
#'
#' @description Modifies the default path of the data folder in the
#' pkg_params.rdata file.
#'
#' @param path_to_data Path to the default data folder
#'
#' @export
#'
#' @examples
#' \dontrun{setDataPath("/home/bruno/workspace/Data/GSL-grid/")}
#'
setDataPath <- function(path_to_data){
  # Set a variable for path to parameters files
  params_path <- system.file("extdata", "pkg_params.rdata", package = "gslcoenv")

  # Import parameters as list
  params <- rlist::list.load(params_path)

  # Set the new path to the data folder
  params$data_path <- path_to_data

  # Save the list to a rdata file
  rlist::list.save(params,params_path)

  # Print new path name
  print(paste0("Default data folder change to :",path_to_data))
}


#' @title Set the path to the folder where the polygons are stored
#'
#' @description Modifies the default path of the polygon folder in the
#' pkg_params.rdata file.
#'
#' @param path_to_poly Path to the default polygon folder
#'
#' @export
#'
#' @examples
#' \dontrun{setPolyPath("/home/bruno/workspace/Data/Polygon/")}
setPolyPath <- function(path_to_poly){
  # Set a variable for path to parameters files
  params_path <- system.file("extdata", "pkg_params.rdata", package = "gslcoenv")

  # Import parameters as list
  params <- rlist::list.load(params_path)

  # Set the new path to the polygon folder
  params$poly_path <- path_to_poly

  # Save the list to a rdata file
  rlist::list.save(params,params_path)

  # Print new path name
  print(paste0("Default polygon folder change to :",path_to_poly))

}

#' @title Set the default path to get the environmental data
#'
#' @description Tell this package where to find the environmental data.
#'
#' @param path_to_data Path to the default data folder, Windows (\\) or Linux (/)
#' path style are supported even for Windows architecture, see example.
#' if NA, the default path is displayed.
#'
#' @export
#'
#' @examples
#' \dontrun{setDataPath("C:/Users/stdenisb/Documents/Coding/data/gslcoenv_data/")}
#'

setDataPath <- function(path_to_data=NULL){
  # Get path to parameters file
  parameter_file <- system.file("extdata", "pkg_parameters.yaml", package = "gslcoenv")

  #Get list of parameters
  parameters <- yaml::read_yaml(parameter_file)

  # Return default data path if arguments is NA
  if(is.null(path_to_data)){
    cat("Data folder : ",parameters$data_path)
  }

  else{
    # Check if the path ends with a closing string (\\) for Windows style, or (/) for Linux style path
    if(substring(path_to_data,nchar(path_to_data)) != "\\" & substring(path_to_data,nchar(path_to_data)) != "/"){
      # Check if path is Windows style and close the path with double backslash
      if(grepl("\\\\", path_to_data)){
        path_to_data <- paste0(path_to_data,"\\")
      }
      # Assume path is Linux style and close it with forward slash
      else{
        path_to_data <- paste0(path_to_data,"/")
      }
    }

    # Overwrite the old path with new path in the parameters file
    parameters$data_path <- path_to_data
    yaml::write_yaml(parameters,parameter_file)

    # Print new path name
    cat("New data folder : ",path_to_data)
  }
}


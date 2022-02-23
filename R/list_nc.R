#' @title List the variables in the data folder
#'
#' @description List the variables in the default data folder set by
#' \code{\link{setDataPath}} or information about a specified variable
#' available in the default data folder.
#'
#' @param varname Variable to extract information about. Default = NA. If NA,
#' it print the available variable to be read by \code{\link{read_nc}}.
#' If varname is type character, information about the variable is print from
#' the associated netcdf file global attributes.
#'
#' @export

list_nc <- function(varname = NA){
  # Get path to parameters file
  param_path <- system.file("extdata", "pkg_params.rdata", package = "gslcoenv")

  # Get path to data folder
  data_path <- rlist::list.load(param_path)$data_path

  # Get the file name present in data folder
  flist <- list.files(data_path, pattern = "\\.nc$")

  # Stop function if no file is found
  if(length(flist) == 0){
    stop(paste0("No netCDF file in directory : ",data_path))
  }

  if(is.na(varname)){
    # List name of the available variables
    for (varname in gsub(".nc","",flist)){
      print(varname)
    }
  }

  else{
    ncdf4::nc_open(paste0(data_path,varname,".nc"))
  }
}

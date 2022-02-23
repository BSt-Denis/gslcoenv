#' @title Load variable to a var_list
#'
#' @description Function returning data as a list from saved file created
#'  by \code{\link{save_var}}
#'
#' @param loadpath Path to the file containing the data to load.
#'
#' @return variable data as a list containing the data, shape, dimensions
#'  (longitude ,latitude ,time) and units.
#'
#' @export
#'
#' @examples
#' \dontrun{data <- load_var("/home/bruno/workspace/Data/test/saved_data.rdata")}
#'
load_var <- function(loadpath){

  # Rdata
  if(tools::file_ext(loadpath) == "rdata"){
    # Load data into list
    var_list <- rlist::list.load(loadpath)

  # NetCDF
  } else if(tools::file_ext(loadpath) == "nc"){

    # Create empty list to fill
    var_list <- list()
    dim_vec <- vector()

    # Open file
    nc <- ncdf4::nc_open(loadpath, write=FALSE)

    # Get variable names from netCDF file
    nc_variable = names(nc$var)

    # Get the main variable name by exclusion
    main_var <- setdiff(nc_variable,c("longitude","latitude","time"))

    # Add main variable to variable list
    var_list[["name"]] <- main_var
    var_list[["data"]] <- ncdf4::ncvar_get(nc,varid = main_var)

    # Add dimensions and coordinates
    # Longitude
    if("longitude" %in% nc_variable){
      var_list[["longitude"]] <- ncdf4::ncvar_get(nc,'longitude')
      dim_vec <- append(dim_vec,"longitude")
    }

    # Latitude
    if("latitude" %in% nc_variable){
      var_list[["latitude"]] <- ncdf4::ncvar_get(nc,'latitude')
      dim_vec <- append(dim_vec,"latitude")
    }

    # Time
    if("time" %in% names(nc$dim)){
      var_list[["time"]] <- lubridate::as_date(ncdf4::ncvar_get(nc,'time')/86400,
                                               origin = lubridate::origin)
      dim_vec <- append(dim_vec,"time")
    }

    # Add shape
    var_list[["shape"]] <- dim(var_list$data)

    # Add dims
    var_list[["dims"]] <- dim_vec

    # Add units
    var_list[["units"]] <- ncdf4::ncatt_get(nc, main_var, attname="units")$value

    # Close file
    ncdf4::nc_close(nc)

  # Unrecognise file extension
  } else{print("File extension not recognise, it must be '.rdata' or '.nc'")}

  # Return variable data
  return(var_list)
}

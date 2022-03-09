#' @title Save variable in a local file
#'
#' @description Function that save a variable list created by \code{\link{read_nc}} or
#' \code{\link{load_var}} in csv or nc format.
#'
#' @param var_list variable list created with this package
#' @param savepath Path to save the data. The format of the save file is
#' determined by the extension of this argument.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' save_var(var_list,"/home/bruno/test_data.nc"}
#'
save_var <- function(var_list, savepath){

  # Check if var_list is a list
  if (!is.list(var_list)) {
    stop("var_list argument must be a list. typeof(var_list) == list")
  }

  # Save
  # Rdata
  if(tools::file_ext(savepath) == "rdata"){
    rlist::list.save(var_list, savepath)
  }
  # NetCDF
  else if(tools::file_ext(savepath) == "nc"){

    # Create NetCDF dimensions list
    nc_dim_list = list()
    nc_var_list = list()

    # Spatial Dimensions
    if("latitude" %in% names(var_list) & "longitude" %in% names(var_list)){
      x <- ncdf4::ncdim_def( "x", "index", as.integer(1:length(var_list$longitude[,1])))
      y <- ncdf4::ncdim_def( "y", "index", as.integer(1:length(var_list$longitude[1,])))

      # Spatial coordinates
      longitude <- ncdf4::ncvar_def("longitude", "degree_east",  list(x,y), NA)
      latitude <- ncdf4::ncvar_def("latitude", "degree_north",  list(x,y), NA)
      nc_dim_list = append(nc_dim_list,c(list(x),list(y)))
      nc_var_list = append(nc_var_list,c(list(longitude),list(latitude)))
    }

    # Time coordinates
    if("time" %in% names(var_list)){
      t <- ncdf4::ncdim_def( "time", "seconds since 1970-01-01", as.numeric(var_list$time)*86400, unlim=TRUE)
      nc_dim_list = append(nc_dim_list,list(t))
    }

    # Create variables
    for(varname in var_list$variables){
      var_id <- ncdf4::ncvar_def(varname,  var_list$units,  nc_dim_list, NA)
      nc_var_list = append(nc_var_list,list(var_id))
    }

    # Create new files
    ncnew <- ncdf4::nc_create(savepath, nc_var_list, force_v4 = TRUE)

    # Write Data to variables
    # Variables
    for(varname in var_list$variables){
      ncdf4::ncvar_put(ncnew, varname, var_list[[varname]])
    }

    # Time related global attributes
    if("time" %in% names(var_list)){
      ncdf4::ncatt_put(ncnew, 0, "time_coverage_start", strftime(min(var_list$time)))
      ncdf4::ncatt_put(ncnew, 0, "time_coverage_end", strftime(max(var_list$time)))
    }

    # Coordinates and coords global attributes
    if("latitude" %in% names(var_list) & "longitude" %in% names(var_list)){
    ncdf4::ncvar_put(ncnew, longitude, var_list$longitude)
    ncdf4::ncvar_put(ncnew, latitude, var_list$latitude)
    ncdf4::ncatt_put(ncnew, 0, "longitude_min", min(var_list$longitude))
    ncdf4::ncatt_put(ncnew, 0, "longitude_max", max(var_list$longitude))
    ncdf4::ncatt_put(ncnew, 0, "latitude_min", min(var_list$latitude))
    ncdf4::ncatt_put(ncnew, 0, "latitude_max", max(var_list$latitude))
    }

    # Write Global Attributes
    ncdf4::ncatt_put(ncnew, 0, "data_var", paste0(c(var_list$variables),collapse=","))
    ncdf4::ncatt_put(ncnew, 0, "original_nc_var", var_list$nc_var)
    ncdf4::ncatt_put(ncnew, 0, "creation_date", strftime(Sys.time()))
    ncdf4::ncatt_put(ncnew, 0, "created_by", "The gslcoenv R package")
    ncdf4::ncatt_put(ncnew, 0, "original_data", "Interpolated data by Peter Galbraith from PMZA monitoring missions and other scientific missions carried out by the DFO section of Quebec")

    # Close .nc file
    ncdf4::nc_close(ncnew)

  # Raise error in case of unrecognized saving format
  } else {
    stop("Save format unrecognize, only 'rdata' and 'nc' are implement at the moment ")
  }
  print("Data saved")
}

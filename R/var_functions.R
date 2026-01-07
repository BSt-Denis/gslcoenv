#===============================================================================
# info_var
#' @title info_var
#'
#' @description Print information about a variable list created by read_nc.
#' The variable name, shape, dimension names, units and memory used are printed.
#' This function is useful to quickly get information about a variable.
#'
#' @param var_list variable list created by this package
#'
#' @return The output from \code{\link{print}}
#' @export
#'
#' @examples
#' \dontrun{var_info(my_environemental_data_list)}
info_var <- function(var_list) {
  # Check if ls is a list
  if (!is.list(var_list)) {
    stop("var_list argument must be a list. typeof(var_list) == list")
  }
  # Print information extracted from variable list ls.
  cat("Variables = ",paste(var_list$variables,collapse=", "),"\n")
  cat("Shape = ",paste(var_list$shape,collapse=", "),"\n")
  cat("Dimensions = ",paste(var_list$dims,collapse=", "),"\n")
  cat("Units = ",var_list$units,"\n")
  cat("Memory size = ",format(utils::object.size(var_list), units = 'auto'),"\n")
  cat("NetCDF variable name = ",var_list$nc_var,"\n")

}

#===============================================================================
# load_var
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

    # Get the main variable name by excluding dimensions and coordinates names
    var_list[["variables"]] <- setdiff(nc_variable,c("longitude","latitude","time"))

    # Add main variable to variable list
    for(varname in var_list$variables){
      var_list[[varname]] <- ncdf4::ncvar_get(nc,varid = varname)
    }
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
    var_list[["shape"]] <- dim(var_list[[varname]])

    # Add dims
    var_list[["dims"]] <- dim_vec

    # Add units
    var_list[["units"]] <- ncdf4::ncatt_get(nc, var_list$variables[1], attname="units")$value

    # Add original netcdf variable name
    var_list[["nc_var"]] <- ncdf4::ncatt_get(nc, 0, attname="original_nc_var")$value

    # Close file
    ncdf4::nc_close(nc)

    # Unrecognise file extension
  } else{print("File extension not recognise, it must be '.rdata' or '.nc'")}

  # Return variable data
  return(var_list)
}

#===============================================================================
# save_var
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

#===============================================================================
# bymonth_var
#' @title Slice data from a variable list according to specified months
#'
#' @description Extract data from a var_list by specifying which month the data
#' should contain.
#'
#' @param var_list var_list created or loaded by this package
#' @param month_num Numeric number of the month (11 = november). Either numeric
#' or vector of numeric elements
#'
#' @return var_list containing data of the specified month
#'
#' @export
#'
#' @examples \dontrun{temp_june <- bymonth_var(total_temp,6)
#' temp_june_august <- bymonth_var(total_temp,c(06,08))}
#'
bymonth_var <- function(var_list, month_num){

  #Check if time is in the var_list
  stopifnot("time" %in% names(var_list), is.numeric(month_num))

  # Extract month from date time
  monthNum = lubridate::month(var_list$time)

  # Get valid date index
  valid_date_id = which(monthNum %in% month_num)

  # Get valid time values
  var_list$time = var_list$time[valid_date_id]

  if("longitude" %in% var_list[["dims"]] & "latitude" %in% var_list[["dims"]]){
    for (varname in var_list[["variables"]]){
      var_list[[varname]] = var_list[[varname]][,,valid_date_id]
    }
    var_list$shape = dim(var_list[[var_list$variables[1]]])

  } else {
    for (varname in var_list[["variables"]]){
      var_list[[varname]] = var_list[[varname]][valid_date_id]
    }
    var_list$shape = length(var_list[[var_list$variables[1]]])
  }

  return(var_list)
}

#' #===============================================================================
#' # substitute_var
#' #' @title Replace value of element by a choosen one
#' #'
#' #' @description Substitute certain element of the data by a choosen value.
#' #' This can be useful to replace the 0 in certain environment variable by a NA.
#' #'
#' #' @param var_list var_list created or loaded by this package
#' #' @param old_value
#' #' @param new_value
#' #'
#' #' @return substitute_var_list , new var_list with the element substituted
#' #'
#' #' @export
#' #'
#' #' @examples \dontrun{masked_var_list <- mask_var(var_list,0, NA)
#' #'
#' substitue_var <- function(var_list, old_value, new_value = NA){
#'   for (name in ds$variables){
#'     ds[name]
#'   }
#' }




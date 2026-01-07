# Slice a var_list to comprise data inside a given latitude and longitude range.
#
slice_xy <- function(vl, longitude, latitude){
  # Check for longitude and latitude coodinates, and dimensions of data
  stopifnot("longitude" %in% names(vl),"latitude" %in% names(vl))

  # Get index of valid coordinates
  valid_lon_id = which(dplyr::between(vl$longitude[,1], min(longitude), max(longitude)))
  valid_lat_id = which(dplyr::between(vl$latitude[1,], min(latitude), max(latitude)))

  # Slicing coordinates
  vl[["longitude"]] = vl$longitude[valid_lon_id,valid_lat_id]
  vl[["latitude"]] = vl$latitude[valid_lon_id,valid_lat_id]

  # Slicing the variables
  if(length(vl$shape) == 2){
    for(vars in vl$variables){
      vl[[vars]] = vl[[vars]][valid_lon_id,valid_lat_id]
    }
  } else {
    for(vars in vl$variables){
      vl[[vars]] = vl[[vars]][valid_lon_id,valid_lat_id,]
    }
  }

  # Updating var_list
  vl[["shape"]] = dim(vl[[vars]])

  return(vl)
}

#===============================================================================
# nc_datetime2R_datetime
#' Convert various time format from a NetCDF file to an R datetime
#'
#' This function is not exported.
#'
#' @param nc ncdf4 object
#' @return Numeric Second since epoch time 1970-01-01
#' @keywords internal
nc_datetime2R_datetime <- function(nc){
  # Get time values
  time_vals <- ncdf4::ncvar_get(nc, "time")

  # Read time attributes
  time_units <- ncdf4::ncatt_get(nc, "time", attname = "units")$value
  calendar <- ncdf4::ncatt_get(nc, "time", "calendar")$value

  #Find time step and origin
  time_step <- sub(" since.*", "", time_units)
  origin <- sub(".*since ", "", time_units)

  # Parse origin
  origin_date <- lubridate::ymd_hms(origin, tz = "UTC")

  #Determine multiplier based on time step
  multiplier <- switch(time_step,
                       "days" = 86400,
                       "hours" = 3600,
                       "seconds" = 1,
                       stop("Unsupported time unit: ", time_step))

  # Handle calendars
  if (calendar %in% c("gregorian", "standard", "proleptic_gregorian")) {
    dates <- origin_date + time_vals * multiplier
  } else if (calendar %in% c("noleap", "365_day")) {
    dates <- origin_date + time_vals * 86400
    warning("Calendar 'noleap' detected: leap years ignored.")
  } else if (calendar == "360_day") {
    dates <- origin_date + time_vals * 86400
    warning("Calendar '360_day' detected: months assumed 30 days.")
  } else {
    stop("Unsupported calendar type: ", calendar)
  }
  return(dates)
}

# restoreDefaultParameterFile <- function(){
#   print("You are about to restore the default settings of the package")
#   user_input <- tolower(readline("Do you want to continue (Y/n): "))
#   if(user_input == "y"){
#     print("Restoring default parameters")
#
#
#     print("Default parameters restored")
#   }
#   else(
#     print("Exiting restoration process")
#   )
#
# }

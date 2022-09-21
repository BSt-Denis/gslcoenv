#' @title Read netCDF file containing the gridded data.
#'
#' @description This function read the netCDF (.nc) file associated with the varname
#' argument, extract the data and slice it according to specified arguments.
#' The function return a list containing the sliced data, its coordinates and
#' others useful metadata.
#'
#' @param varname Name of the variable
#' @param longitude Default = NA, Range of longitude to slice the variable data.
#' If NA, the whole dimensions is imported. The longitude argument must be NA or
#' a vector of length 2.
#' @param latitude Default = NA, Range of latitude to slice the variable data.
#' If NA, the whole dimension is imported. The latitude argument must be NA or
#' a vector of length 2.
#' @param time Default = NA, Range of time to slice the variable data.
#' If NA, the whole dimension is imported. The time argument must be NA or a
#' vector of length 2.
#' @param path_to_data Default = NA. The path to the data directory.
#' If NA, the path is store in /extdata/pkg_params.rdata under the name data_path
#' @param date_format  Default = "%Y-%m". The format of the time argument.
#' Default can be seen as "YYYY-MM".
#' Other possible format are available via \code{\link{strptime}}
#'
#' @return Return a list containing the sliced data, its dimensions and their
#' values and the variable units.
#'
#' To get all the possible field names, use the command \code{\link{names}}.
#' Example : names(var_data)
#'
#' @export
#'
#' @examples
#' \dontrun{var = read_nc("bottom_temperature")
#'
#' var = read_nc("bottom_temperature", longitude=c(-64,-50), latitude=c(34,50),
#' time = c("1985-01","2004-11"))}
#'
read_nc <- function(varname, longitude=NA, latitude=NA, time=NA, path_to_data = NA, date_format="%Y-%m") {
  # Open nc file associated with the variables
  if(is.na(path_to_data)) {path_to_data <- rlist::list.load(system.file("extdata", "pkg_params.rdata", package = "gslcoenv"))$data_path}

  nc <- ncdf4::nc_open(paste0(path_to_data,varname,".nc"))

  # Get indexes to slice values
  # Longitude
  if (is.na(longitude[1])) {
    lon_start <- 1
    lon_count <- -1
    valid_lon <- ncdf4::ncvar_get(nc,'longitude',start=c(1,1),count=c(-1,1))
  } else {
    nc_lon <- ncdf4::ncvar_get(nc,'longitude',start=c(1,1),count=c(-1,1))
    valid_lon <- nc_lon[dplyr::between(nc_lon,min(longitude),max(longitude))]
    lon_match <- match(c(min(valid_lon),max(valid_lon)),nc_lon)

    # Longitude index and count
    lon_start <- min(lon_match)
    lon_count <- max(lon_match)-min(lon_match)+1
  }

  # Latitude
  if (is.na(latitude[1])) {
    lat_start <- 1
    lat_count <- -1
    valid_lat <- ncdf4::ncvar_get(nc,'latitude',start=c(1,1),count=c(1,-1))
  } else {
    nc_lat <- ncdf4::ncvar_get(nc,'latitude',start=c(1,1),count=c(1,-1))
    valid_lat <- nc_lat[dplyr::between(nc_lat,min(latitude),max(latitude))]
    lat_match <- match(c(min(valid_lat),max(valid_lat)),nc_lat)

    # Latitude index and count
    lat_start <- min(lat_match)
    lat_count <- max(lat_match)-min(lat_match)+1
  }

  # Time
  if (is.na(time[1])) {
    time_start <- 1
    time_count <- -1
    time_data <- lubridate::as_date(ncdf4::ncvar_get(nc,'time')/86400, origin = lubridate::origin)
  } else {
    nc_time <- ncdf4::ncvar_get(nc,'time')

    # Convert argument time into date
    time = lubridate::as_date(lubridate::parse_date_time(time,date_format))

    # Convert second since epoch to R time
    nc_time <- lubridate::as_date(nc_time/86400, origin = lubridate::origin)
    time_data <- nc_time[dplyr::between(nc_time,min(time),max(time))]
    time_match <- match(c(min(time_data),max(time_data)),nc_time)

    # Time index and count
    time_start <- min(time_match)
    time_count <- max(time_match)-min(time_match)+1
  }

  # Create vector
  start_vec = c(lon_start,lat_start,time_start)
  count_vec = c(lon_count,lat_count,time_count)

  # Extract variable data
  var_nc = ncdf4::ncvar_get(nc, varid=varname, start=start_vec, count=count_vec)

  # Meshgrid for longitude and latitude
  ms_grid = pracma::meshgrid(valid_lat,valid_lon)

  # Generate a data list
  var_data = list(varname, var_nc, ms_grid$y, ms_grid$x, time_data, dim(var_nc), c("longitude","latitude","time"), ncdf4::ncatt_get(nc, varname, attname="units")$value, varname)

  # Add symbolic names to data list
  names(var_data) = c("variables",varname,"longitude","latitude","time","shape","dims","units","nc_var")

  # Close .nc file
  ncdf4::nc_close(nc)

  return(var_data)

}

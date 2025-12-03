#===============================================================================
# read_nc
#===============================================================================

#' @title Read and import environmental data.
#'
#' @description This function read the NetCDF (.nc) file associated with the
#' environmental data, .
#' The function return a list containing the sliced data, its coordinates and
#' others useful metadata.
#'
#' @param varname Name of the variable to read
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
#' If NA, the path used is the default one stored in the package internal file.
#' @param date_format  Default = "%Y-%m". The format of the time argument.
#' Default can be seen as "YYYY-MM".
#' Other possible format are available via \code{\link{strptime}}
#'
#' @return Return a list containing the sliced data, dimensions and units.
#'
#' To print all the possible field names, use the command \code{\link{names}}.
#'
#' @export
#'
#' @examples
#' \dontrun{var = read_nc("bottom_temperature")
#'
#' var = read_nc("bottom_temperature", longitude=c(-64,-50), latitude=c(34,50),
#' time = c("1985-01","2004-11"))}
#'
read_nc <- function(varname, longitude=NA, latitude=NA, time=NA, path_to_data=NA, date_format="%Y-%m") {

  # Check for path_to_data argument
  if(is.na(path_to_data)){
    path_to_data <- yaml::read_yaml(system.file("extdata", "pkg_parameters.yaml", package = "gslcoenv"))$data_path
  }

  # Find NetCDF files in folder
  file_list <- list.files(path_to_data, pattern = "\\.nc$")

  # Stop function if no file is found
  if(length(file_list) == 0){
    stop(paste0("No netCDF file in directory : ",path_to_data))
  }

  # Find the file with the varname you are looking for
  file_counter=0
  for (filename in file_list){
    nc <- ncdf4::nc_open(paste0(path_to_data,filename))
    if (varname %in% names(nc$var)){
      break
    }
    else{
      file_counter = file_counter+1
    }
  }

  #Check if the varname was found
  if(file_counter == length(file_list)){
    stop(paste0(" Varname : ",varname," is not found in the folder: ",path_to_data))
  }

  # Get indexes to slice values
  # Longitude
  if (is.na(longitude[1])) {
    lon_start <- 1
    lon_count <- -1
    valid_lon <- ncdf4::ncvar_get(nc,'longitude',start=c(1,1),count=c(-1,1))
  }
  else {
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
  }
  else {
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
    time_data <- xr_datetime2R_datetime(nc)
  }
  else {
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
  var_data = list(varname, var_nc, ms_grid$Y, ms_grid$X, time_data, dim(var_nc), c("longitude","latitude","time"), ncdf4::ncatt_get(nc, varname, attname="units")$value, varname)

  # Add symbolic names to data list
  names(var_data) = c("variables",varname,"longitude","latitude","time","shape","dims","units","nc_var")

  # Close .nc file
  ncdf4::nc_close(nc)

  return(var_data)
}

#===============================================================================
# list_nc
#===============================================================================

#' @title List the variables in the data folder
#'
#' @description  Provide information on the variables found in the data folder set by
#' \code{\link{setDataPath}}
#'
#' @export

list_nc <- function(){
  # Get path to parameters file
  parameter_file <- system.file("extdata", "pkg_parameters.yaml", package = "gslcoenv")

  #Get path to data folder
  data_path <- yaml::read_yaml(parameter_file)$data_path

  # Get the file name present in data folder
  flist <- list.files(data_path, pattern = "\\.nc$")

  # Stop function if no file is found
  if(length(flist) == 0){
    stop(paste0("No netCDF file in directory : ",data_path))
  }

  #Excluded variables based on coordinates
  excluded_vars <- c("longitude","latitude","time")

  #Initialize empty list
  variable_name <- list()
  long_name <- list()
  unit <- list()
  first_year<- list()
  last_year<- list()
  filename <- list()

  # Loop over each .nc file present in the folder
  for (f in flist){
    # Open NetCDF file
    nc <- ncdf4::nc_open(paste0(data_path,f))

    # Filter variable names to exclude longitude, latitude and time
    filtered_vars <- setdiff(names(nc$var),excluded_vars)

    # Extract names, long names and units from each variables from the file
    for (name in filtered_vars){
      variable_name <- append(variable_name, name)
      long_name <- append(long_name, ncdf4::ncatt_get(nc,varid=name,attname='long_name')$value)
      unit <- append(unit, ncdf4::ncatt_get(nc,varid=name,attname='units')$value)
      filename <- append(filename, f)
      dates <- nc_datetime2R_datetime(nc)
      first_year <- append(first_year, format(min(dates),"%Y"))
      last_year <- append(last_year, format(max(dates),"%Y"))
    }
    # Close NetCDF file
    ncdf4::nc_close(nc)
  }
  ##########################################
  ## Printing table

  # Column Widths
  variable_name_width <- max(nchar(c("Name", variable_name))) + 2
  long_name_width <- max(nchar(c("Long name", long_name))) + 2
  unit_width <- max(nchar(c("Unit", unit))) + 2
  first_year_width <- max(nchar(c("First year", first_year))) + 2
  last_year_width <- max(nchar(c("Last year", last_year))) + 2
  filename_width <- max(nchar(c("Filename", filename))) + 2

  # Header
  cat("Available variables :\n")
  cat(sprintf("%-*s|%-*s|%-*s|%-*s|%-*s|%-*s\n", variable_name_width, "Name", long_name_width, "Long name", unit_width, "Unit", first_year_width,"First year", last_year_width, "Last year", filename_width, "Filename"))
  cat(paste(rep("-", variable_name_width + long_name_width + unit_width + filename_width + 2), collapse=""), "\n")

  # Data
  for (i in 1:length(variable_name)) {
    cat(sprintf("%-*s|%-*s|%-*s|%-*s|%-*s|%-*s\n", variable_name_width, variable_name[i], long_name_width, long_name[i], unit_width, unit[i], first_year_width, first_year[i], last_year_width, last_year[i], filename_width, filename[i]))
  }
}

#===============================================================================
# nouvelle_fonction
#===============================================================================

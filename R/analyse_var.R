#' @title Perform statistical analysis on a var_list
#'
#' @description Perform one or multiple statistical analysis along the time or
#' spatial dimension.
#'
#' @param var_list  list containing the variable extracted from \code{\link{read_nc}} or \code{\link{load_var}}
#' @param op operations to perform on the data, character or list of characters.
#' Operations are "mean","min","max","med" for median, "sd" for standard
#' deviation, "prct" for percentile, "all" for all of the previous.
#'
#' @param dims Output data dimensions, dims = "xy" or "t". If "xy", return a
#' spatial grid where the analysis is performed along time. If "t", return a
#' time series on which the analysis is performed along the longitude and
#' latitude dimensions for each time step.
#'
#' @param prct Float or vector where the elements are between 0 and 1 to calculate
#' the percentile, 0.1 = 10%. Default = c(0.1,0.9). Only works if "prct" or
#' "all" is include in op. argument.
#'
#' @return list containing the result from the statistical analysis, the unit,
#' the dimensions and the number of valid observations for each points
#'
#' @export
#' @examples \dontrun{temp <- stat_var(var_list,c("mean","min"),"xy")
#' temp <- stat_var(var_list,"all", "t", prct = c(0.25,0.5,0.75))}
stat_var <- function(var_list, op, dims, prct = c(0.1,0.9)){

  # Check if the list is already pass into this function.
  stopifnot(var_list$nc_var %in% names(var_list))

  # Create empty list to return
  out_list = list()
  var_vec = vector()

  # dims to analyze
  if( dims == 'xy'){
    dims = c(1,2)
    out_list[["longitude"]] = var_list$longitude
    out_list[["latitude"]] = var_list$latitude
    out_list[["shape"]] = dim(out_list$longitude)
    out_list[["dims"]] = c("longitude","latitude")
    }
  else if(dims == "t"){
    dims = c(3)
    out_list[["time"]] = var_list$time
    out_list[["shape"]] = dim(out_list$time)
    out_list[["dims"]] = c("time")
  }
  else {
    stop("dims argument must be either 'xy' or 't'")
  }

  # Number of valid observations
  out_list[["nobs"]] = apply(var_list[[var_list$nc_var]], dims, function(x) length(which(!is.na(x) | !is.nan(x))))
  var_vec = append(var_vec,"nobs")

  # Apply mean over selected dimensions
  if("mean" %in% op | "all" %in% op){
   out_list[["mean"]] = apply(var_list[[var_list$nc_var]], dims, function(x) mean(x,na.rm=TRUE))
   var_vec = append(var_vec,"mean")
  }

  # Min
  if("min" %in% op | "all" %in% op){
    out_list[["min"]] = apply(var_list[[var_list$nc_var]], dims, function(x) min(x,na.rm=TRUE))
    out_list$min[sapply(out_list$min, is.infinite)] <- NaN
    var_vec = append(var_vec,"min")
  }

  # Max
  if("max" %in% op | "all" %in% op){
    out_list[["max"]] = apply(var_list[[var_list$nc_var]], dims, function(x) max(x,na.rm=TRUE))
    out_list$max[sapply(out_list$max, is.infinite)] <- NaN
    var_vec = append(var_vec,"max")
  }

  # Median
  if("med" %in% op | "all" %in% op){
    out_list[["med"]] = apply(var_list[[var_list$nc_var]], dims, function(x) stats::median(x,na.rm=TRUE))
    var_vec = append(var_vec,"med")
  }

  # Standard Deviation
  if("sd" %in% op | "all" %in% op){
  out_list[["sd"]] = apply(var_list[[var_list$nc_var]], dims, function(x) stats::sd(x,na.rm=TRUE))
  var_vec = append(var_vec,"sd")
  }

  # Percentile
  if("prct" %in% op | "all" %in% op){
    for(i in prct){
      out_list[[paste0("pct",i*100)]] = apply(var_list[[var_list$nc_var]], dims, function(x) stats::quantile(x,i,na.rm=TRUE))
      var_vec = append(var_vec,paste0("pct",i*100))
    }
  }

  # Add element into output list
  out_list[["variables"]] = var_vec
  out_list[["units"]] = var_list$units
  out_list[["nc_var"]] = var_list$nc_var

  return(out_list)
}

# yearly <- function(var_list){
#
#   # Check if time is a dimension in var_list
#   stopifnot("time" %in% names(var_list))
#
#   # Get yearly time
#   time_year = unique(lubridate::floor_date(var_list$time, unit="year"))
#
#   # Calculate mean values over a year
#
# }

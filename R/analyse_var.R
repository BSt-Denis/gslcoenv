#' @title Perform some statistical analysis on a var_list
#'
#' @description Perform one or multiple statistical analysis along the time or
#' spatial dimension.
#'
#' @param var_list  list containing the variable extracted from read_nc
#' @param op operations to perform on the data, character or list of characters
#' Operations are "mean","min","max","med" for median, "std" for standard
#' deviation, "prct" for percentile, "all" for all of the previous.
#'
#' @param dims Dimensions to operate the analysis. "xy" | "t". "xy" return a
#' spatial grid where the analysis is performed along time, or "t" return a
#' time series on which the analysis is performed along the longitude and
#' latitude dimensions.
#'
#' @param prct Float or vector where element are between 0 and 1 to calculate
#' the percentile, 0.1 = 10%. Default = c(0.1,0.9). Only works if "prct" or
#' "all" is include in op. argument.
#'
#' @return list containing the result from the statistical analysis, the unit
#' and the dimensions
#'
#' @export
#' @examples \dontrun{temp <- stat_var(var_list,c("mean","min"),"xy")
#' temp <- stat_var(var_list,"all", "t", prct = c(0.25,0.5,0.75))}
stat_var <- function(var_list, op, dims, prct = c(0.1,0.9)){

  # Create empty list to return
  out_list = list()
  out_list[["name"]] = var_list$name
  out_list[["units"]] = var_list$units

  # Adjust proper dims to analyze
  if( dims == 'xy'){
    dims = c(1,2)
    out_list[["longitude"]] = var_list$longitude
    out_list[["latitude"]] = var_list$latitude
    } else if(dims == "t"){
    dims = c(3)
    out_list[["time"]] = var_list$time
  } else {
    stop("dims argument must be either NA, 'xy' or 't'")
  }

  # Apply mean over selected dimensions
  if("mean" %in% op | "all" %in% op){
   out_list[["mean"]] = apply(var_list$data, dims, function(x) mean(x,na.rm=TRUE))
  }

  # Min
  if("min" %in% op | "all" %in% op){
    out_list[["min"]] = apply(var_list$data, dims, function(x) min(x,na.rm=TRUE))
    out_list$min[sapply(out_list$min, is.infinite)] <- NaN
  }

  # Max
  if("max" %in% op | "all" %in% op){
    out_list[["max"]] = apply(var_list$data, dims, function(x) max(x,na.rm=TRUE))
    out_list$max[sapply(out_list$max, is.infinite)] <- NaN
  }

  # Median
  if("med" %in% op | "all" %in% op){
    out_list[["med"]] = apply(var_list$data, dims, function(x) stats::median(x,na.rm=TRUE))
  }

  # Standard Deviation
  if("std" %in% op | "all" %in% op){
  out_list[["std"]] = apply(var_list$data, dims, function(x) stats::sd(x,na.rm=TRUE))
  }

  # Percentile
  if("prct" %in% op | "all" %in% op){
    for(i in prct){
      out_list[[paste0("pct",i*100)]] = apply(var_list$data, dims, function(x) stats::quantile(x,i,na.rm=TRUE))
    }
  }

  return(out_list)
}

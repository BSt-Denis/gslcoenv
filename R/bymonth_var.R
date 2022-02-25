#' @title Extract data from a variable list according to specified months
#'
#' @description Extract data from a var_list by specifying which month the data
#' should contain.
#'
#' @param var_list var_list created or loaded by this package
#' @param month_name Numeric number of the month (11 = november). Either numeric
#' or vector numeric element
#'
#' @return var_list containing data of the specified month
#'
#' @export
#'
#' @examples \dontrun{temp_june <- bymonth_var(total_temp,6)
#' temp_june_august <- bymonth_var(total_temp,c(06,08))}
#'
bymonth_var <- function(var_list, month_name){

  #Check if time is in the var_list
  if(!("time" %in% names(var_list))){
    stop("Element time must be part of the var_list argument")
  }
  # Check if month_name is numeric
  stopifnot(is.numeric(month_name))

  # Extract month from date time
  monthName = lubridate::month(var_list$time)

  # Get valid date index
  valid_date_id = which(monthName %in% month_name)

  var_list$time = var_list$time[valid_date_id]
  var_list$data = var_list$data[,,valid_date_id]
  var_list$shape = dim(var_list$data)

  return(var_list)
}

#' @title Extract data from a variable list according to specified months
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

#' @title Extract variable list data  according to specified months
#'
#' @description Extract data from a var_list by specifying which month the data
#' should contain.
#'
#' @param var_list var_list created or loaded by this package
#' @param month_name Name of the months to use for extraction. Either character
#' or vector of character
#'
#' @return var_list containing data for the specified month
#'
#' @export
#'
#' @examples \dontrun{temp_june <- bymonth_var(total_temp,"june")
#' temp_june_august <- bymonth_var(total_temp,c("june","august"))}
#'
bymonth_var <- function(var_list, month_name){
  if(!("time" %in% names(var_list))){
    stop("Element time must be part of the var_list argument")
  }

  # Lower possible capital letter
  month_name = tolower(month_name)

  # Extract month from date time
  monthName = tolower(lubridate::month(var_list$time, label=TRUE, abbr=FALSE))

  # Get valid date index
  valid_date_id = which(monthName %in% month_name)

  var_list$time = var_list$time[valid_date_id]
  var_list$data = var_list$data[,,valid_date_id]
  var_list$shape = dim(var_list$data)

  return(var_list)
}

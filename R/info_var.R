#' @title info_var
#'
#' @description This function print information about a variable list created by read_nc.
#' The variable name, shape, dimension names, units and memory used are printed.
#' This function is useful to take a quick look at the extracted variable.
#'
#' @param ls variable list created by this package
#'
#' @return The output from \code{\link{print}}
#' @export
#'
#' @examples
#' \dontrun{var_info(ls)}
info_var <- function(ls) {
  # Check if ls is a list
  if (!is.list(ls)) {
    stop("ls argument must be a list. typeof(ls) == list")
  }
  # Print information extracted from variable list ls.
  print(paste0("Variables = ",paste0(c(ls$variables),collapse=",")))
  print(paste0("Shape = (",paste0(c(ls$shape),collapse=","),")" ))
  print(paste0("Dimensions = (",paste0(c(ls$dims),collapse=","),")"))
  print(paste0("Units = ",ls$units))
  print(paste0("Data Memory = ",utils::object.size(ls)," bytes"))
  print(paste0("NetCDF variable name = ", ls$nc_var))
}

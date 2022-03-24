#' @title Visualize time series
#'
#' @description Function to visualize 1D data along time.
#'
#' @param data vector, or 1D object
#' @param var_list var_list containing information about the data
#'
#' @export
#'
#' @examples \dontrun{viz_ts(var_list$bottom_temperature, var_list)}
viz_ts <- function(data,var_list){
  # Check for time dimensions
  stopifnot("time" %in% names(var_list))

  # Plot time series
  graphics::plot(var_list$time, data, type="o",
                 main = paste0("Timeserie from ",var_list$time[1]," to ",utils::tail(var_list$time,1)),
                 xlab = "Time")
}


#' @title Plot data on a map of the estuary
#'
#' @description Create a map displaying the data on the estuary with a colormap
#' from the \code{\link[cmocean]{cmocean}} package.
#'
#' @param data name of variable to plot
#' @param var_list var_list containing coordinates and dimensions of the data
#'
#' @export
#'
#' @examples
#' \dontrun{viz_map(vl$bottom_temperature[,,1],vl)}
viz_map <- function(data, var_list){

  # Check for longitude and latitude coodinates, and dimensions of data
  stopifnot("longitude" %in% names(var_list),"latitude" %in% names(var_list), length(dim(data)) == 2)

  # Choose the right colorbar
  if(var_list[["nc_var"]] == "bottom_temperature"){
    colorname = "thermal"
    coldir = 1
  } else if(var_list[["nc_var"]] == "bottom_salinity"){
    colorname = "haline"
    coldir=-1
  } else if(var_list[["nc_var"]] == "C1" | var_list[["nc_var"]] == "C2"){
    colorname = "deep"
    coldir = 1
  } else{
    colorname = "thermal"
    coldir = -1
  }

  # Convert data and coordinates to a dataframe
  df <- data.frame(as.vector(var_list$longitude),as.vector(var_list$latitude),as.vector(data))
  names(df) = c("longitude","latitude","data")

  # Get world raster
  world = rnaturalearth::ne_countries(scale = "medium", returnclass ="sf")

  # Plotting
  ggplot2::ggplot(data = world) +
    ggplot2::geom_sf(fill ="antiquewhite") +
    ggplot2::coord_sf(xlim = c(min(var_list$longitude)-0.07, max(var_list$longitude)+0.07),
                      ylim = c(min(var_list$latitude)-0.05, max(var_list$latitude)+0.05), expand = TRUE)+
    # Contour filled
    ggplot2::geom_contour_filled(data = df, ggplot2::aes(x=longitude, y=latitude, z=data))+
    cmocean::scale_fill_cmocean(name = colorname, discrete = TRUE, direction = coldir) +

    # Add grid
    ggplot2::theme(
      panel.grid.major = ggplot2::element_line(color = grDevices::gray(.5), linetype = "dashed", size = 0.5))
}

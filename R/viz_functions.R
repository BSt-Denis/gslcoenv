#' @title Visualize time series
#'
#' @description Function to visualize 1D data along time.
#'
#' @param data vector, or 1D object
#' @param var_list var_list containing information about the data
#'
#' @export
#'
#' @examples \dontrun{viz_ts(temp$data, temp)}
viz_ts <- function(data,var_list){
  graphics::plot(var_list$time, data, type="l", main = paste0("Timeserie from ",var_list$time[1]," to ",utils::tail(var_list$time,1)))
}

# viz_map <- function(data,var_list, timeid = NA, cmap = cmocean::cmocean("thermal")){
#
#   # Reduce 3D data to 2D
#   if(length(dim(data)) == 3){data = data[,,timeid]}
#
#   # Plot data
#   world = rnaturalearth::ne_countries(scale = "medium", returnclass ="sf")
#
#   ggplot2::ggplot(data = world) +
#     ggplot2::geom_sf(fill ="antiquewhite") +
#     ggplot2::geom_contour_filled(data=as.data.frame(data), ggplot2::aes(x=var_list$longitude, y = var_list$latitude))+
#     ggplot2::coord_sf(xlim = c(-71, -53.5), ylim = c(45, 52), expand = FALSE)+
#     ggplot2::xlab("Longitude") +
#     ggplot2::ylab("Latitude") +
#     ggplot2::ggtitle("Map of the 2D data")+
#   ggplot2::theme(
#     panel.grid.major = ggplot2::element_line(color = grDevices::gray(.5), linetype = "dashed", size = 0.5),
#     panel.background = ggplot2::element_rect(fill = "aliceblue"))
#
# }

#' @title Plot 2D data on a map ** Not fully implementend yet
#'
#' @param data Data to be plotted
#' @param var_list var_lsit containing informations about the data
#' @param timeid time index in case of 3D data, only works if length(dims(data)) > 2
#' @param cmap colormap used to plot the data, default = thermal from the
#' \code{\link[cmocean]{cmocean}} package.
#'
#' @export
#'
#' @examples
#' \dontrun{viz_map(temp$data,temp,timeid=1)}
viz_map <- function(data,var_list, timeid = NA, cmap = cmocean::cmocean("thermal")){

  # Reduce 3D data to 2D
  if(length(dim(data)) == 3){data = data[,,timeid]}

  # Plot data
  graphics::filled.contour(rev(var_list$longitude[,1]), var_list$latitude[1,],apply(var_list$data[,,1],2,rev),
                 nlevels = 10, color.palette = cmocean::cmocean("thermal"),
                 plot.title = {graphics::par(cex.main=1);graphics::title(main="Visualization of 2D data",
                                                                xlab = "Longitude", ylab="Laitutde")},
                 key.title = {graphics::par(cex.main=0.5);graphics::title(main=paste0(var_list$name,"\n","[",var_list$units,"]"))})
}

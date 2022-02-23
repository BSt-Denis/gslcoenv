#' @title Create polygon from a list or vector of longitude and latitude
#' coordinates
#'
#' @description Create polygon as class "sfc" form sf R package by provinding
#' a list or vector of longitude and latitude. If the coordinates are projected
#' on a defined crs. The crs can be provided to properly construct the polygon
#' via the crs argument. If only two coordinates are given, a rectangle polygon
#' is created using the two points as top left and right bottom corner.
#' The coordinates doesn't need to close, the function take care of it for you.
#'
#' @param longitude Vector or list with longitude coordinates
#' @param latitude Vector or list with latitude coordinates
#' @param crs number or string representing a coordinate reference system (CRS)
#'
#' @return Polygon as sfc class defined in "sf" package.
#' @export
#'
#' @examples
#' polygone = create_poly(c(-70,-60),c(40,45))
#' polygone = create_poly(c(-65,-70,-70,-65),c(40,40,45,45), crs = 4326)
create_poly <- function(longitude, latitude, crs = 4326){
  # If two points are give, set a polygon delimited by the top left and right bottom corners
  if(length(longitude) == 2 & length(latitude) == 2){
    longitude = longitude[c(1,1,2,2,1)]
    latitude = latitude[c(1,2,2,1,1)]
  }

  # Check if polygon is closed
  if(utils::head(longitude, n=1) != utils::tail(longitude, n=1) | utils::head(latitude, n=1) != utils::tail(latitude, n=1)){
    longitude = append(longitude,utils::head(longitude, n=1))
    latitue = append(latitude,utils::head(latitude, n=1))
  }

  # Create polygon
  poly = sf::st_polygon(list(cbind(longitude,latitude)))
  # Add proper coordinate reference system for plotting and comparing.
  poly = sf::st_sfc(poly, crs=crs)

  return(poly)
}

#' @title Save polygon on local disk
#'
#' @description Save polygon on the local computer in various format
#' depending o the extension of the savepath argument. For the moment, only
#' "rdata" and "csv" are implemented.
#'
#' @param poly Polygon as sf | sfc class from the R package "sf"
#' @param savepath Path to save the polygone
#' @param polyname Name of the polygone, Default = NA, this arguments is only
#' taken into account if the extension of savepath is "rdata". In this case,
#' polyname must be a char type.
#'
#' @export
#'
#' @examples
#' \dontrun{save_poly(polgone,"/home/bruno/save_directory/save_poly.rdata",
#' polyname = "16F")}
#'
save_poly <- function(poly, savepath, polyname=NA){
  # Rdata format
  if(tools::file_ext(savepath) == "rdata"){
    if(is.na(polyname)){
      stop("polyname argument must not be NA, please enter a valid name for your polygon")
    }
    # Create empty list
    polylist = list()
    # Insert polygon in list
    polylist[[polyname]] = poly
    # Save data into rdata fil as list
    rlist::list.save(polylist, savepath)
  }

  # CSV
  else if(tools::file_ext(savepath) == "csv"){
    # Retrieve points from polygon
    pts = sf::st_coordinates(poly)
    # Rename columns X Y L1 L2 to longitude latitude L1 L2
    colnames(pts) = c("longitude","latitude","L1","L2")
    utils::write.csv(pts[,1:2], file=savepath, sep =",", col.names = TRUE, row.names = FALSE)
  }
  else {
    stop("Extension not recognize, rdata and csv are implemented for the moment")
  }

}

#' @title Load a polygon from file
#'
#' @description Load a a polygon from a file. For the moment, only .csv and .rdata
#' are implemented. The loading method is defined by the filename extension.
#'
#' @param load_path Path to load the file
#' @param lon_name name given to the columns with the longitude component in
#' the loaded file. Arguments only works for csv extension^
#' @param lat_name name given to the columns with the latitude component in
#' the loaded file. Arguments only works for csv extension
#'
#' @return Polygon as sfc class defined in "sf" package is extension is .csv.
#' Return a list comprising a polygon of sfc class.
#'
#' @export
#'
#' @examples \dontrun{polygone = load_poly("/home/bruno/<save directory>/save_poly.rdata")}
#'
load_poly <- function(load_path, lon_name="longitude", lat_name="latitude"){
  # Rdata
  if(tools::file_ext(load_path) == "rdata"){
    # Load data into list
    poly <- rlist::list.load(load_path)
  }
  # CSV
  else if(tools::file_ext(load_path) == "csv"){
   poly_pts = utils::read.csv(load_path)
   poly = create_poly(poly_pts[[lon_name]], poly_pts[[lat_name]], crs = 4326)
  }
  else {
    stop("Extension not recognize, rdata and csv are implemented at the moment")
  }
  return(poly)
}

#' @title Show a selected polygon on the map
#'
#' @description Show a polygon on the map of the estuary and the gulf of
#' St.Lawrence.
#'
#' @param poly a polygone of either "sf", "sfc" class or any polygone
#' with crs attributes
#
#' @export
show_poly <- function(poly){
  # Get world map
  world = rnaturalearth::ne_countries(scale = "medium", returnclass ="sf")

  ggplot2::ggplot(data = world) +
    ggplot2::geom_sf(fill ="antiquewhite") +
    # Add polygon
    ggplot2::geom_sf(data=poly, colour = "red", linetype=2)+
    # Zoom on the gulf and estuary
    ggplot2::coord_sf(xlim = c(-71, -53.5), ylim = c(45, 52), expand = FALSE)+
    ggplot2::xlab("Longitude") +
    ggplot2::ylab("Latitude") +
    ggplot2::ggtitle("Showing the polygon as red dashed line")
    ggplot2::theme(
      panel.grid.major = ggplot2::element_line(color = grDevices::gray(.5), linetype = "dashed", size = 0.5),
      panel.background = ggplot2::element_rect(fill = "aliceblue"))
}

within_poly <- function(var_list,poly){

  # Create sf multipoint feature with the lat/lon grid
  multipts = sf::st_multipoint(list(cbind(as.vector(var_list$longitude),as.vector(var_list$latitude))))

  # Find which points is inside poly

  # Create mask from these points

  # Apply mask over data

  # Update var_list with new data
  # var_list$data
}

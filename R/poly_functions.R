#' @title Create polygon from a list or vector of longitude and latitude
#' coordinates
#'
#' @description Create polygon as class "sfc" from sf package by provinding
#' a list or vector of longitude and latitude. If the coordinates are projected
#' on a defined coordinate reference system, the crs can be provided to properly construct the polygon
#' via the crs argument. If only two coordinates are given, a rectangle polygon
#' is created using the two points as top left and right bottom corner.
#' The coordinates doesn't need to close, the function take care of it for you.
#'
#' @param longitude Vector or list with longitude coordinates
#' @param latitude Vector or list with latitude coordinates
#' @param crs number or string representing a coordinate reference system (CRS)
#'
#' @return Polygon of sfc class defined in "sf" package.
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
    latitude = append(latitude,utils::head(latitude, n=1))
  }

  # Create polygon
  pol= sf::st_polygon(list(cbind(longitude,latitude)))

  # Add proper coordinate reference system for plotting and comparing.
  pol= sf::st_sfc(pol, crs=crs)

  return(pol)
}

#' @title Save polygon on local disk
#'
#' @description Save polygon on the local computer in various format
#' depending o the extension of the savepath argument. For the moment, only
#' "rdata" and "csv" are implemented.
#'
#' @param pol Polygon as sf | sfc class from the R package "sf"
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
save_poly <- function(pol, savepath, polyname=NA){
  # Rdata format
  if(tools::file_ext(savepath) == "rdata"){
    if(is.na(polyname)){
      stop("polyname argument must not be NA, please enter a valid name for your polygon")
    }
    # Create empty list
    polylist = list()
    # Insert polygon in list
    polylist[[polyname]] = pol
    # Save data into rdata fil as list
    rlist::list.save(polylist, savepath)
  }

  # CSV
  else if(tools::file_ext(savepath) == "csv"){
    # Retrieve points from polygon
    pts = sf::st_coordinates(pol)
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
#' the loaded file. Arguments only works for csv file
#' @param lat_name name given to the columns with the latitude component in
#' the loaded file. Arguments only works for csv file
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
    pol <- rlist::list.load(load_path)
  }
  # CSV
  else if(tools::file_ext(load_path) == "csv"){
   poly_pts = utils::read.csv(load_path)
   pol = create_poly(poly_pts[[lon_name]], poly_pts[[lat_name]], crs = 4326)
  }
  else {
    stop("Extension not recognize, rdata and csv are implemented at the moment")
  }
  return(pol)
}

#' @title Show polygon on the map
#'
#' @description Show a polygon on the map of the estuary and the gulf of
#' St.Lawrence.
#'
#' @param pol a polygone of either "sf", "sfc" class or any polygone
#' with crs attributes
#
#' @export
show_poly <- function(pol){
  # Get world map
  world = rnaturalearth::ne_countries(scale = "medium", returnclass ="sf")

  ggplot2::ggplot(data = world) +
    ggplot2::geom_sf(fill ="antiquewhite") +
    # Add polygon
    ggplot2::geom_sf(data=pol, colour = "red", fill = NA, linetype=2)+
    # Zoom on the gulf and estuary
    ggplot2::coord_sf(xlim = c(-71, -53.5), ylim = c(45, 52), expand = FALSE)+
    ggplot2::xlab("Longitude") +
    ggplot2::ylab("Latitude") +
    ggplot2::ggtitle("Showing the polygon in red") +
    ggplot2::theme(
      panel.grid.major = ggplot2::element_line(color = grDevices::gray(.5), linetype = "dashed", size = 0.5),
      panel.background = ggplot2::element_rect(fill = "aliceblue"))
}


#' @title Mask data that are outside a chosen polygon
#'
#' @description Mask and slice the data of a var_list that are outside the polygon
#'
#' @param var_list list containing the variables extracted from \code{\link{read_nc}} or \code{\link{load_var}}
#' @param pol polygon of class "sf" or "sfc"
#'
#' @return a list with data masked outside the polygon
#' @export
#'
#' @examples \dontrun{masked_list = inside_poly(bottom_temp, polygone)}
inside_poly <- function(var_list,pol){

  # Check for longitude and latitude coodinates, and dimensions of data
  stopifnot("longitude" %in% names(var_list),"latitude" %in% names(var_list))

  # Get extremities of the polygon
  ext = sf::st_bbox(pol)

  # Slice var_list near the polygon border (reduce memory and slack used)
  var_list = slice_xy(var_list,c(ext[["xmin"]]-0.03,ext[["xmax"]]+0.03),c(ext[["ymin"]]-0.02,ext[["ymax"]]+0.02))

  # Create sf multipoint feature with the sliced grid
  mp = sf::st_multipoint(cbind(as.vector(var_list[["longitude"]]),as.vector(var_list[["latitude"]])))
  p = sf::st_cast(x = sf::st_sfc(mp, crs=4326), to = "POINT")

  # Find which points is inside poly
  valid_pt = lengths(sf::st_intersects(p,pol))

  # Reshape valid_point as an matrix of data dimensions
  valid_pt = matrix(valid_pt, nrow = nrow(var_list[["longitude"]]))

  # Apply mask over data
  for(varname in var_list[["variables"]]){
    var_list[[varname]][valid_pt==0] = NA
  }

  return(var_list)
}

#' @title Select the data inside a distance of a point
#'
#' @description Select the data that is located inside a specified distance of a
#' selected geographic coordinate.
#'
#' @param var_list list containing the variables extracted from \code{\link{read_nc}} or \code{\link{load_var}}
#' @param lon longitude coordinate of the point
#' @param lat latitude coordinate of the point
#' @param dist distance in meter of the center of the point
#'
#' @return var_list
#'
#' @export
#'
#' @examples \dontrun{masked_list = within_dist(bottom_temp, lon=-65, lat=49, dist=5000)}
within_dist <- function(var_list, lon, lat, dist=5000){

  # Check for longitude and latitude coodinates, and dimensions of data
  stopifnot("longitude" %in% names(var_list),"latitude" %in% names(var_list))

  # Create polygon surrounding the point
  pt_poly = sf::st_buffer(sf::st_sfc(sf::st_point(c(lon,lat)),crs=4326),dist)

  # Get extremities of the polygon
  ext = sf::st_bbox(pt_poly)

  # Slice var_list near the polygon border (reduce memory and slack used)
  var_list = slice_xy(var_list,c(ext[["xmin"]]-0.03,ext[["xmax"]]+0.03),c(ext[["ymin"]]-0.02,ext[["ymax"]]+0.02))

  # Create sf multipoint feature with the sliced grid
  mp = sf::st_multipoint(cbind(as.vector(var_list[["longitude"]]),as.vector(var_list[["latitude"]])))
  p = sf::st_cast(x = sf::st_sfc(mp, crs=4326), to = "POINT")

  # Find which points is inside poly
  valid_pt = lengths(sf::st_intersects(p,pt_poly))

  # Reshape valid_point as an matrix of data dimensions
  valid_pt = matrix(valid_pt, nrow = nrow(var_list[["longitude"]]))

  # Apply mask over data
  for(varname in var_list[["variables"]]){
    var_list[[varname]][valid_pt==0] = NA
  }

  return(var_list)

}

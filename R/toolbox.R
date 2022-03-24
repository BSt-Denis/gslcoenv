slice_xy <- function(vl, longitude, latitude){
  # Check for longitude and latitude coodinates, and dimensions of data
  stopifnot("longitude" %in% names(vl),"latitude" %in% names(vl))

  # Get index of valid coordinates
  valid_lon_id = which(dplyr::between(vl$longitude[,1], min(longitude), max(longitude)))
  valid_lat_id = which(dplyr::between(vl$latitude[1,], min(latitude), max(latitude)))

  # Slicing coordinates
  vl[["longitude"]] = vl$longitude[valid_lon_id,valid_lat_id]
  vl[["latitude"]] = vl$latitude[valid_lon_id,valid_lat_id]

  # Slicing the variables
  if(length(vl$shape) == 2){
    for(vars in vl$variables){
      vl[[vars]] = vl[[vars]][valid_lon_id,valid_lat_id]
    }
  } else {
    for(vars in vl$variables){
      vl[[vars]] = vl[[vars]][valid_lon_id,valid_lat_id,]
    }
  }

  # Updating var_list
  vl[["shape"]] = dim(vl[[vars]])

  return(vl)
}

% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/viz_functions.R
\name{viz_map}
\alias{viz_map}
\title{Plot data on a map of the estuary}
\usage{
viz_map(data, var_list)
}
\arguments{
\item{data}{name of variable to plot}

\item{var_list}{var_list containing coordinates and dimensions of the data}
}
\description{
Create a map displaying the data on the estuary with a colormap
from the \code{\link[cmocean]{cmocean}} package.
}
\examples{
\dontrun{viz_map(vl$bottom_temperature[,,1],vl)}
}

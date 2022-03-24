
# gslcoenv

<!-- badges: start -->
<!-- badges: end -->

The goal of gslcoenv is to provide functionality to interact with the interpolated 
grid contained in Peter Galbraith Assessment report of the physical conditions of 
the St. Lawrence Gulf and Estuary.

## Installation

You can install the development version of gslcoenv from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("BSt-Denis/gslcoenv")
```

## Getting Started
1. You need to download the data stored on the DFO Virtual Private Network (VPN)
at this location -> R:/Commun/Virginie Roy/Package_gslcoenv/data/

2. Tell the package where to find the data on your local computer.
``` r
# Import package
library(gslcoenv)

setDataPath("/home/.../.../folder_with_data/")
```
3. Check if the package find the data
``` r
# List files found in the folder
list_nc()
```
R will print the variables names in the console if everything is fine

## Example

This is an example showing the basic functionality of gslcoenv:

``` r
# Import package gslcoenv into working environment
library(gslcoenv)

# Extract data from netCDF file
var_list = read_nc("bottom_temperature")

# From var_list, slice data to conserve only those in august
new_list = bymonth_var(var_list,8)

# Calculate the mean of the bottom temperature for each grid points 
stat_list = stat_var(new_list,"mean","xy")

# Extract the mean bottom temperature in a radius of 10 km centered at -64 W and 48 N
new_stat_list = indistance_var(stat_list, lon=-64, lat=48, 10000)

# Show the map with the mean bottom temperature in a 10 km radius of -64 W and 48 N
viz_map(stat_list$mean,stat_list)

# Save the data in a netcdf files
save_var(new_stat_list,"C:\users\..\..\data\mean_bottom_temperature.nc")
```

## Troubleshooting

1. Make sure the version of R is 3.5.0 or newer, and the packages are all up to date. If you are using a computer from DFO-MPO, you will need to start RStudio with admin privileges with Avecto to update the version of R and its packages.


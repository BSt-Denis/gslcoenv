
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

# For linux style path
setDataPath("/home/.../.../folder_with_data/")

# For Windows style path
setDataPath("C:\\Users\\...\\...\\folder_with_data\\")
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
## var_list 
A var_list, is a object of class "list" that carries one or many variables such as bottom temperature, the thickness of the intermediate layer or the result of statistical analysis (mean, max, median, etc.). It contains the data, its coordinates and some useful metadata. 

Fields in var_list : 
1. variables : list of variable names in the var_list
2. <variable name> : data of the variable
3. longitude : 2d array containing the longitude coordinates
4. latitude : 2d array containing the latitude coordinates
5. time : vector of "Date object" containing the timestamp
6. shape : vector of integer containing the length of each dimensions
7. dims : vector of character containing the name of the dimensions
8. units : units of the variables
9. nc_var : name of the variable extracted from the netCDF file

As for a list in R, there is three ways to access fields in a var_list : 
``` r
# 1. Calling using $ sign
var_list$longitude
```
It returns the element in the same form as they were insert (list, matrix, array, etc.)

``` r
# 2. Calling using single brackets and quotation mark
var_list["longitude"] 
```
It always returns the element as a list

``` r
# 3. Calling using double brackets and quotation mark
var_list[["longitude"]] 
```
It returns the element in the same form as they were insert (list, matrix, array, etc.)

## Troubleshooting

1. Make sure the version of R is 3.5.0 or newer, and the packages are all up to date. If you are using a computer from DFO-MPO, you will need to start RStudio with admin privileges with Avecto to update the version of R and its packages.


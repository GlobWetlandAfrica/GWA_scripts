#  Copyright (c) 2017, GeoVille Information Systems GmbH
#  All rights reserved.
#
#  Redistribution and use in source and binary forms, with or without
#  modification, is prohibited for all commercial applications without
# licensing by GeoVille GmbH.
#
#
# Date created: 06.05.2017
# Date last modified: 04.09.2018
#
#
# __author__ = "Christina Ludwig"
# __version__ = "1.0"


# INPUT PARAMTERS

# -> FOR QGIS Processing modules
##load_vector_using_rgdal
##Water and Wetness Detection=name
##Wetland Inventory=group
##Directory_containing_indices=folder
##Directory_containing_TWI=folder
##Output_Directory=folder
##Start_Date=optional string
##End_Date=optional string
##Minimum_water_probability=number 45
##Minimum_wetness_probability_bare_soil=number 55
##Minimum_wetness_probability_sparse_vegetation=number 55
##Minimum_wetness_probability_dense_vegetation=number 65
##Minimum_mapping_unit=number 3
##Plot_probability= Boolean False
##Plot_certainty_indicator= Boolean False


# Load libraries ----------------------------------------------------------
library(raster)
library(rgdal)
library(rpanel)
library(stringr)
library(GWAutils)

WI_workflow(Directory_containing_indices,
            Directory_containing_TWI,
            Output_Directory,
            Minimum_water_probability, 
            Start_Date,
            End_Date,
            Minimum_mapping_unit,
            Plot_certainty_indicator,
            Plot_probability)

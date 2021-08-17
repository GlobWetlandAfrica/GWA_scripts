##load_vector_using_rgdal
##[Sampling]=group
##Raster_to_be_sampled=raster
##Samples_per_strata=number 50

##Attribute_name=string class_id
##Optional_Attribute_name_1=string
##Optional_Attribute_name_2=string

##Sample_Points= output vector

Rpath <- file.path(Sys.getenv("USERPROFILE"), ".qgis2", "processing", "rscripts", "GWA_TBX", fsep="\\")

fun_path <-paste(Rpath, '\\rastStratSamp.R', sep='')

source(fun_path)

Result <- RastStratSamp(Raster_to_be_sampled, Samples_per_strata, Attribute_name, Optional_Attribute_name_1,
                        Optional_Attribute_name_2)

Sample_Points<-Result
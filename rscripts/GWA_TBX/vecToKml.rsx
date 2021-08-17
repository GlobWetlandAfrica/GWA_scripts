##load_vector_using_rgdal
##[Sampling]=group
##Sample_Shapefile=vector
##Ouput_Folder=Folder
##ID_Field_from_Shapefile_Attributes=string number
##KML_Filename=string enter_file_name_here.kml

library('rpanel')

str <- ID_Field_from_Shapefile_Attributes
if (str =='' ){
rp.messagebox('You must enter the name of the Shapefile Attribute Field to be used as an ID. It seems you left this option empty.', title = 'Oops! Missing Field')
}


Rpath <- file.path(Sys.getenv("USERPROFILE"), ".qgis2", "processing", "rscripts", "GWA_TBX", fsep="\\")

fun_path <-paste(Rpath, '\\vecToKml.R', sep='')

source(fun_path)

vecToKml(Sample_Shapefile, Ouput_Folder, KML_Filename, ID_Field_from_Shapefile_Attributes)

##load_vector_using_rgdal
##[Sampling]=group
##Point_Samples=vector
##Raster_To_Base_Grid_On=raster
##Make_3x3_Grid____Yes_or_No=string Yes

##Sample_Outline=output vector

# Check for packages required, and if they are not installed, instal them.
tryCatch(find.package("rpanel"), error=function(e) install.packages("rpanel", lib=file.path(.Library[1])))

library('rpanel')

Rpath <- file.path(Sys.getenv("USERPROFILE"), ".qgis2", "processing", "rscripts", "GWA_TBX", fsep="\\")

fun_path <-paste(Rpath, '\\pointToGrid.R', sep='')

source(fun_path)

str <- Make_3x3_Grid____Yes_or_No
if (str !='Yes' & str != 'No'){
rp.messagebox('You must enter "Yes" or "No" for "Make 3x3 Grid"', title = 'oops!')
} else {

if (Make_3x3_Grid____Yes_or_No=='Yes'){

g3x3<-TRUE

} else {

g3x3<-FALSE

}

Result <- PointToGrid(Raster_To_Base_Grid_On, Point_Samples, g3x3)

}

Sample_Outline<-Result

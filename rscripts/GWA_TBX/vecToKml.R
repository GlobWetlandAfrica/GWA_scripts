                                                
  # Converts a shapefile to KML for use in Google Earth
  
  library(maptools)
  library(rgdal)
  
  # function that divides polygons into individual polygons, and gives them each an ID (kmlPolygons cannot do this alone)
  
  kmlPolygons2 <- function(Sample_Shapefile, kmlFileName, Pname, Kname='Samples', Kdescription='Sample ID') {
    
    # get string name of shapefile
    myfunc <- function(inobject) {
      deparse(substitute(inobject))
    }
    Sample_Shapefile_Str<-myfunc(Sample_Shapefile)
    
    
    if (proj4string(get(Sample_Shapefile_Str))!="+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0") {
      cat("Input SpatialPolygonsDataFrame ",Sample_Shapefile_Str," re-projected from ",
          proj4string(get(Sample_Shapefile_Str))," to WGS84 longlat\n",sep="")
      assign(Sample_Shapefile_Str,spTransform(get(Sample_Shapefile_Str),CRS(" +proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0")))
    } # check projection
    
    kmlFile <- file(kmlFileName, "w")
    Xout <- sapply(slot(get(Sample_Shapefile_Str), "polygons"), function(x) { 
      kmlPolygon(x,
                 name=as(get(Sample_Shapefile_Str), "data.frame")[slot(x, "ID"), Pname], 
                 col="#F7FBFF00",
                 lwd=0.5, border='white', visibility=TRUE ) 
    })
    
    cat(kmlPolygon(kmlname=Kname, 
                   kmldescription=Kdescription)$header, 
        file=kmlFile, sep="\n")
    cat(unlist(Xout["style",]), file=kmlFile, sep="\n")
    cat(unlist(Xout["content",]), file=kmlFile, sep="\n")
    cat(kmlPolygon()$footer, file=kmlFile, sep="\n")
    close(kmlFile)
  }
  
  
  vecToKml<-function(Sample_Shapefile, Ouput_Folder, KML_Filename, Attribute_ID){
  
    # check for .kml ectension and add if not present
    exten<-substring(KML_Filename, nchar(KML_Filename)-3, nchar(KML_Filename))
    
    if (exten !='.kml') {
      
      KML_Filename<-paste(KML_Filename, '.kml', sep="")
      
    }
    
    # define the output path for the kml file
    out_path<-paste(Ouput_Folder, '/', KML_Filename, sep="")
    
    # reproject the shapefile to WGS84
    smp_ll<-spTransform(Sample_Shapefile, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0"))
    
    # Get the sample lables for each point
    kml_labels<-eval(parse(text=paste('Sample_Shapefile@data$', Attribute_ID, sep='')))
    
    # write the kml to disk
    if (class(smp_ll)[1]=='SpatialPolygonsDataFrame'){
  
    kmlPolygons2(Sample_Shapefile, kmlFileName=out_path, Pname=Attribute_ID)
    
    }
    
    if (class(smp_ll)[1]=='SpatialPointsDataFrame'){
      
      kmlPoints(smp_ll, out_path, name=kml_labels)
      
    }
  }
  

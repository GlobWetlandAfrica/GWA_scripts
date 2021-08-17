##load_vector_using_rgdal
##[Accuracy Assessment]=group

##Classified_Map=raster
##Validation_Samples=vector
##Validation_Label_Field= Field Validation_Samples
##Unweighted_Error_Matrix=output table
##Area_Weighted_Error_Matrix=output table
##Unbiased_Area_Estimates=output table



library(rpanel)
library(tcltk2)

r_path <- file.path(Sys.getenv("USERPROFILE"), ".qgis2", "processing", "rscripts", "GWA_TBX", fsep="\\")
fun_path <- paste(r_path, '\\aa_card.R', sep='')
source(fun_path)


# function for calculating accuracy statistics from an erroe matrix table:

# the input table should be arranged so that the reference are the columns and map are rows

acc_stats <- function(acc_table){

d <- diag(acc_table)
rs <- rowSums(acc_table)
cs <- colSums(acc_table)
pa <- d / cs * 100
ua <- d / rs * 100

oa <- sum(d) / sum(acc_table) * 100

nrws <- nrow(acc_table)

stats <- vector(mode="numeric", length = nrws)
stats <- NA

oa2 <- c(rep(NA, nrws-1), oa)

accs <- round(cbind(stats, cs, rs, pa, ua, oa2), 3)

res_table <- cbind(acc_table, accs)

return(res_table)

}


# get the frequency of pixels in the raster:

panel <- rp.control(title = "Progess Message. . .", size = c(500, 50))
rp.text(panel, "Calculating raster class areas. . .", font="Arial", pos = c(10, 10), title = 'bottom', name = 'prog_panel')
freq_t <- getValues(Classified_Map)
frq <- table(freq_t)
rp.control.dispose(panel)

class_ints <- names(frq)


mess_text <- paste0('IMPORTANT: "No Data" values must not be included below.\n\nNumber of classes detected = ', length(class_ints), '\nWith raster class values of =', (paste(class_ints, collapse=", ")),
'\n\nIs this as you expect?\n\nIf this is correct, choose Yes to continue.\nIf there are unwanted classes or No Data values included above, choose No')

class_answer <- tk_messageBox(type = 'yesno',
message = mess_text, caption = "Map classes check. . .")

if (class_answer == 'no'){

unwant_text <- paste0('You must reclassify all unwanted class values to "No Data" and try again.')

tk_messageBox(type = 'ok', message = unwant_text, caption = "Please reclassify raster. . .", icon = 'error')
stop("Please reclassify raster.")
}


# get the class weights
prp <- frq / sum(frq)


# first check that the raster units are in meters
coord <- as.character(crs(Classified_Map))
unit_check <- '+units=m'
check_unit <- grep(unit_check, coord)

if (identical(check_unit, integer(0))){

# print error message and stop
unit_text <- paste0('Error: Pixel resolution units must be in meters.',
'\nReproject raster so units are in meters and try again.')

tk_messageBox(type = 'ok', message = unit_text, caption = "Change raster units to meters. . .", icon = 'error')
stop("Please change raster units to meters.")
}


# get pixel resolution
reso <- res(Classified_Map)

# get total area in hectare (units are pre-checked to be in meters)
tarea <- sum(frq) * (reso[1] * reso[2]) / 10000

# get class area proportions
area_pro <- tarea * prp


# extract map values and combine with validation values and run accuracy assessment:

# get map values
mapv <- extract(Classified_Map, Validation_Samples)

# get validation values
valv <- Validation_Samples[[Validation_Label_Field]]

# join in a data.frame
dt <- as.data.frame(cbind(valv, mapv))

# run accuracy assessement
acc_ass <- aa_card(dt, w=prp, confusion_matrix = FALSE)


# get unbiased area estimates:
area_est <- acc_ass$area


# check if pixel area classes matches the unbiased area class order
order_check <- identical(as.numeric(names(area_pro)), area_est$class)

if (order_check == FALSE){

class_order <- match(area_est$class, as.numeric(names(area_pro)))
area_pro <- area_pro[class_order]

}

# area estimates
arest <- cbind(acc_ass$area[,1], round(as.numeric(area_pro), 2), round((acc_ass$area[,2:3] * tarea), 2))
colnames(arest) <- c('Class', 'Classified map area', 'Unbiased area estimate', 'Confidence interval (95%)')
arest$units <- 'ha'

Unbiased_Area_Estimates <- arest


# get unweighted error matrix and stats:

err_mat <- acc_ass$cm
col_nms <- paste0('ref. class ', colnames(err_mat))
row_nms <- paste0('map class ', rownames(err_mat))

# get stats
err_stats <- as.data.frame(acc_stats(err_mat))

rownames(err_stats) <- row_nms
colnames(err_stats) <- c(col_nms, '', 'Col. totals', 'Row totals', 'Prod. Acc', 'Users Acc', 'Overall Acc')

Unweighted_Error_Matrix <- err_stats


# get weighted error matrix and stats:

werr_mat <- round(acc_ass$cmp, 5)

# get stats
werr_stats <- as.data.frame(acc_stats(werr_mat))

# 95% confidence intervals of users and producers accuracy, and overall accuracy
ua_pa_95 <- acc_ass$stats[,6:7] * 1.96 * 100
oa_95 <- acc_ass$accuracy[2] * 1.96 * 100 * 100
oa_95 <- c(rep(NA, nrow(werr_stats)-1), oa_95)

werr_stats <- cbind(werr_stats, ua_pa_95, oa_95)

rownames(werr_stats) <- row_nms
colnames(werr_stats) <- c(col_nms, '', 'Col. totals', 'Row totals', 'Prod. Acc', 'Users Acc', 'Overall Acc', 'Prod. Acc 95% CI', 'Users Acc 95% CI', 'Overall Acc 95% CI')

Area_Weighted_Error_Matrix <- werr_stats

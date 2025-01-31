#
# ******************************************************************************
# Gonzalo M. Diaz
# MINISTERIO DE DEFENSA - Servicio Meteorologico Nacional
# Buenos Aires, 04.09.2020
#
# ******************************************************************************
# Paso 01 -> De la operatividad del pronóstico hidrológico con VIC + routeo
#            Interpolación Inverse-distance weighted (IDW) a los datos
#            SQPE-OBS-v0.2
# ******************************************************************************
# Script que realiza interpolación de las variables de precipitación de
# SQPE-OBS-v0.2 en su resolución espacial de 0.1°. Se setean las RUTAS de los
# archivos de entrada y de salida.
# ******************************************************************************
rm(list=ls())
suppressMessages(library("gstat"))
suppressMessages(library("sp"))
suppressMessages(library("raster"))
################################################################################
#################################### RUTAS #####################################
path.data   <- "/ms-36/QPE/Panel/app_est_prcp/"
path.grilla <- "/data/oper-hidro/VIC/Basins/Interp_grid/"
###
### UBICACION DE LAS SALIDAS DE GFS: Interpoladas
path.salida.PP <- "/ms-36/hidro/datos/Precipitacion/Estimada/SQPE-OBS-v0.2/Interpolada/CP/0.125/"
###
################################################################################
ini.data <- as.Date(Sys.Date() - 2)
fin.data <- as.Date(Sys.Date() - 2)

################################### MAIN #######################################

for(j in 0:as.numeric(fin.data-ini.data)){
  fecha.a.interpolar <- ini.data + j
  dia <- format(fecha.a.interpolar, format="%d")
  mes <- format(fecha.a.interpolar, format="%m")
  ano <- format(fecha.a.interpolar, format="%Y")
  
  ################################################################################
  ############### SE ABRE ARCHIVO CON GRILLA A INTERPOLAR DE VIC #################
  grilla <- read.table(paste0(path.grilla, "grid0.125.txt"))
  colnames(grilla) <- c("lon", "lat")
  ################################################################################
  
  archivo.a.abrir <- paste0(path.data, paste0("Ajuste_", ano, mes, dia, ".tif"))
  
  print(archivo.a.abrir)

  data.a.interpolar <- raster(archivo.a.abrir)
  data.a.interpolar <- as.data.frame(rasterToPoints(data.a.interpolar)) ; colnames(data.a.interpolar) <- c("lon", "lat", "pp")
  
  # elimina NA del data frame que molestan para la interpolación de IDW
  data.a.interpolar <- na.omit(data.a.interpolar)
   
  coordinates(data.a.interpolar) <- c("lon", "lat")
  coordinates(grilla) <- c("lon", "lat")
  gridded(grilla) <- TRUE
  
  data.a.interpolar[-is.na(data.a.interpolar$pp), "pp"]
    
  ###################################################################
  # Cálculo de IDW con el paquete gstat
  ###################################################################
  idw.out <- idw(pp ~ 1 , data.a.interpolar , grilla , idp = 4.0, na.action = na.omit)
  ###################################################################
  ###################################################################

  ubic <- as.data.frame(idw.out@coords)
  intp <- as.data.frame(idw.out$var1.pred)
  data <- cbind(ubic, intp)
    
  ###################################################################
  # Armado de raster para su exportación en formato tif
  ###################################################################
  pp       <- matrix(data$`idw.out$var1.pred`, ncol = 192, byrow = TRUE)
  Longitud <- seq(min(data$lon), max(data$lon), by = 0.125)
  Latitud  <- seq(min(data$lat), max(data$lat), by = 0.125)
  crs.ll   <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
  pp.raster.invert <- raster::raster(pp, 
                                     xmn = range(Longitud)[1], xmx = range(Longitud)[2], 
                                     ymn = range(Latitud)[1], ymx = range(Latitud)[2],
                                     crs = CRS(crs.ll))
  pp.raster  <- raster::flip(x = pp.raster.invert, direction = 'y')
  ###################################################################
  ###################################################################
  
  ###################################################################
  # Exportación de los datos generados por IDW en formato tif
  ###################################################################
  writeRaster(pp.raster, paste0(path.salida.PP, "SQPE-OBS-v0.2_pp(i)_", ano, mes, dia, ".tif"), overwrite = TRUE)
  ###################################################################
  ###################################################################
}


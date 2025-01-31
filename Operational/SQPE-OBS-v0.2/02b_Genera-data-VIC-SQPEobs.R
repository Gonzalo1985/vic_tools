#
# ---------------------------------------------------------------------------------#
# Gonzalo M. Diaz
# MINISTERIO DE DEFENSA - Servicio Meteorologico Nacional, Buenos Aires, 08.09.2020
# ----
# ---------------------------------------------------------------------------------#
# Paso 02 -> De la operatividad del pronóstico hidrológico con VIC + routeo
#            Genera archivos "data" con precipitación Estimada SQPE-OBS-v0.1 para
#            leer por el VIC como archivos de entrada
# ---------------------------------------------------------------------------------#
# Script que lee archivos interpolados de distintas variables (PP, Tmax, Tmin y V):
#
# . La variable PP es obtenida de la estimación de lluvia SQPE-OBS-v0.2
#
# . Una vez leídos los datos se ordenan y se generan archivos de texto para cada
# punto de simulación del modelo VIC. El formato de los archivos debe ser uno por
# punto y en su interior tiene una cantidad de columnas igual a la cantidad de
# variables correspondientes.
# ---------------------------------------------------------------------------------

# --------------------------------------------------------------------------------#
# -------------- CARGA DE LIBRERIAS NECESARIAS y LIMPIEZA Environment ----
rm(list=ls())
suppressMessages(library("dplyr"))
suppressMessages(library("raster"))
suppressMessages(library("lubridate"))
# ---------------------------------------------------------------------------------

# ------------------------ SETEO DE PARAMETROS ----
source('/home/gdiaz/Documentos/VIC+route/SQPE-OBS-v0.2/02a_Control-file-param-SQPEobs.R')
# ---------------------------------------------------------------------------------

# --------------------------------------------------------------------------------#
# ----------------------------------- RUTAS ----
### UBICACION DE LOS DATOS INTERPOLADOS A LEER y SECCION PRONOSTICO
path.data.PP   <- "/ms-36/hidro/datos/Precipitacion/Estimada/SQPE-OBS-v0.2/Interpolada/CP/0.125/"
path.data.Tmax <- "/ms-36/hidro/datos/Temperatura/Observada/Interpolada/CP/"
path.data.Tmin <- "/ms-36/hidro/datos/Temperatura/Observada/Interpolada/CP/"
path.data.V    <- "/ms-36/hidro/datos/Viento/Maximo/Interpolada/CP/"
path.data.Vmed <- "/ms-36/hidro/datos/Viento/Medio/Interpolada/CP/"

### UBICACION DEL ARCHIVO DE SUELO DE LA CUENCA y GRILLA DE INTERPOLACION
path.suelo <- "/data/oper-hidro/VIC/Parameter_Files/PF_VIC/SQPE-OBS-v0.2/"
path.grid <- "/data/oper-hidro/VIC/Basins/Interp_grid/"

### UBICACION DE LOS DATOS DE SALIDA: data...
path.salida <- "/data/oper-hidro/VIC/Inputs/In_VIC_SQPE-OBS-v0.2/"
# ---------------------------------------------------------------------------------




# ---------------------------------------------------------------------------------#
# ----- SE ABREN ARCHIVOS DE INTERES y SE ESCRIBE "param_control_file.txt" ----
basin <- read.table(paste0(path.suelo, "soil_file_", param4.s, ".prn"))

#coord.nueva <- read.table(paste0(path_grid, "grid0.125-nuevagrilla.txt"))
coord <- read.table(paste0(path.grid, param5.s, ".txt"))

colnames(fe) <- c("day.beg.sim", "mon.beg.sim", "yr.beg.sim",
                  "day.end.sim", "mon.end.sim", "yr.end.sim",
                  "day.beg.frc", "mon.beg.frc", "yr.beg.frc",
                  "day.end.frc", "mon.end.frc", "yr.end.frc",
                  "last.day.mon", "last.month", "last.year", "soil.file")

write.table(t(fe),
            paste0(path.suelo, "param_control_file.txt"),
            row.names = TRUE, col.names = FALSE, sep="\t")
# ---------------------------------------------------------------------------------


# ---------------------------------------------------------------------------------#
# ------- DEFINICION DEL LAPSO DE CORRIDA QUE SE REALIZARA P/EL MODELO ----
dist.dates <- length(seq(from = date1.sqpe, to = date2.sqpe, by = 'day')) + 1
# ---------------------------------------------------------------------------------


# ---------------------------------------------------------------------------------#
# ------- DEFINICION DEL PARAMETRO date.param Y CARGA DE COORDENADAS ----
date.param <- date1.sqpe
data.PP    <- coord[, 1:2] ; data.Tmin <- coord[, 1:2]
data.Tmax  <- coord[, 1:2] ; data.V    <- coord[, 1:2]
# ---------------------------------------------------------------------------------


# ---------------------------------------------------------------------------------#
# "for" que abre los datos interpolados de las variables de entrada (PP, Tmax,
# Tmin e Int Viento) y se guardan en 4 matrices separadas junto con las posicio-
# nes de cada punto (lon/lat). CADA ARCHIVO ES UN DIA!!
for (i in 2:dist.dates){
  date.aux <- date.param + i - 2
  dia.aux  <- format(date.aux, format="%d")
  mes.aux  <- format(date.aux, format="%m")
  ano.aux  <- format(date.aux, format="%y")
  ano.aux.completo  <- format(date.aux, format="%Y")
  
  print(paste("Se abre el archivo del dia...", date.aux))
  
  data.PP.aux <- raster(paste0(path.data.PP, "SQPE-OBS-v0.2_pp(i)_",
                               ano.aux.completo, mes.aux, dia.aux, ".tif"))
  
  # se convierte a tabla los datos de precipitación
  data.PP.aux <- cbind(coord, extract(data.PP.aux, coord))
  colnames(data.PP.aux) <- c("V1", "V2", "V3")
  
  data.PP.aux[data.PP.aux$V3 < 0] <- 0   # se eliminan los valores <0 de la interpolación
  
  data.Tmin.aux <- read.table(paste0(path.data.Tmin, ano.aux.completo, "/Tmin(i)_",
                                     ano.aux, mes.aux, "_dia_", dia.aux, ".txt"))
  
  data.Tmax.aux <- read.table(paste0(path.data.Tmax, ano.aux.completo, "/Tmax(i)_",
                                     ano.aux, mes.aux, "_dia_", dia.aux, ".txt"))
  

  #data.V.aux <- read.table(paste0(path.data.Vmed, "Vm(i)_",
  #                                 ano.aux, mes.aux, "_dia_", dia.aux, ".txt"))
  
  data.V.aux <- read.table(paste0(path.data.V, "V(i)_",
                                  ano.aux, mes.aux, "_dia_", dia.aux, ".txt"))
  
  data.V.aux <- data.V.aux / 2          # se hace el paso de unidades de kt a m/seg
  
  data.PP   <- cbind(data.PP, data.PP.aux[, 3])
  data.Tmin <- cbind(data.Tmin, data.Tmin.aux[, 3])
  data.Tmax <- cbind(data.Tmax, data.Tmax.aux[, 3])
  data.V    <- cbind(data.V, data.V.aux[, 3])
}
# ---------------------------------------------------------------------------------




# ---------------------------------------------------------------------------------#
# completa los últimos días del último mes de simulación para que el modelo de 
# routeo pueda correr. Lo completa con 1 en todas las posiciones (lat/lon)
if (param6.s == "fuerza_gfs"){
  num.uR <- as.integer(format(date5.sqpe, format="%d")) - as.integer(format(date4.sqpe, format="%d"))
  Mtx.uR <- matrix(1, nrow(data.PP), num.uR)
}

if (param6.s == "presente"){
  num.uR <- as.integer(format(date5.sqpe, format="%d")) - as.integer(format(date2.sqpe, format="%d"))
  #Mtx.uR.nueva <- matrix(1, nrow(data.PP), num.uR)
  Mtx.uR <- matrix(1, nrow(data.Tmin), num.uR)
}

data.PP   <- cbind(data.PP, Mtx.uR)
data.Tmin <- cbind(data.Tmin, Mtx.uR)
data.Tmax <- cbind(data.Tmax, Mtx.uR)
data.V    <- cbind(data.V, Mtx.uR)
# ---------------------------------------------------------------------------------


# ---------------------------------------------------------------------------------#
# "for" que va buscando las posiciones (lat/lon) de la matriz "basin" en las ma-
# trices de los datos ("data.PP", "data.Tmax", "data.Tmin" y "data.V"). Luego,
# por cada loop del "for" genera los archivos data para cada punto de la cuenca
for (j in 1:nrow(basin)){
  print(j)
  pos.lon <- which(data.PP[, 1] == basin[j, 4])
  pos.lat <- which(data.PP[, 2] == basin[j, 3])
  row.aux <- intersect(pos.lon, pos.lat)
  Mx.PP <- data.PP[row.aux, 3:ncol(data.PP)]
  
  pos.lon <- which(data.Tmax[,1] == basin[j,4])
  pos.lat <- which(data.Tmax[,2] == basin[j,3])
  row.aux <- intersect(pos.lon, pos.lat)
  Mx.Tmax <- data.Tmax[row.aux, 3:ncol(data.Tmax)]
  
  pos.lon <- which(data.Tmin[,1] == basin[j,4])
  pos_lat <- which(data.Tmin[,2] == basin[j,3])
  row.aux <- intersect(pos.lon, pos.lat)
  Mx.Tmin <- data.Tmin[row.aux, 3:ncol(data.Tmin)]
  
  pos.lon <- which(data.V[,1] == basin[j,4])
  pos.lat <- which(data.V[,2] == basin[j,3])
  row.aux <- intersect(pos.lon, pos.lat)
  Mx.V <- data.V[row.aux, 3:ncol(data.V)]
  
  data <- cbind(t(Mx.PP), t(Mx.Tmax), t(Mx.Tmin), t(Mx.V))
  data <- round(data, digits = 3)
  
  print(paste("Se escribe el archivo data de...", basin[j, 3], basin[j, 4]))
  
  write.table(data,
              paste(path.salida, "data_", basin[j, 3], "_", basin[j, 4], sep=""),
              row.names = FALSE, col.names = FALSE, sep="\t")
}
# ---------------------------------------------------------------------------------





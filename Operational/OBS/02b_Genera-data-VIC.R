#
# ---------------------------------------------------------------------------- #
# Gonzalo M. Diaz
# MINISTERIO DE DEFENSA - Servicio Meteorologico Nacional
# Buenos Aires, 27.07.2016
# ----
# ---------------------------------------------------------------------------- #
# Paso 02 -> De la operatividad del Modelo VIC + routeo
#            Genera archivos 'data' para que VIC lea como archivos de entrada
# ---------------------------------------------------------------------------- #
# Script que lee archivos interpolados de distintas variables (PP, Tmax, Tmin y
# V). Una vez leídos los datos se ordenan y se generan archivos de texto para
# cada punto de simulación del modelo VIC. El formato de los archivos debe ser
# uno por punto y en su interior tiene una cantidad de columnas igual a la can-
# tidad de variables correspondientes.
# ---------------------------------------------------------------------------- #

# ------------------------------------------------------------------------------
# -------------- CARGA DE LIBRERIAS NECESARIAS y LIMPIEZA Environment ----
rm(list=ls())
suppressMessages(library("lubridate"))
suppressMessages(library("dplyr"))
suppressMessages(library("vroom"))
# ------------------------------------------------------------------------------

# ------------------------ SETEO DE PARAMETROS ----
source('/home/gdiaz/Documentos/VIC+route/OBS/02a_Control-file-param.R')
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# ----------------------------------- RUTAS ----
### UBICACION DE LOS DATOS INTERPOLADOS A LEER y SECCION PRONOSTICO
path.data.PP   <- "/ms-36/hidro/datos/Precipitacion/Observada/Interpolada/CP/"
path.data.Tmax <- "/ms-36/hidro/datos/Temperatura/Observada/Interpolada/CP/"
path.data.Tmin <- "/ms-36/hidro/datos/Temperatura/Observada/Interpolada/CP/"
path.data.V    <- "/ms-36/hidro/datos/Viento/Maximo/Interpolada/CP/"
path.data.Vmed <- "/ms-36/hidro/datos/Viento/Medio/Interpolada/CP/"
path.prono     <- "/home/gdiaz/Documentos/VIC+route/FRCST/GFS/"

### UBICACION DEL ARCHIVO DE SUELO DE LA CUENCA y GRILLA DE INTERPOLACION
path.suelo <- "/data/oper-hidro/VIC/Parameter_Files/PF_VIC/OBS/"
path.grid <- "/data/oper-hidro/VIC/Basins/Interp_grid/"

### UBICACION DE LOS DATOS DE SALIDA: data...
path.salida <- "/data/oper-hidro/VIC/Inputs/In_VIC/"
# ------------------------------------------------------------------------------




# ------------------------------------------------------------------------------
# ----- SE ABREN ARCHIVOS DE INTERES y SE ESCRIBE "param_control_file.txt" ----
basin <- read.table(paste0(path.suelo, "soil_file_", param4, ".prn"))

coord <- read.table(paste0(path.grid, param5, ".txt"))

#write.table(fe, paste0(path.suelo, "param_control_file.txt"),
#            row.names = FALSE, col.names = FALSE, sep="\t")

colnames(fe) <- c("day.beg.sim", "mon.beg.sim", "yr.beg.sim",
                  "day.end.sim", "mon.end.sim", "yr.end.sim",
                  "day.beg.frc", "mon.beg.frc", "yr.beg.frc",
                  "day.end.frc", "mon.end.frc", "yr.end.frc",
                  "last.day.mon", "last.month", "last.year", "soil.file")

write.table(t(fe),
            paste0(path.suelo, "param_control_file.txt"),
            row.names = TRUE, col.names = FALSE, sep="\t")
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# ------- DEFINICION DEL LAPSO DE CORRIDA QUE SE REALIZARA P/EL MODELO ----
dist.dates <- length(seq(from = date1, to = date2, by = 'day')) + 1
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# ------- DEFINICION DEL PARAMETRO date.param Y CARGA DE COORDENADAS ----
date.param <- date1
data.PP <- coord[,1:2] ; data.Tmin <- coord[,1:2]
data.Tmax <- coord[,1:2] ; data.V <- coord[,1:2]
# ------------------------------------------------------------------------------


# ---------------------------------------------------------------------------- #
# "for" que abre los datos interpolados de las variables de entrada (PP, Tmax,
# Tmin e Int Viento) y se guardan en 4 matrices separadas junto con las posicio-
# nes de cada punto (lon/lat). CADA ARCHIVO ES UN DIA!!
for (i in 2:dist.dates){
  date.aux <- date.param + i - 2
  dia.aux <- format(date.aux, format="%d")
  mes.aux <- format(date.aux, format="%m")
  ano.aux <- format(date.aux, format="%y")
  ano.aux.long <- format(date.aux, format="%Y")
  
  if (i == 2) {print(paste("El primer archivo que se abre es del día ...",
                           date.aux))}
  
  if (i == dist.dates) {print(paste("El último archivo que se abre es del día ...",
                                    date.aux))}
  
  data.PP.aux <- read.table(paste0(path.data.PP, ano.aux.long, "/PP(i)_",
                                   ano.aux, mes.aux, "_dia_", dia.aux, ".txt"))
  
  #data.PP.aux <- vroom(paste0(path.data.PP, ano.aux.long, "/PP(i)_",
  #                            ano.aux, mes.aux, "_dia_", dia.aux, ".txt"),
  #                     col_names = c("V1", "V2", "V3"))
  
  data.PP.aux[data.PP.aux < 0] <- 0   # se eliminan los valores <0 de la interpolación
  
  data.Tmin.aux <- read.table(paste0(path.data.Tmin, ano.aux.long, "/Tmin(i)_",
                                     ano.aux, mes.aux, "_dia_", dia.aux, ".txt"))
  
  #data.Tmin.aux <- vroom(paste0(path.data.Tmin, ano.aux.long, "/Tmin(i)_",
  #                              ano.aux, mes.aux, "_dia_", dia.aux, ".txt"),
  #                       col_names = c("V1", "V2", "V3"))
  
  data.Tmax.aux <- read.table(paste0(path.data.Tmax, ano.aux.long, "/Tmax(i)_",
                                     ano.aux, mes.aux, "_dia_", dia.aux, ".txt"))
  
  
  #data.Tmax.aux <- vroom(paste0(path.data.Tmax, ano.aux.long, "/Tmax(i)_",
  #                              ano.aux, mes.aux, "_dia_", dia.aux, ".txt"),
  #                       col_names = c("V1", "V2", "V3"))
  
  #if(ano.aux == "17" && mes.aux == "04")
  #{data.V.aux <- read.table(paste0(path.data.Vmed, "Vm(i)_",
  #                                 ano.aux, mes.aux, "_dia_", dia.aux, ".txt"))} else
  data.V.aux <- read.table(paste0(path.data.V, "V(i)_",
                                  ano.aux, mes.aux, "_dia_", dia.aux, ".txt"))
  
  data.V.aux <- data.V.aux/2          # se hace el paso de unidades de kt a m/seg
  
  data.PP   <- cbind(data.PP, data.PP.aux[,3])
  data.Tmin <- cbind(data.Tmin, data.Tmin.aux[,3])
  data.Tmax <- cbind(data.Tmax, data.Tmax.aux[,3])
  data.V    <- cbind(data.V, data.V.aux[,3])
}
# ------------------------------------------------------------------------------

# ---------------------------------------------------------------------------- #
# -------- SE UNEN LOS DATOS DE SALIDA DEL MODELO A LAS OBSERVACIONES ----
source(paste0(path.prono, '04_une-obs-prono.R'))
# ------------------------------------------------------------------------------



# ---------------------------------------------------------------------------- #
# completa los últimos días del último mes de simulación para que el modelo de 
# routeo pueda correr. Lo completa con 1 en todas las posiciones (lat/lon)
if (param6 == "fuerza_gfs"){
  num.uR <- as.integer(format(date5, format="%d")) - as.integer(format(date4, format="%d"))
  Mtx.uR <- matrix(data = 1, nrow = nrow(data.PP), ncol = num.uR)
}

if (param6 == "presente"){
  num.uR <- as.integer(format(date5, format="%d")) - as.integer(format(date2, format="%d"))
  #Mtx.uR.nueva <- matrix(1, nrow(data.PP), num.uR)
  Mtx.uR <- matrix(1, nrow(data.Tmin), num.uR)
}

data.PP   <- cbind(data.PP, Mtx.uR)
data.Tmin <- cbind(data.Tmin, Mtx.uR)
data.Tmax <- cbind(data.Tmax, Mtx.uR)
data.V    <- cbind(data.V, Mtx.uR)
# ------------------------------------------------------------------------------


# ---------------------------------------------------------------------------- #
# "for" que va buscando las posiciones (lat/lon) de la matriz "basin" en las ma-
# trices de los datos ("data.PP", "data.Tmax", "data.Tmin" y "data.V"). Luego,
# por cada loop del "for" genera los archivos data para cada punto de la cuenca
for (j in 1:nrow(basin)){
  print(j)
  pos.lon <- which(data.PP[,1] == basin[j,4])
  pos.lat <- which(data.PP[,2] == basin[j,3])
  row.aux <- intersect(pos.lon, pos.lat)
  Mx.PP <- data.PP[row.aux, 3:ncol(data.PP)]
  
  pos.lon <- which(data.Tmax[,1] == basin[j,4])
  pos.lat <- which(data.Tmax[,2] == basin[j,3])
  row.aux <- intersect(pos.lon,pos.lat)
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
  
  print(paste("Se escribe el archivo data de...", basin[j,3], basin[j,4]))
  
  write.table(data,
              paste(path.salida, "data_", basin[j,3], "_", basin[j,4], sep=""),
              row.names = FALSE, col.names = FALSE, sep="\t")
}
# ------------------------------------------------------------------------------





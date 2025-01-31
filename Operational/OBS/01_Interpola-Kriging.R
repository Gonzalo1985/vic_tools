#
# ---------------------------------------------------------------------------------#
# Gonzalo M. Diaz
# MINISTERIO DE DEFENSA - Servicio Meteorologico Nacional, Buenos Aires, 14.12.2016 
# ----
# ---------------------------------------------------------------------------------#
# Paso 01 -> De la operatividad del Modelo VIC + routeo
#            Kriging sobre las observaciones de la red de estaciones del SMN
# ---------------------------------------------------------------------------------#
# Se debe setear las RUTAS de las ubicaciones de los archivos a leer y de los datos
# de salida (datos interpolados a grilla). En la sección PARAMETROS A MODIFICAR se
# debe indicar entre que lat/lon se desea realizar el Kriging y además el paso es-
# pacial
# ---------------------------------------------------------------------------------


# --------------------------------------------------------------------------------#
# ---- Limpieza del Environment y carga de librerias ----
rm(list=ls())
suppressMessages(library("automap"))
suppressMessages(library("raster"))
suppressMessages(library("mapdata"))
# ---------------------------------------------------------------------------------


# ---------------------------------------------------------------------------------
# ---- Rutas de datos de entrada y salida ----
### UBICACION DE LOS DATOS DE ENTRADA
path.data <- "/ms-36/agro/bases/"

### UBICACION DE LOS DATOS DE SALIDA: Interpolados
path.salida.PP   <- "/ms-36/hidro/datos/Precipitacion/Observada/Interpolada/CP/"
path.salida.Tmax <- "/ms-36/hidro/datos/Temperatura/Observada/Interpolada/CP/"
path.salida.Tmin <- "/ms-36/hidro/datos/Temperatura/Observada/Interpolada/CP/"
path.salida.V    <- "/ms-36/hidro/datos/Viento/Maximo/Interpolada/CP/"
path.salida.Vmed <- "/ms-36/hidro/datos/Viento/Medio/Interpolada/CP/"
# ---------------------------------------------------------------------------------


# ---------------------------------------------------------------------------------
# ----------------------------- PARAMETROS A MODIFICAR ----
xmn.int <- -66.8125 ; xmx.int <- -42.9375 #-43.5625
ymn.int <- -37.9375 ; ymx.int <- -14.0625
paso <- 0.125
# ---------------------------------------------------------------------------------




ok <- c()


# ---------------------------------------------------------------------------------
# --------------- ARMADO DE LAS FECHAS PARA LEER LA BASE DE DATOS ----
fecha.hoy <- Sys.Date()
dia_str   <- format(fecha.hoy, format="%A")
ano       <- format(fecha.hoy, format="%y")


d.int.1 <- fecha.hoy - 4 ; d.int.2 <- fecha.hoy - 3 ; d.int.3 <- fecha.hoy - 2 ; d.int.4 <- fecha.hoy - 1
fecha.entrada.str <- c(as.character(d.int.1, format = "%Y-%m"),
                       as.character(d.int.2, format = "%Y-%m"),
                       as.character(d.int.3, format = "%Y-%m"),
                       as.character(d.int.4, format = "%Y-%m"))

ano.1 <- format(d.int.1, format="%y") ; ano.2 <- format(d.int.2, format="%y")
ano.3 <- format(d.int.3, format="%y") ; ano.4 <- format(d.int.4, format="%y")

ano.1.long <- format(d.int.1, format="%Y") ; ano.2.long <- format(d.int.2, format="%Y")
ano.3.long <- format(d.int.3, format="%Y") ; ano.4.long <- format(d.int.4, format="%Y")

mes.1 <- format(d.int.1, format="%m") ; mes.2 <- format(d.int.2, format="%m")
mes.3 <- format(d.int.3, format="%m") ; mes.4 <- format(d.int.4, format="%m")

dia.1 <- format(d.int.1, format="%d") ; dia.2 <- format(d.int.2, format="%d")
dia.3 <- format(d.int.3, format="%d") ; dia.4 <- format(d.int.4, format="%d")

ano.vector <- c(strtoi(ano.1), strtoi(ano.2), strtoi(ano.3), strtoi(ano.4))
ano.vector.long <- c(ano.1.long, ano.2.long, ano.3.long, ano.4.long)
mes.vector <- c(as.integer(mes.1), as.integer(mes.2), as.integer(mes.3), as.integer(mes.4))
dia.vector <- c(as.integer(dia.1), as.integer(dia.2), as.integer(dia.3), as.integer(dia.4))
# ---------------------------------------------------------------------------------

for(i in 1:length(mes.vector)){
  
  if(mes.vector[i] < 10 ){str.mes <- paste0("0",toString(mes.vector[i]))}
  if(mes.vector[i] >= 10){str.mes <- toString(mes.vector[i])}
  
  data.PP    <- read.table(paste0(path.data, fecha.entrada.str[i], "/", "ppr-",
                                  toString(ano.vector[i]), str.mes, ".txt"),
                           skip=1)
  
  data.Tmin  <- read.table(paste0(path.data, fecha.entrada.str[i], "/", "tmnr-",
                                  toString(ano.vector[i]), str.mes, ".txt"),
                           skip=1)
  
  data.Tmax  <- read.table(paste0(path.data, fecha.entrada.str[i], "/", "tmxr-",
                                  toString(ano.vector[i]), str.mes, ".txt"),
                           skip=1)
  
  data.V     <- read.table(paste0(path.data, fecha.entrada.str[i], "/", "vff-",
                                  toString(ano.vector[i]), str.mes, ".txt"),
                           skip=1)
  
  data.V.med <- read.table(paste0(path.data, fecha.entrada.str[i], "/", "vmff1-",
                                  toString(ano.vector[i]), str.mes, ".txt"),
                           skip=1)
  
  ###################################################################
  ### tratado de datos faltantes y de otros
  ###################################################################
  data.PP[data.PP==-1       ]    <- 0
  data.PP[data.PP==-99.9    ]    <- NA
  data.Tmin[data.Tmin==-99.9]    <- NA
  data.Tmax[data.Tmax==-99.9]    <- NA
  data.V[data.V==-99.9      ]    <- NA
  data.V[data.V ==-99       ]    <- NA
  data.V.med[data.V.med==-99.9]  <- NA
  # ----------------------------------------------------------------------------
  
  for(j in 1:5){
    if(j == 1) {DATA <- data.PP   }
    if(j == 2) {DATA <- data.Tmin }
    if(j == 3) {DATA <- data.Tmax }
    if(j == 4) {DATA <- data.V    }
    if(j == 5) {DATA <- data.V.med}

    DATA2 <- DATA[, 3:4]
    DATA2 <- cbind(DATA2, DATA[, dia.vector[i] + 4])
    colnames(DATA2) <- c("lon", "lat", "datos")
    
    ###################################################################
    # Cálculo de Kriging
    ###################################################################
    #source("/home/hidro/01.Interpolaciones/03_kriging-smn-meteofrance.R")
    #p <- kriging.smn.meteofrance(xmn.int = xmn.int, xmx.int = xmx.int,
    #                             ymn.int = ymn.int, ymx.int = ymx.int,
    #                             lons = DATA2[, 1], lats = DATA2[, 2],
    #                             zs = DATA2[, 3], paso = paso)
    
    if (j == 1) {aux.pp <- TRUE} else {aux.pp <- FALSE}
    
    source("/home/gdiaz/Documentos/VIC+route/OBS/00_kriging-smn.R")
    p <- kriging.smn(xmn.int = xmn.int, xmx.int = xmx.int,
                     ymn.int = ymn.int, ymx.int = ymx.int,
                     paso = paso, file = DATA2, es.pp = aux.pp)
    # --------------------------------------------------------------------------
    #ok <- rbind(ok, print(paste0("El maximo interpolado es ", max(p[,3]))))
    
    # --------------------------------------------------------------------------
    # Verificación de las precipitaciones en grilla generada con Kriging
    #if(j==1)
    #  {source('/home/hidro/VIC+route/VERIFICA-PARAMETROS/01_Verifica-pp-input.R')}
    # --------------------------------------------------------------------------
    
    if(dia.vector[i] < 10) {str.dia <- paste0("0",toString(dia.vector[i]))}
    if(dia.vector[i] >= 10){str.dia <- toString(dia.vector[i])}
    
     if(j==1) {write.table(p[, c("xo", "yo", "var1.pred")],
                           paste0(path.salida.PP, ano.vector.long[i],
                                  "/PP(i)_",
                                  toString(ano.vector[i]),
                                  str.mes,
                                  "_dia_", str.dia, ".txt"),
                           row.names = FALSE, col.names = FALSE, sep = "\t")}
     
     if(j==2) {write.table(p[, c("xo", "yo", "var1.pred")],
                           paste0(path.salida.Tmin, ano.vector.long[i],
                                  "/Tmin(i)_",
                                  toString(ano.vector[i]),
                                  str.mes,
                                  "_dia_", str.dia, ".txt"),
                           row.names = FALSE, col.names = FALSE, sep = "\t")}
     
     if(j==3) {write.table(p[, c("xo", "yo", "var1.pred")],
                           paste0(path.salida.Tmax, ano.vector.long[i],
                                  "/Tmax(i)_",
                                  toString(ano.vector[i]),
                                  str.mes,
                                  "_dia_", str.dia, ".txt"),
                           row.names = FALSE, col.names = FALSE, sep = "\t")}
     
     if(j==4) {write.table(p[, c("xo", "yo", "var1.pred")],
                           paste0(path.salida.V,
                                  "V(i)_",
                                  toString(ano.vector[i]),
                                  str.mes,
                                  "_dia_", str.dia, ".txt"),
                           row.names = FALSE, col.names = FALSE, sep = "\t")}
     
     if(j==5) {write.table(p[, c("xo", "yo", "var1.pred")],
                           paste0(path.salida.Vmed,
                                  "Vm(i)_",
                                  toString(ano.vector[i]),
                                  str.mes,
                                  "_dia_", str.dia, ".txt"),
                           row.names = FALSE, col.names = FALSE, sep = "\t")}
    # --------------------------------------------------------------------------
  }
}


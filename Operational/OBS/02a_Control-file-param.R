# ---------------------------------------------------------------------------- #
# ---------------------------------------------------------------------------- #
# ------------------------------- PARAMETROS ----

param1 <- 1 # 1: para correr el modelo hasta el día anterior al día de hoy 
#           # 2: para correr el modelo en rango específico (indicado en param2
#                y param3)

param2 <- "2012-01-01" # si param1 es 2, se debe indicar la fecha desde donde
#                        correr

param3 <- "2022-12-31" # si param1 es 2, se debe indicar la fecha hasta donde
#                        correr

param4 <- "calibradoSCEUA" # nombre del archivo de suelo en el cual buscar los
#                                                              puntos para generar los archivos data
# uruguay_cierre_CONCORDIA_2daCALIB_hastaCONCORDIA
# uruguay_ByMyA
# uruguay_ByMyA_4-7-4-1-1
# Cplata

param5 <- "grid0.125"     # nombre del archivo con coordenadas de interpolación


param6 <- "fuerza_gfs"    # fuerza_gfs: el modelo VIC es forzado por las salidas
#                                       del modelo de pronóstico (GFS)
                          # presente: el modelo VIC es forzado únicamente con las
#                                     observaciones
# ------------------------------------------------------------------------------
# ---------------------------------------------------------------------------- #



# ---------------------------------------------------------------------------- #
# ------------------ SI param1 = 1  Y  param6 = "fuerza_gfs" ----
if (param1 == 1 && param6 == "fuerza_gfs"){

  rango <- seq(Sys.Date()-1, length = 2, by = "-3 years")
  
  date1 <- rango[2] ; d1 <- 1 ; m1 <- month(date1) ; y1 <- year(date1) 
  date1 <- as.Date(paste0(y1,"-",m1,"-",d1))
  
  date2 <- rango[1] ; d2 <- day(date2) ; m2 <- month(date2) ; y2 <- year(date2)
  
  date3 <- rango[1] + 1 ; d3 <- day(date3) ; m3 <- month(date3) ; y3 <- year(date3)
  
  date4 <- rango[1] + 6 ; d4 <- day(date4) ; m4 <- month(date4) ; y4 <- year(date4)
  
  dia_aux <- d4 ; mes_aux <- m4 ; ano_aux <- y4 ; source('/home/gdiaz/Documentos/VIC+route/OBS/define-date_aux.R')
  date5 <- date_aux ; d5 <- day(date5) ; m5 <- month(date5) ; y5 <- year(date5)
  
  rango.graf <- c(date2 - 90, date2, date4)
  
  fe <- data.frame(C1=strtoi(d1),C2=strtoi(m1),C3=strtoi(y1),
                   C4=strtoi(d2),C5=strtoi(m2),C6=strtoi(y2),
                   C7=strtoi(d3),C8=strtoi(m3),C9=strtoi(y3),
                   C10=strtoi(d4),C11=strtoi(m4),C12=strtoi(y4),
                   C13=strtoi(d5),C14=strtoi(m5),C15=strtoi(y5),
                   C16=paste0("soil_file_",param4,".prn"))
}
# ---------------------------------------------------------------------------------

# --------------------------------------------------------------------------------#
# ------------------ SI param1 = 2  Y  param6 = "fuerza_gfs" ----
if (param1 == 2 && param6 == "fuerza_gfs"){
  
  date1 <- as.Date(param2) ; d1 <- 1 ; m1 <- month(date1) ; y1 <- year(date1)
  
  date2 <- as.Date(param3) ; d2 <- day(date2) ; m2 <- month(date2) ; y2 <- year(date2)
  
  rango <- seq(date2, date1, length = 2)
  
  date3 <- rango[1] + 1 ; d3 <- day(date3) ; m3 <- month(date3) ; y3 <- year(date3)
  
  date4 <- rango[1] + 6 ; d4 <- day(date4) ; m4 <- month(date4) ; y4 <- year(date4)
  
  dia_aux <- d4 ; mes_aux <- m4 ; ano_aux <- y4 ; source('/home/gdiaz/Documentos/VIC+route/OBS/define-date_aux.R')
  date5 <- date_aux ; d5 <- day(date5) ; m5 <- month(date5) ; y5 <- year(date5)
  
  rango.graf <- c(date2 - 90, date2, date4)
  
  fe <- data.frame(C1=strtoi(d1),C2=strtoi(m1),C3=strtoi(y1),
                   C4=strtoi(d2),C5=strtoi(m2),C6=strtoi(y2),
                   C7=strtoi(d3),C8=strtoi(m3),C9=strtoi(y3),
                   C10=strtoi(d4),C11=strtoi(m4),C12=strtoi(y4),
                   C13=strtoi(d5),C14=strtoi(m5),C15=strtoi(y5),
                   C16=paste0("soil_file_",param4,".prn"))
}
# ---------------------------------------------------------------------------------

# --------------------------------------------------------------------------------#
# ------------------ SI param1 = 1  Y  param6 = "presente" ----
if (param1 == 1 && param6 == "presente"){
  
  rango <- seq(Sys.Date()-1, length = 2, by = "-3 years")
  
  date1 <- rango[2] ; d1 <- 1 ; m1 <- month(date1) ; y1 <- year(date1) 
  date1 <- as.Date(paste0(y1,"-",m1,"-",d1))
  
  date2 <- rango[1] ; d2 <- day(date2) ; m2 <- month(date2) ; y2 <- year(date2)
  
  date3 <- rango[1] + 1 ; d3 <- day(date3) ; m3 <- month(date3) ; y3 <- year(date3)
  
  date4 <- rango[1] + 6 ; d4 <- day(date4) ; m4 <- month(date4) ; y4 <- year(date4)
  
  dia_aux <- d2 ; mes_aux <- m2 ; ano_aux <- y2 ; source('/home/gdiaz/Documentos/VIC+route/OBS/define-date_aux.R')
  date5 <- date_aux ; d5 <- day(date5) ; m5 <- month(date5) ; y5 <- year(date5)
  
  rango.graf <- c(date2 - 90, date2, date2)
  
  fe <- data.frame(C1=strtoi(d1),C2=strtoi(m1),C3=strtoi(y1),
                   C4=strtoi(d2),C5=strtoi(m2),C6=strtoi(y2),
                   C7=strtoi(d3),C8=strtoi(m3),C9=strtoi(y3),
                   C10=strtoi(d4),C11=strtoi(m4),C12=strtoi(y4),
                   C13=strtoi(d5),C14=strtoi(m5),C15=strtoi(y5),
                   C16=paste0("soil_file_",param4,".prn"))
}
# ---------------------------------------------------------------------------------

# --------------------------------------------------------------------------------#
# ------------------ SI param1 = 2  Y  param6 = "presente" ----
if (param1 == 2 && param6 == "presente"){
  
  date1 <- as.Date(param2) ; d1 <- 1 ; m1 <- month(date1) ; y1 <- year(date1)
  
  date2 <- as.Date(param3) ; d2 <- day(date2) ; m2 <- month(date2) ; y2 <- year(date2)
  
  rango <- seq(date2, date1, length = 2)
  
  date3 <- rango[1] + 1 ; d3 <- day(date3) ; m3 <- month(date3) ; y3 <- year(date3)
  
  date4 <- rango[1] + 6 ; d4 <- day(date4) ; m4 <- month(date4) ; y4 <- year(date4)
  
  dia_aux <- d2 ; mes_aux <- m2 ; ano_aux <- y2 ; source('/home/gdiaz/Documentos/VIC+route/OBS/define-date_aux.R')
  date5 <- date_aux ; d5 <- day(date5) ; m5 <- month(date5) ; y5 <- year(date5)
  
  rango.graf <- c(date2 - 90, date2, date2)
  
  fe <- data.frame(C1=strtoi(d1),C2=strtoi(m1),C3=strtoi(y1),
                   C4=strtoi(d2),C5=strtoi(m2),C6=strtoi(y2),
                   C7=strtoi(d3),C8=strtoi(m3),C9=strtoi(y3),
                   C10=strtoi(d4),C11=strtoi(m4),C12=strtoi(y4),
                   C13=strtoi(d5),C14=strtoi(m5),C15=strtoi(y5),
                   C16=paste0("soil_file_",param4,".prn"))
}
# ---------------------------------------------------------------------------------


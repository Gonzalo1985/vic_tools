# --------------------------------------------------------------------------------#
# --------------------------------------------------------------------------------#
# ------------------------------- PARAMETROS ----

param1.s <- 1 # 1: para correr el modelo hasta el día anterior al día de hoy 
              # 2: para correr el modelo en rango.sqpe específico (indicado en param2.s y param3.s)

param2.s <- "2015-01-01"     # si param1.s es 2, se debe indicar la fecha desde donde correr


param3.s <- "2020-12-31"     # si param1.s es 2, se debe indicar la fecha hasta donde correr


param4.s <- "calibradoSCEUA"  # nombre del archivo de suelo en el cual buscar los puntos
                             # en cuales basarse para generar los archivos data
# uruguay_ByMyA
# Cplata

param5.s <- "grid0.125"      # nombre del archivo con coordenadas de la interpolación


param6.s <- "presente"    # fuerza_gfs: el modelo VIC es forzado por las salidas del mo-
                          # delo de pronóstico (GFS)
                          # presente: el modelo VIC es forzado únicamente con las obser-
                          #           vaciones
# ---------------------------------------------------------------------------------
# --------------------------------------------------------------------------------#

# ------------------------------------------------------------------------------------------ #
# Función que se utiliza para definir el último día del mes que se simula en la corrida ----
define.ultimo.dia.mes <- function(dia_aux, mes.aux, ano_aux)
  {
   if (as.integer(mes_aux) == 1 | as.integer(mes_aux) == 3 | as.integer(mes_aux) == 5 | as.integer(mes_aux) == 7 | as.integer(mes_aux) == 8 | as.integer(mes_aux) == 10 | as.integer(mes_aux) == 12)
     {date_aux <- as.Date(paste0(ano_aux,"-",mes_aux,"-",as.integer(dia_aux)+(31-as.integer(dia_aux))))}
  
   if (as.integer(mes_aux) == 4 | as.integer(mes_aux) == 6 | as.integer(mes_aux) == 9 | as.integer(mes_aux) == 11)
     {date_aux <- as.Date(paste0(ano_aux,"-",mes_aux,"-",as.integer(dia_aux)+(30-as.integer(dia_aux))))}
  
   if (as.integer(mes_aux) == 2)
     {
      if (as.integer(ano_aux)%%4 == 0 & as.integer(ano_aux)%%100 != 0 | as.integer(ano_aux)%%400 == 0)
      {date_aux <- as.Date(paste0(ano_aux,"-",mes_aux,"-",as.integer(dia_aux)+(29-as.integer(dia_aux))))} else
        {date_aux <- as.Date(paste0(ano_aux,"-",mes_aux,"-",as.integer(dia_aux)+(28-as.integer(dia_aux))))}
     }
   return(date_aux)
  }
# ------------------------------------------------------------------------------------------




# --------------------------------------------------------------------------------#
# ------------------ SI param1.s = 1  Y  param6.s = "fuerza_gfs" ----
if (param1.s == 1 && param6.s == "fuerza_gfs"){

  rango.sqpe <- seq(as.Date("2020-05-01"), Sys.Date() - 2, length = 2)
  
  date1.sqpe <- rango.sqpe[1] ; d1 <- 1 ; m1 <- month(date1.sqpe) ; y1 <- year(date1.sqpe) 
  date1.sqpe <- as.Date(paste0(y1, "-", m1, "-", d1))
  
  date2.sqpe <- rango.sqpe[2] ; d2 <- day(date2.sqpe) ; m2 <- month(date2.sqpe) ; y2 <- year(date2.sqpe)
  
  date3.sqpe <- rango.sqpe[2] + 1 ; d3 <- day(date3.sqpe) ; m3 <- month(date3.sqpe) ; y3 <- year(date3.sqpe)
  
  date4.sqpe <- rango.sqpe[2] + 6 ; d4 <- day(date4.sqpe) ; m4 <- month(date4.sqpe) ; y4 <- year(date4.sqpe)
  
  dia_aux <- d4 ; mes_aux <- m4 ; ano_aux <- y4 ; date_aux <- define.ultimo.dia.mes(dia_aux, mes_aux, ano_aux)
  
  date5.sqpe <- date_aux ; d5 <- day(date5.sqpe) ; m5 <- month(date5.sqpe) ; y5 <- year(date5.sqpe)
  
  rango.sqpe.graf <- c(date2.sqpe - 90, date2.sqpe, date4.sqpe)
  
  fe <- data.frame(C1=strtoi(d1),C2=strtoi(m1),C3=strtoi(y1),
                   C4=strtoi(d2),C5=strtoi(m2),C6=strtoi(y2),
                   C7=strtoi(d3),C8=strtoi(m3),C9=strtoi(y3),
                   C10=strtoi(d4),C11=strtoi(m4),C12=strtoi(y4),
                   C13=strtoi(d5),C14=strtoi(m5),C15=strtoi(y5),
                   C16=paste0("soil_file_",param4.s,".prn"))
}
# ---------------------------------------------------------------------------------

# --------------------------------------------------------------------------------#
# ------------------ SI param1.s = 2  Y  param6.s = "fuerza_gfs" ----
if (param1.s == 2 && param6.s == "fuerza_gfs"){
  
  date1.sqpe <- as.Date(param2.s) ; d1 <- 1 ; m1 <- month(date1.sqpe) ; y1 <- year(date1.sqpe)
  
  date2.sqpe <- as.Date(param3.s) ; d2 <- day(date2.sqpe) ; m2 <- month(date2.sqpe) ; y2 <- year(date2.sqpe)
  
  rango.sqpe <- seq(date1.sqpe, date2.sqpe, length = 2)
  
  date3.sqpe <- rango.sqpe[2] + 1 ; d3 <- day(date3.sqpe) ; m3 <- month(date3.sqpe) ; y3 <- year(date3.sqpe)
  
  date4.sqpe <- rango.sqpe[2] + 6 ; d4 <- day(date4.sqpe) ; m4 <- month(date4.sqpe) ; y4 <- year(date4.sqpe)
  
  dia_aux<- d4 ; mes_aux <- m4 ; ano_aux <- y4 ; date_aux <- define.ultimo.dia.mes(dia_aux, mes_aux, ano_aux)
  
  date5.sqpe <- date_aux ; d5 <- day(date5.sqpe) ; m5 <- month(date5.sqpe) ; y5 <- year(date5.sqpe)
  
  rango.sqpe.graf <- c(date2.sqpe - 90, date2.sqpe, date4.sqpe)
  
  fe <- data.frame(C1=strtoi(d1),C2=strtoi(m1),C3=strtoi(y1),
                   C4=strtoi(d2),C5=strtoi(m2),C6=strtoi(y2),
                   C7=strtoi(d3),C8=strtoi(m3),C9=strtoi(y3),
                   C10=strtoi(d4),C11=strtoi(m4),C12=strtoi(y4),
                   C13=strtoi(d5),C14=strtoi(m5),C15=strtoi(y5),
                   C16=paste0("soil_file_",param4.s,".prn"))
}
# ---------------------------------------------------------------------------------

# --------------------------------------------------------------------------------#
# ------------------ SI param1.s = 1  Y  param6.s = "presente" ----
if (param1.s == 1 && param6.s == "presente"){
  
  rango.sqpe <- seq(as.Date("2020-05-01"), Sys.Date() - 2, length = 2)
  
  date1.sqpe <- rango.sqpe[1] ; d1 <- 1 ; m1 <- month(date1.sqpe) ; y1 <- year(date1.sqpe) 
  date1.sqpe <- as.Date(paste0(y1, "-", m1, "-", d1))
  
  date2.sqpe <- rango.sqpe[2] ; d2 <- day(date2.sqpe) ; m2 <- month(date2.sqpe) ; y2 <- year(date2.sqpe)
  
  date3.sqpe <- rango.sqpe[2] + 1 ; d3 <- day(date3.sqpe) ; m3 <- month(date3.sqpe) ; y3 <- year(date3.sqpe)
  
  date4.sqpe <- rango.sqpe[2] + 6 ; d4 <- day(date4.sqpe) ; m4 <- month(date4.sqpe) ; y4 <- year(date4.sqpe)
  
  dia_aux <- d2 ; mes_aux <- m2 ; ano_aux <- y2 ; date_aux <- define.ultimo.dia.mes(dia_aux, mes_aux, ano_aux)
  
  date5.sqpe <- date_aux ; d5 <- day(date5.sqpe) ; m5 <- month(date5.sqpe) ; y5 <- year(date5.sqpe)
  
  rango.sqpe.graf <- c(date2.sqpe - 90, date2.sqpe, date2.sqpe)
  
  fe <- data.frame(C1=strtoi(d1),C2=strtoi(m1),C3=strtoi(y1),
                   C4=strtoi(d2),C5=strtoi(m2),C6=strtoi(y2),
                   C7=strtoi(d3),C8=strtoi(m3),C9=strtoi(y3),
                   C10=strtoi(d4),C11=strtoi(m4),C12=strtoi(y4),
                   C13=strtoi(d5),C14=strtoi(m5),C15=strtoi(y5),
                   C16=paste0("soil_file_",param4.s,".prn"))
}
# ---------------------------------------------------------------------------------

# --------------------------------------------------------------------------------#
# ------------------ SI param1.s = 2  Y  param6.s = "presente" ----
if (param1.s == 2 && param6.s == "presente"){
  
  date1.sqpe <- as.Date(param2.s) ; d1 <- 1 ; m1 <- month(date1.sqpe) ; y1 <- year(date1.sqpe)
  
  date2.sqpe <- as.Date(param3.s) ; d2 <- day(date2.sqpe) ; m2 <- month(date2.sqpe) ; y2 <- year(date2.sqpe)
  
  rango.sqpe <- seq(date1.sqpe, date2.sqpe, length = 2)
  
  date3.sqpe <- rango.sqpe[2] + 1 ; d3 <- day(date3.sqpe) ; m3 <- month(date3.sqpe) ; y3 <- year(date3.sqpe)
  
  date4.sqpe <- rango.sqpe[2] + 6 ; d4 <- day(date4.sqpe) ; m4 <- month(date4.sqpe) ; y4 <- year(date4.sqpe)
  
  dia_aux <- d2 ; mes_aux <- m2 ; ano_aux <- y2 ; date_aux <- define.ultimo.dia.mes(dia_aux, mes_aux, ano_aux)
  
  date5.sqpe <- date_aux ; d5 <- day(date5.sqpe) ; m5 <- month(date5.sqpe) ; y5 <- year(date5.sqpe)
  
  rango.sqpe.graf <- c(date2.sqpe - 90, date2.sqpe, date2.sqpe)
  
  fe <- data.frame(C1=strtoi(d1),C2=strtoi(m1),C3=strtoi(y1),
                   C4=strtoi(d2),C5=strtoi(m2),C6=strtoi(y2),
                   C7=strtoi(d3),C8=strtoi(m3),C9=strtoi(y3),
                   C10=strtoi(d4),C11=strtoi(m4),C12=strtoi(y4),
                   C13=strtoi(d5),C14=strtoi(m5),C15=strtoi(y5),
                   C16=paste0("soil_file_",param4.s,".prn"))
}
# ---------------------------------------------------------------------------------


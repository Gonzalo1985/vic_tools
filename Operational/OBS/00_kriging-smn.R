#
# ---------------------------------------------------------------------------------#
# Gonzalo M. Diaz
# MINISTERIO DE DEFENSA - Servicio Meteorologico Nacional, Buenos Aires, 14.12.2016 
# ----
# ---------------------------------------------------------------------------------#
# --------------------------------------------------------------------------------------
# Descripcion:
# kriging.smn genera una interpolacion de Kriging automatico de los datos que se ingresen
# 
# Los datos deben estar en columnas:
#   1ra columna: longitud
#   2da columna: latitud
#   3ra columna: dato a interpolar
#
# Uso de la funcion:
# kriging.smn(xmn.int, xmx.int, ymn.int, ymx.int, paso, file, es.pp)
# --------------------------------------------------
# Los argumentos de entrada de la funcion son:
# xmn.int: longitud oeste del dominio a interpolar
# xmx.int: longitud este del dominio a interpolar
# ymn.int: latitud sur del dominio a interpolar
# ymx.int: latitud norte del dominio a interpolar
# paso: resolucion espacial a la cual interpolar (en grados)
# file: la matriz a interpolar en el formato indicado en la parte superior (lon|lat|dato a interpolar)
# es.pp: TRUE si la variable a interpolar es precipitacion, en su defecto FALSE
# ----------------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------
kriging.smn <- function(xmn.int, xmx.int, ymn.int, ymx.int, paso, file, es.pp) {

  suppressMessages(library("automap"))
  
  if(ncol(file) != 3){stop('El formato del archivo file es incorrecto', call. = FALSE)}

  file <- as.data.frame(file)                 # convierte el 'file' en data frame
  colnames(file) <- c("lon", "lat", "datos")  # nombre las columnas de 'file'
  
  if(es.pp == TRUE){file[file == -1] <- 0}    # reemplaza -1 por 0 si la variable a interpolar es precipitacion
  file[file == -99.9] <- NA                   # reemplaza -99.9 por NA

  # subset para la region de interes
  file <- file[which(file$lon > xmn.int & file$lon < xmx.int & file$lat > ymn.int & file$lat < ymx.int),]
  
  file <- na.omit(file)                       # omite los NA del file -> elimina filas con NA
  class(file$datos)   <- "double"             # cambia clase de columna "datos" de file a numeric
  file                <- na.omit(file)        # omite los NA del file generados con class

  # -----------------------------------------------------------------------------
  # Definición del área que deseo que sea interpolada por Kriging 
  xo <- seq(xmn.int, xmx.int, by = paso) ; yo <- seq(ymn.int, ymx.int, by = paso)
  # -----------------------------------------------------------------------------
  
  A <- expand.grid(xo, yo)                    # genera retícula donde calcular Kriging
  colnames(A) <- c("xo", "yo")                # modifica el nombre de las columnas de A
  #str(A)
  coordinates(A) <- ~xo + yo                  # convierte a Spatial class
  gridded(A) <- TRUE
  coordinates(file) <- ~lon+lat               # convierte data a Spatial Points Data Frame

  # -----------------------------------------------------------------------------
  # Cálculo de Kriging con el paquete automap
  if (min(file$datos, na.rm = TRUE) == 0 & max(file$datos, na.rm = TRUE) == 0)
    
    {xyz <- data.frame(xo = coordinates(A)[, 1], yo = coordinates(A)[, 2],
                       var1.pred = 0, var1.var = NA, var1.stdev = NA)} else
                         
      {kriging_result = autoKrige(datos ~ 1, file, new_data = A, 
                                  start_vals = c(NA, NA, NA))
       xyz <- as.data.frame(kriging_result$krige_output)}
  
  # -----------------------------------------------------------------------------
  
  # -----------------------------------------------------------------------------
  # Salida de los datos en la grilla generada con Kriging (variable p)
  p <- xyz[, c('xo', 'yo', 'var1.pred', 'var1.var', 'var1.stdev')]
  return(p)
  # -----------------------------------------------------------------------------
}


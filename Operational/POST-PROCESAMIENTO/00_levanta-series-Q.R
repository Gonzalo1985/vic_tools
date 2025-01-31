#
# -------------------------------------------------------------------------------- #
# Gonzalo M. Diaz
# MINISTERIO DE DEFENSA - Servicio Meteorologico Nacional
# Buenos Aires, 27.01.2023 
# ----
# -------------------------------------------------------------------------------- #
# 
# -------------------------------------------------------------------------------- #
# Funciones para levantar los datos de la Curva de Gasto del alerta.ina.gob.ar
# --------------------------------------------------------------------------------
#ID <- c(
#  335, 343, # PELOTAS
#  163, 341, # CANOAS
#  106, 239, 262, # IRAI
#  61, # EL SOBERBIO (prefectura)
#  1035, # GARRUCHOS (salto grande)
#  72, # PASO DE LOS LIBRES (prefectura)
#  79, # CONCORDIA (prefectura)
#  284  # CONCEPCION DEL URUGUAY (prefectura)
#)
# ---------------------------------------------------------------------------- #
# FUNCIONES
GET.Q.data <- function(Id, Start, End, configFile = 'Config.json'){
  
  data <- list()
  
  config <- fromJSON(configFile)
  
  URI <- paste0(config$api$url, "getSeriesBySiteAndVar?estacion_id=", Id,
                "&var_id=4&",
                "timestart=", Start,
                "&timeend=", End, "&includeProno=true")
  
  
  request <- GET(URI, add_headers("Authorization" = config$api$token),
                 accept_json())
  
  x <- fromJSON(content(request, "text"))
  
  return(list(x$estacion$nombre, x$estacion$geom$coordinates, x$observaciones))
  
}
# ---------------------------------------------------------------------------- #


CALC.daily.mean <- function(input.data = input.data){
  
  # transforma de matrix a data.frame
  input.data <- as.data.frame(input.data)
  
  # transforma de factor a Date
  input.data$V1 <- as.Date(input.data$V1)
  
  # transforma de factor a Date
  input.data$V2 <- as.Date(input.data$V2)
  
  # transforma de factor a Numeric
  input.data$V3 <- as.numeric(as.character(input.data$V3))
  
  daily.mean <- input.data %>%
    mutate(date = floor_date(input.data$V1)) %>%
    group_by(date) %>%
    summarize(mean_X1 = mean(V3))
  
  return(daily.mean)
}
# ---------------------------------------------------------------------------- #


GET.Q.series <- function(ID = ID, start.date = start.date, end.date = end.date){
  
  complete.date <- data.frame(date = seq.Date(start.date, end.date, 1))
  aux.Q.obs <- c()
  for (i in seq_along(ID)){
     out.1 <- GET.Q.data(
       Id = ID[i],
       Start = as.character(start.date),
       End = as.character(end.date + 1),
       configFile = '/home/gdiaz/Documentos/VIC+route/POST-PROCESAMIENTO/Config.json'
       )
     out.2 <- CALC.daily.mean(out.1[[3]])
     out.2$date <- as.Date(out.2$date)
     Q.station.complete <- merge(out.2,complete.date, by = "date", all.y = TRUE)
     aux.Q.obs <- cbind(aux.Q.obs, Q.station.complete$mean_X1)
    }
  Q.obs <- data.frame(fechas = Q.station.complete$date, aux.Q.obs)
  return(Q.obs)
}
# ---------------------------------------------------------------------------- #

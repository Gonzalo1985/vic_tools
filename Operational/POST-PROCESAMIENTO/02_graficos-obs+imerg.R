#
# ---------------------------------------------------------------------------- #
# Gonzalo M. Diaz
# MINISTERIO DE DEFENSA - Servicio Meteorologico Nacional
# Buenos Aires, 06.10.2017
# ----
# ---------------------------------------------------------------------------- #
# Paso 02 -> Del post-procesamiento de los datos del Modelo VIC + routeo
#            Graficos de la evolucion temporal de los caudales de los puertos y
#            su pronostico
# ---------------------------------------------------------------------------- #
# Script que grafica la evolución temporal (hidrogramas) de los caudales
# simulados por VIC+routeo para cada uno de los puertos deseados del río Uruguay
# ------------------------------------------------------------------------------

# ---------------------------------------------------------------------------- #
# ----------------- Limpieza del Environment y carga de librerias ----
rm(list = ls()) 
suppressMessages(library("lubridate"))
suppressMessages(library("jsonlite"))
suppressMessages(library("httr"))
suppressMessages(library("dplyr"))
# ------------------------------------------------------------------------------

# ---------------------------------------------------------------------------- #
# --------------------------- SETEO DE PARAMETROS ----
source('/home/gdiaz/Documentos/VIC+route/OBS/02a_Control-file-param.R')
source('/home/gdiaz/Documentos/VIC+route/SQPE-OBS-v0.2/02a_Control-file-param-SQPEobs.R')
# ------------------------------------------------------------------------------

# ---------------------------------------------------------------------------- #
# ----------------------------------- RUTAS ----
### UBICACION DE CARPETA PRINCIPAL
path.ppal <- "/home/gdiaz/Documentos/VIC+route/POST-PROCESAMIENTO/"
###
### UBICACION DE LAS OBSERVACIONES: CAUDALES
path_observa <- "/ms-36/hidro/datos/Caudal/"
###
### UBICACION DE LOS DATOS SIMULADOS: CAUDALES
path_simula <- "/data/oper-hidro/VIC/Outputs/Out_route/"
###
### UBICACION DE LOS DATOS SIMULADOS CON FORZANTE SQPE-OBS-v0.2: CAUDALES
path.sim.sqpe <- "/data/oper-hidro/VIC/Outputs/Out_route_SQPE-OBS-v0.2/"
###
### UBICACION DE SALIDA DE LAS IMAGENES PRODUCIDAS
path.salida <- "/ms-36/QPE/Panel/app_hidrologicas/"
###
# ------------------------------------------------------------------------------

# ---------------------------------------------------------------------------- #
# ------- NIVELES DE ALERTA/EVACUACION ----
# Pelotas, Canoas, Irai, El Soberbio, Garruchos, Paso de los Libres, Concordia,
# Concepción del Uruguay
nivel.pto.aler <- c(NA, NA, NA, 15800, 15300, 12100, NA, 16000)
nivel.pto.evac <- c(NA, NA, NA, 19700, 19550, 14800, NA, 22000)
# ------------------------------------------------------------------------------

# ---------------------------------------------------------------------------- #
# -- SE ABREN LOS DATOS MODELADOS y OBSERVADOS Y SE GUARDAN EN MATRIZ COMUN ----
PELOT_simula <- read.table(paste0(path_simula, "PELOT.day"))
CANOA_simula <- read.table(paste0(path_simula, "CANOA.day"))
IRAII_simula <- read.table(paste0(path_simula, "IRAII.day"))
SOBER_simula <- read.table(paste0(path_simula, "SOBER.day"))
GARRU_simula <- read.table(paste0(path_simula, "GARRU.day"))
PASOL_simula <- read.table(paste0(path_simula, "PASOL.day"))
CONCO_simula <- read.table(paste0(path_simula, "CONCO.day"))

#SOBER.sim.imerg <- read.table(paste0(path.sim.imerg, "SOBEI.day"))
#GARRU.sim.imerg <- read.table(paste0(path.sim.imerg, "GARRI.day"))
#PASOL.sim.imerg <- read.table(paste0(path.sim.imerg, "PASOI.day"))
#CONCE.sim.imerg <- read.table(paste0(path.sim.imerg, "CONCI.day"))

#SOBER.sim.sqpe.01 <- read.table(paste0(path.sim.sqpe.v0.1, "SOBES.day"))
#GARRU.sim.sqpe.01 <- read.table(paste0(path.sim.sqpe.v0.1, "GARRS.day"))
#PASOL.sim.sqpe.01 <- read.table(paste0(path.sim.sqpe.v0.1, "PASOS.day"))
#CONCE.sim.sqpe.01 <- read.table(paste0(path.sim.sqpe.v0.1, "CONCS.day"))

PELOT.sim.sqpe <- read.table(paste0(path.sim.sqpe, "PELOS.day"))
CANOA.sim.sqpe <- read.table(paste0(path.sim.sqpe, "CANOS.day"))
IRAII.sim.sqpe <- read.table(paste0(path.sim.sqpe, "IRAIS.day"))
SOBER.sim.sqpe <- read.table(paste0(path.sim.sqpe, "SOBES.day"))
GARRU.sim.sqpe <- read.table(paste0(path.sim.sqpe, "GARRS.day"))
PASOL.sim.sqpe <- read.table(paste0(path.sim.sqpe, "PASOS.day"))
CONCO.sim.sqpe <- read.table(paste0(path.sim.sqpe, "CONCS.day"))


#Q.obs <- read.csv(paste0(path_observa,"Q_puertos_uruguay.csv"), header = TRUE)

# abre serie de caudal para su graficado
ID <- c(61, 1035, 72, 79)
source(paste0(path.ppal, "00_levanta-series-Q.R"))
Q.obs <- GET.Q.series(ID = ID,
                      start.date = rango.graf[1],
                      end.date = rango.graf[2])

# completa con NA las otras columnas y nombra columnas
Q.obs <- cbind(Q.obs, NA, NA, NA, NA)
colnames(Q.obs) <- c("fechas", "SOBER", "GARRU", "PASOL", "CONCO",
                     "PELOT", "CANOA", "IRAII", "CONCE")



DATA_simula <- cbind(PELOT_simula, CANOA_simula[, 4], IRAII_simula[, 4],
                     SOBER_simula[, 4], GARRU_simula[, 4], PASOL_simula[, 4],
                     CONCO_simula[, 4])
colnames(DATA_simula) <- c("año", "mes", "dia",
                           "PELOT", "CANOA", "IRAII",
                           "SOBER", "GARRU", "PASOL", "CONCO")

DATA.sim.sqpe <- cbind(PELOT.sim.sqpe, CANOA.sim.sqpe[, 4], IRAII.sim.sqpe[, 4],
                       SOBER.sim.sqpe[, 4], GARRU.sim.sqpe[, 4], PASOL.sim.sqpe[, 4],
                       CONCO.sim.sqpe[, 4])
colnames(DATA.sim.sqpe) <- c("año", "mes", "dia",
                             "PELOT", "CANOA", "IRAII",
                             "SOBER", "GARRU", "PASOL", "CONCO")
# ------------------------------------------------------------------------------

# ---------------------------------------------------------------------------- #
# --- ARMA PERIODOS LARGO DE LA SIMULACION PARA SIMULACIONES: OBSERVACIONES ----
# ------------------------------------------------------------IMERG-ER ---------
# ------------------------------------------------------------SQPE-OBS-v0.1 ----
# ------------------------------------------------------------SQPE-OBS-v0.2 ----
agrega.0 <- function(input.DATA = input.DATA)
{
  for (i in 1:nrow(input.DATA)){
    ifelse(as.numeric(input.DATA$mes[i]) < 10,
           input.DATA$mes[i] <- paste0("0", input.DATA$mes[i]),
           input.DATA$mes[i] <- input.DATA$mes[i])
    ifelse(as.numeric(input.DATA$dia[i]) < 10,
           input.DATA$dia[i] <- paste0("0", input.DATA$dia[i]),
           input.DATA$dia[i] <- input.DATA$dia[i])
  }
  return(input.DATA)
}

salida.aux <- agrega.0(input.DATA = DATA_simula)
fechas <- lubridate::ymd(paste0(salida.aux$año, salida.aux$mes, salida.aux$dia))
DATA_simula <- cbind(fechas, salida.aux)

salida.aux <- agrega.0(input.DATA = DATA.sim.sqpe)
fechas.sim.sqpe <- lubridate::ymd(paste0(salida.aux$año, salida.aux$mes, salida.aux$dia))
DATA.sim.sqpe <- cbind(fechas.sim.sqpe, salida.aux)
# -------------------------------------------------------------------------------


# ---------------------------------------------------------------------------- #
# -- DEFINICION DE DATOS EN FORMATO xts Y DOMINIO DE OBSERVADO Y PRONOSTICO ----
DATA_simula.xts <- xts::xts(x = subset(DATA_simula,
                                       select = c("PELOT", "CANOA", "IRAII",
                                                  "SOBER", "GARRU", "PASOL",
                                                  "CONCO")),
                            order.by = DATA_simula[, 'fechas'])

DATA.sim.sqpe.xts <- xts::xts(x = subset(DATA.sim.sqpe,
                                         select = c("PELOT", "CANOA", "IRAII",
                                                    "SOBER", "GARRU", "PASOL",
                                                    "CONCO")),
                              order.by = DATA.sim.sqpe[, 'fechas.sim.sqpe'])

SOBER.observa.xts <- xts::xts(x = subset(Q.obs, select = "SOBER"),
                              order.by = as.Date(Q.obs[, 'fechas']))

GARRU.observa.xts <- xts::xts(x = subset(Q.obs, select = "GARRU"),
                              order.by = as.Date(Q.obs[, 'fechas']))

PASOL.observa.xts <- xts::xts(x = subset(Q.obs, select = "PASOL"),
                              order.by = as.Date(Q.obs[, 'fechas']))

CONCO.observa.xts <- xts::xts(x = subset(Q.obs, select = "CONCO"),
                              order.by = as.Date(Q.obs[, 'fechas']))

DATA.observa.xts <- cbind(NA, NA, NA,
                          SOBER.observa.xts, GARRU.observa.xts,
                          PASOL.observa.xts, CONCO.observa.xts,
                          NA)

DATA.simula.1 <- window(DATA_simula.xts, 
                        start = rango.graf[1], 
                        end = rango.graf[2])

DATA.simula.4 <- window(DATA.sim.sqpe.xts, 
                        start = rango.graf[1], 
                        end = rango.sqpe.graf[2])

DATA.prono.1 <- window(DATA_simula.xts, 
                       start = rango.graf[2], 
                       end = rango.graf[3])

DATA.observa <- window(DATA.observa.xts,
                       start = rango.graf[1],
                       end = rango.graf[2])
# ------------------------------------------------------------------------------

# ---------------------------------------------------------------------------- #
# --------------------- ABRE ESTADISTICOS ----
estadisticos.SOBER <- read.csv(paste0(path.ppal, "estadisticos-SOBER.csv"),
                               colClasses = c("NULL", rep(NA, 8)))
estadisticos.GARRU <- read.csv(paste0(path.ppal, "estadisticos-GARRU.csv"),
                               colClasses = c("NULL", rep(NA, 8)))
estadisticos.PASOL <- read.csv(paste0(path.ppal, "estadisticos-PASOL.csv"),
                               colClasses = c("NULL", rep(NA, 8)))
estadisticos.CONCO <- read.csv(paste0(path.ppal, "estadisticos-CONCO.csv"),
                               colClasses = c("NULL", rep(NA, 8)))

estadisticos <- data.frame(RMSE = c(estadisticos.SOBER[1, "RMSE"],
                                    estadisticos.GARRU[1, "RMSE"],
                                    estadisticos.PASOL[1, "RMSE"],
                                    estadisticos.CONCO[1, "RMSE"]))
rownames(estadisticos) <- c("SOBER", "GARRU", "PASOL", "CONCO")
# ------------------------------------------------------------------------------ 


# ---------------------------------------------------------------------------- #
# ---------------------------------- GRAFICADO ----
for (i in 1:7)
  {
   print(paste0("Grafica la salida modelada y observada (si corresponde) de ", colnames(DATA.simula.1)[i]))
   source(paste0(path.ppal, "02a_plot-con-ggplot.R"))
  }
# ------------------------------------------------------------------------------

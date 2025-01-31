#
# ---------------------------------------------------------------------------- #
# Gonzalo M. Diaz
# MINISTERIO DE DEFENSA - Servicio Meteorologico Nacional
# Buenos Aires, 05.10.2017
# ----
# ---------------------------------------------------------------------------- #
# Paso 01 -> Del post-procesamiento de los datos del Modelo VIC + routeo
#            Cálculo de estadísticos de la corrida operativa de VIC + routeo
# ---------------------------------------------------------------------------- #
# Script que calcula los estadísticos para la corrida del modelo VIC + routeo 
# para las estaciones del río Uruguay en las cuales se cuenta con datos de caudal
# -----------------------------------------------------------------------------

# ---------------------------------------------------------------------------- #
# ----------------- Limpieza del Environment y carga de librerias ----
rm(list = ls())
suppressMessages(library("lubridate"))
suppressMessages(library("xts"))
suppressMessages(library("bsts"))
suppressMessages(library("hydroGOF"))
suppressMessages(library("httr"))
suppressMessages(library("jsonlite"))
suppressMessages(library("dplyr"))
# ----------------------------------------------------------------------------- 

# ---------------------------------------------------------------------------- #
# ----------------------------------- RUTAS ----
### UBICACION DE CARPETA PRINCIPAL
path.ppal <- "/home/gdiaz/Documentos/VIC+route/POST-PROCESAMIENTO/"
###
### UBICACION DE LAS OBSERVACIONES: CAUDALES
path.Q.obs <- "/ms-36/hidro/datos/Caudal/"
###
### UBICACION DE LOS DATOS SIMULADOS: CAUDALES
path.sim <- "/data/oper-hidro/VIC/Outputs/Out_route/"
###
### UBICACION DE LOS DATOS SIMULADOS CON FORZANTE IMERG-ER: CAUDALES
path.sim.imerg <- "/data/oper-hidro/VIC/Outputs/Out_route_imergER/"
###
### UBICACION DE LOS DATOS SIMULADOS CON FORZANTE SQPE-OBS-v0.1: CAUDALES
path.sim.sqpe.v0.1 <- "/data/oper-hidro/VIC/Outputs/Out_route_SQPE-OBS-v0.1/"
###
### UBICACION DE LOS DATOS SIMULADOS CON FORZANTE SQPE-OBS-v0.2: CAUDALES
path.sim.sqpe.v0.2 <- "/data/oper-hidro/VIC/Outputs/Out_route_SQPE-OBS-v0.2/"
###
# -----------------------------------------------------------------------------



# ---------------------------------------------------------------------------- #
# -- DEFINICION DEL RANGO DE FECHAS EN EL CUAL SE CALCULARAN LOS ESTADISTICOS --
# --------------------- PARA SIMULACION A PARTIR DE OBSERVACIONES ------------
param.control.file.obs <- read.table(
  "/data/oper-hidro/VIC/Parameter_Files/PF_VIC/OBS/param_control_file.txt",
  row.names = 1
)
#source('/home/gdiaz/Documentos/VIC+route/OBS/02a_Control-file-param.R')

date.beg.sim.obs <- ymd(paste0(param.control.file.obs["yr.beg.sim" ,], "-",
                               param.control.file.obs["mon.beg.sim",], "-",
                               param.control.file.obs["day.beg.sim",]))

date.end.sim.obs <- ymd(paste0(param.control.file.obs["yr.end.sim" ,], "-",
                               param.control.file.obs["mon.end.sim",], "-",
                               param.control.file.obs["day.end.sim",]))

last.day.graph.obs <- ymd(paste0(param.control.file.obs["yr.end.frc" ,], "-",
                                 param.control.file.obs["mon.end.frc",], "-",
                                 param.control.file.obs["day.end.frc",]))

rango.simulacion   <- seq.Date(from = date.beg.sim.obs, to = date.end.sim.obs, by = 1)

rango.estadisticos <- seq.Date(from = date.beg.sim.obs + 365, to = date.end.sim.obs,
                               by = 1)
# -----------------------------------------------------------------------------

# ---------------------------------------------------------------------------------- #
# ---- DEFINICION DEL RANGO DE FECHAS EN EL CUAL SE CALCULARAN LOS ESTADISTICOS ----
# -------------------- PARA SIMULACION A PARTIR DE SQPE-OBS-v0.2 -------------------
param.control.file.sqpe <- read.table(
  "/data/oper-hidro/VIC/Parameter_Files/PF_VIC/SQPE-OBS-v0.2/param_control_file.txt",
  row.names = 1
)

date.beg.sim.sqpe <- ymd(paste0(param.control.file.sqpe["yr.beg.sim" ,], "-",
                                param.control.file.sqpe["mon.beg.sim",], "-",
                                param.control.file.sqpe["day.beg.sim",]))

date.end.sim.sqpe <- ymd(paste0(param.control.file.sqpe["yr.end.sim" ,], "-",
                                param.control.file.sqpe["mon.end.sim",], "-",
                                param.control.file.sqpe["day.end.sim",]))

if (day(Sys.Date()) == 2)
  {last.day.graph.sqpe <- ymd(paste0(param.control.file.sqpe["last.year" ,], "-",
                                     param.control.file.sqpe["last.month",], "-",
                                     param.control.file.sqpe["last.day.mon",]))} else
  {last.day.graph.sqpe <- ymd(paste0(param.control.file.sqpe["yr.end.frc" ,], "-",
                                     param.control.file.sqpe["mon.end.frc",], "-",
                                     param.control.file.sqpe["day.end.frc",]))
  }

rango.simulacion.sqpe   <- seq.Date(from = date.beg.sim.sqpe, to = date.end.sim.sqpe, by = 1)

rango.estadisticos.sqpe <- seq.Date(from = date.beg.sim.sqpe + 365, to = date.end.sim.sqpe,
                                    by = 1)
# ------------------------------------------------------------------------------------


# ------------------------------------------------------------------------------- #
# ---- SE ABREN LOS DATOS MODELADOS y OBSERVADOS Y SE GUARDAN EN MATRIZ COMUN ----
SOBER.sim <- read.table(paste0(path.sim, "SOBER.day"))
GARRU.sim <- read.table(paste0(path.sim, "GARRU.day"))
PASOL.sim <- read.table(paste0(path.sim, "PASOL.day"))
CONCO.sim <- read.table(paste0(path.sim, "CONCO.day"))

#SOBER.sim.imerg <- read.table(paste0(path.sim.imerg, "SOBEI.day"))
#GARRU.sim.imerg <- read.table(paste0(path.sim.imerg, "GARRI.day"))
#PASOL.sim.imerg <- read.table(paste0(path.sim.imerg, "PASOI.day"))
#CONCE.sim.imerg <- read.table(paste0(path.sim.imerg, "CONCI.day"))

#SOBER.sim.sqpe.01 <- read.table(paste0(path.sim.sqpe.v0.1, "SOBES.day"))
#GARRU.sim.sqpe.01 <- read.table(paste0(path.sim.sqpe.v0.1, "GARRS.day"))
#PASOL.sim.sqpe.01 <- read.table(paste0(path.sim.sqpe.v0.1, "PASOS.day"))
#CONCE.sim.sqpe.01 <- read.table(paste0(path.sim.sqpe.v0.1, "CONCS.day"))

SOBER.sim.sqpe <- read.table(paste0(path.sim.sqpe.v0.2, "SOBES.day"))
GARRU.sim.sqpe <- read.table(paste0(path.sim.sqpe.v0.2, "GARRS.day"))
PASOL.sim.sqpe <- read.table(paste0(path.sim.sqpe.v0.2, "PASOS.day"))
CONCO.sim.sqpe <- read.table(paste0(path.sim.sqpe.v0.2, "CONCS.day"))

# abre serie histórica de caudal
ID <- c(61, 1035, 72, 79)
source(paste0(path.ppal, "00_levanta-series-Q.R"))
Q.obs.oper <- GET.Q.series(ID = ID,
                           start.date = date.beg.sim.sqpe,
                           end.date = date.end.sim.obs)

# completa con NA las otras columnas y nombra columnas
Q.obs <- cbind(Q.obs.oper, NA, NA, NA, NA)
colnames(Q.obs) <- c("fechas", "SOBER", "GARRU", "PASOL", "CONCO",
                     "PELOT", "CANOA", "IRAII", "CONCE")

DATA.sim <- cbind(SOBER.sim, GARRU.sim[,4], PASOL.sim[,4], CONCO.sim[,4])
colnames(DATA.sim) <- c("año","mes","dia","SOBER","GARRU","PASOL","CONCO")
fechas.sim <- seq.Date(from = date.beg.sim.obs,
                       to = bsts::LastDayInMonth(last.day.graph.obs),
                       by = 1)

DATA.sim.sqpe <- cbind(SOBER.sim.sqpe, GARRU.sim.sqpe[, 4], PASOL.sim.sqpe[, 4], CONCO.sim.sqpe[, 4])
colnames(DATA.sim.sqpe) <- c("año","mes","dia","SOBER","GARRU","PASOL","CONCO")
fechas.sim.sqpe <- seq.Date(from = date.beg.sim.sqpe,
                            to = bsts::LastDayInMonth(last.day.graph.sqpe), 
                            by = 1)
# ---------------------------------------------------------------------------------

# ------------------------------------------------------------------------------- #
# ---- DEFINICION DE DATOS EN FORMATO xts DE OBSERVACIONES Y MODELADO ----
DATA.obs.xts <- xts::xts(x = subset(Q.obs, select = c("SOBER","GARRU","PASOL",
                                                      "CONCO", "PELOT", "CANOA",
                                                      "IRAII", "CONCE")),
                         order.by = lubridate::ymd(Q.obs[,"fechas"]))

DATA.sim.xts <- xts::xts(x = subset(DATA.sim,
                                    select = c("SOBER","GARRU", "PASOL","CONCO")),
                         order.by = fechas.sim)

DATA.sim.sqpe.xts <- xts::xts(x = subset(DATA.sim.sqpe,
                                         select = c("SOBER","GARRU","PASOL","CONCO")),
                              order.by = fechas.sim.sqpe)
# ---------------------------------------------------------------------------------



# ------------------------------------------------------------------------------- #
# ---- CALCULO DE ESTADISTICOS: Correlación ----
r.SOBER <- cor(DATA.obs.xts[rango.estadisticos, "SOBER"],
               DATA.sim.xts[rango.estadisticos, "SOBER"]/35.3, 
               use = "complete.obs")

r.SOBER.sqpe <- cor(DATA.obs.xts[rango.estadisticos.sqpe, "SOBER"], 
                    DATA.sim.sqpe.xts[rango.estadisticos.sqpe, "SOBER"], 
                    use = "complete.obs")

r.GARRU <- cor(DATA.obs.xts[rango.estadisticos, "GARRU"],
               DATA.sim.xts[rango.estadisticos, "GARRU"]/35.3, 
               use = "complete.obs")

r.GARRU.sqpe <- cor(DATA.obs.xts[rango.estadisticos.sqpe, "GARRU"], 
                    DATA.sim.sqpe.xts[rango.estadisticos.sqpe, "GARRU"], 
                    use = "complete.obs")


r.PASOL <- cor(DATA.obs.xts[rango.estadisticos, "PASOL"],
               DATA.sim.xts[rango.estadisticos, "PASOL"]/35.3,
               use = "complete.obs")

r.PASOL.sqpe <- cor(DATA.obs.xts[rango.estadisticos.sqpe, "PASOL"], 
                    DATA.sim.sqpe.xts[rango.estadisticos.sqpe, "PASOL"], 
                    use = "complete.obs")

r.CONCO <- cor(DATA.obs.xts[rango.estadisticos, "CONCO"],
               DATA.sim.xts[rango.estadisticos, "CONCO"]/35.3, 
               use = "complete.obs")

r.CONCO.sqpe <- cor(DATA.obs.xts[rango.estadisticos.sqpe, "CONCO"], 
                    DATA.sim.sqpe.xts[rango.estadisticos.sqpe, "CONCO"], 
                    use = "complete.obs")
# ---------------------------------------------------------------------------------

# ------------------------------------------------------------------------------- #
# ---- TRANSFORMACION DE FORMATO xts A data.frame PARA QUE SE PUEDAN EJECUTAR ---
# ------------------------ LOS PAQUETES bsts E hydroGOF ----
DATA.obs <- data.frame(fechas = index(DATA.obs.xts), coredata(DATA.obs.xts))
DATA.sim <- data.frame(fechas = index(DATA.sim.xts), coredata(DATA.sim.xts))
DATA.sim.sqpe  <- data.frame(fechas = index(DATA.sim.sqpe.xts), coredata(DATA.sim.sqpe.xts))

DATA.obs.subset <- as.data.frame(with(DATA.obs, 
                                      DATA.obs[(fechas >= date.beg.sim.obs & fechas <= date.end.sim.obs), 
                                               c("SOBER", "GARRU", "PASOL", "CONCO")]))

DATA.sim.subset <- as.data.frame(with(DATA.sim, 
                                      DATA.sim[(fechas >= date.beg.sim.obs & fechas <= date.end.sim.obs), 
                                               c("SOBER", "GARRU", "PASOL", "CONCO")]))

DATA.sim.subset.sqpe <- as.data.frame(with(DATA.sim.sqpe,
                                           DATA.sim.sqpe[(fechas >= date.beg.sim.sqpe & fechas <= date.end.sim.sqpe), 
                                                         c("SOBER", "GARRU", "PASOL", "CONCO")]))

rownames(DATA.obs.subset) <- rango.simulacion
rownames(DATA.sim.subset) <- rango.simulacion
rownames(DATA.sim.subset.sqpe)  <- rango.simulacion.sqpe
# ---------------------------------------------------------------------------------

# ------------------------------------------------------------------------------- #
# ---- CALCULO DE ESTADISTICOS: Raíz del Error Cuadrático Medio ----
rmse.SOBER <- hydroGOF::rmse(DATA.sim.subset[as.character(rango.estadisticos), "SOBER"]/35.3, 
                             DATA.obs.subset[as.character(rango.estadisticos), "SOBER"])

rmse.SOBER.sqpe <- hydroGOF::rmse(DATA.sim.subset.sqpe[as.character(rango.estadisticos.sqpe), "SOBER"]/35.3, 
                                  DATA.obs.subset[as.character(rango.estadisticos.sqpe), "SOBER"])

rmse.GARRU <- hydroGOF::rmse(DATA.sim.subset[as.character(rango.estadisticos), "GARRU"]/35.3, 
                             DATA.obs.subset[as.character(rango.estadisticos), "GARRU"])

rmse.GARRU.sqpe <- hydroGOF::rmse(DATA.sim.subset.sqpe[as.character(rango.estadisticos.sqpe), "GARRU"]/35.3, 
                                  DATA.obs.subset[as.character(rango.estadisticos.sqpe), "GARRU"])


rmse.PASOL <- hydroGOF::rmse(DATA.sim.subset[as.character(rango.estadisticos), "PASOL"]/35.3, 
                             DATA.obs.subset[as.character(rango.estadisticos), "PASOL"])

rmse.PASOL.sqpe <- hydroGOF::rmse(DATA.sim.subset.sqpe[as.character(rango.estadisticos.sqpe), "PASOL"]/35.3, 
                                  DATA.obs.subset[as.character(rango.estadisticos.sqpe), "PASOL"])

rmse.CONCO <- hydroGOF::rmse(DATA.sim.subset[as.character(rango.estadisticos), "CONCO"]/35.3, 
                             DATA.obs.subset[as.character(rango.estadisticos), "CONCO"])

rmse.CONCO.sqpe <- hydroGOF::rmse(DATA.sim.subset.sqpe[as.character(rango.estadisticos.sqpe), "CONCO"]/35.3, 
                                  DATA.obs.subset[as.character(rango.estadisticos.sqpe), "CONCO"])

# ---------------------------------------------------------------------------------

# ---------------------------------------------------------------------------- #
# ---- CALCULO DE ESTADISTICOS: Nash-Sutcliffe ----
ns.SOBER <- hydroGOF::NSE(DATA.sim.subset[as.character(rango.estadisticos), "SOBER"]/35.3, 
                          DATA.obs.subset[as.character(rango.estadisticos), "SOBER"])

ns.SOBER.sqpe <- hydroGOF::NSE(DATA.sim.subset.sqpe[as.character(rango.estadisticos.sqpe), "SOBER"]/35.3, 
                               DATA.obs.subset[as.character(rango.estadisticos.sqpe), "SOBER"])

ns.GARRU <- hydroGOF::NSE(DATA.sim.subset[as.character(rango.estadisticos), "GARRU"]/35.3, 
                          DATA.obs.subset[as.character(rango.estadisticos), "GARRU"])

ns.GARRU.sqpe <- hydroGOF::NSE(DATA.sim.subset.sqpe[as.character(rango.estadisticos.sqpe), "GARRU"]/35.3, 
                               DATA.obs.subset[as.character(rango.estadisticos.sqpe), "GARRU"])

ns.PASOL <- hydroGOF::NSE(DATA.sim.subset[as.character(rango.estadisticos), "PASOL"]/35.3, 
                          DATA.obs.subset[as.character(rango.estadisticos), "PASOL"])

ns.PASOL.sqpe <- hydroGOF::NSE(DATA.sim.subset.sqpe[as.character(rango.estadisticos.sqpe), "PASOL"]/35.3, 
                               DATA.obs.subset[as.character(rango.estadisticos.sqpe), "PASOL"])

ns.CONCO <- hydroGOF::NSE(DATA.sim.subset[as.character(rango.estadisticos), "CONCO"]/35.3, 
                          DATA.obs.subset[as.character(rango.estadisticos), "CONCO"])

ns.CONCO.sqpe <- hydroGOF::NSE(DATA.sim.subset.sqpe[as.character(rango.estadisticos.sqpe), "CONCO"]/35.3, 
                               DATA.obs.subset[as.character(rango.estadisticos.sqpe), "CONCO"])
# ------------------------------------------------------------------------------

# ---------------------------------------------------------------------------- #
# ---- GENERACION DE data.frame CON LOS ESTADISTICOS DE LA SIMULACION ----
#bases.data.PASOL <- cbind(
#  bases.data, 
#  R = c(r.PASOL, r.PASOL.imerg, r.PASOL.sqpe, r.PASOL.sqpe.02),
#  RMSE = c(rmse.PASOL, rmse.PASOL.imerg, rmse.PASOL.sqpe, rmse.PASOL.sqpe.02),
#  NS = c(ns.PASOL, ns.PASOL.imerg, ns.PASOL.sqpe, ns.PASOL.sqpe.02))

#bases.data.GARRU <- cbind(
#  bases.data,
#  R = c(r.GARRU, r.GARRU.imerg, r.GARRU.sqpe, r.GARRU.sqpe.02),
#  RMSE = c(rmse.GARRU, rmse.GARRU.imerg, rmse.GARRU.sqpe, rmse.GARRU.sqpe.02),
#  NS = c(ns.GARRU, ns.GARRU.imerg, ns.GARRU.sqpe, ns.GARRU.sqpe.02))

bases.data <- data.frame(
  bases = c("OBS", "SQPE-OBS-v0.2"),
  ini.sim = c(range(rango.simulacion)[1], range(rango.simulacion.sqpe)[1]),
  fin.sim = c(range(rango.simulacion)[2], range(rango.simulacion.sqpe)[2]),
  ini.est = c(range(rango.estadisticos)[1], range(rango.estadisticos.sqpe)[1]),
  fin.est = c(range(rango.estadisticos)[2], range(rango.estadisticos.sqpe)[2])
)

bases.data.SOBER <- cbind(
  bases.data,
  R = c(r.SOBER, r.SOBER.sqpe),
  RMSE = c(rmse.SOBER, rmse.SOBER.sqpe),
  NS = c(ns.SOBER, ns.SOBER.sqpe))

bases.data.GARRU <- cbind(
  bases.data,
  R = c(r.GARRU, r.GARRU.sqpe),
  RMSE = c(rmse.GARRU, rmse.GARRU.sqpe),
  NS = c(ns.GARRU, ns.GARRU.sqpe))

bases.data.PASOL <- cbind(
  bases.data, 
  R = c(r.PASOL, r.PASOL.sqpe),
  RMSE = c(rmse.PASOL, rmse.PASOL.sqpe),
  NS = c(ns.PASOL, ns.PASOL.sqpe))

bases.data.CONCO <- cbind(
  bases.data,
  R = c(r.CONCO, r.CONCO.sqpe),
  RMSE = c(rmse.CONCO, rmse.CONCO.sqpe),
  NS = c(ns.CONCO, ns.CONCO.sqpe))
# ------------------------------------------------------------------------------

write.csv(bases.data.SOBER, file = paste0(path.ppal, "estadisticos-SOBER.csv"))
write.csv(bases.data.GARRU, file = paste0(path.ppal, "estadisticos-GARRU.csv"))
write.csv(bases.data.PASOL, file = paste0(path.ppal, "estadisticos-PASOL.csv"))
write.csv(bases.data.CONCO, file = paste0(path.ppal, "estadisticos-CONCO.csv"))

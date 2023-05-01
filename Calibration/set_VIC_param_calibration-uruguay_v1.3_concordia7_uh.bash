#!/bin/bash

# SCRIPT QUE SETEA LOS PARAMETROS DE VIC PARA SU CALIBRACION. EL SCRIPT 
# GENERA DOS SCRIPTS DE R, UNO (EL PRIMERO) VARIA LOS VALORES DE LOS 
# PARAMETROS, EL OTRO (EL SEGUNDO) CALCULA LOS ESTADISTICOS PARA EVALUAR 
# LA CALIBRACION

# CORRE SCRIPT PARA ARMAR LOS ARCHIVOS DE ENTRADA AL VIC EN EL PERIODO 
# DE CALIBRACION DESEADO
#Rscript '/home/gdiaz/OPERATIVO/02b_Genera-data-VIC.R' >> LOG.txt

#####################################################################
# RUTA DE ARCHIVOS DE CONTROL
path_control_vic='/home/gonzalo/Parameter_Files/PF_VIC/'
path_control_rout='/home/gonzalo/para-route/'

# RUTA DONDE SE GUARDAN LOS DISTINTOS ARCHIVOS DE SUELO DE CADA SIMULACION
path_files='/home/gonzalo/Parameter_Files/PF_VIC/' # modificar

# RUTA DONDE SE GUARDAN LOS ARCHIVOS DE LOS ESTADISTICOS (N-S y RMSE)
path_ppal='/home/gonzalo/CAL_Scripts/' # modificar
rm ${path_ppal}LOG7.txt

# RUTAS DONDE SE ENCUENTRAN LOS EJECUTABLES DE LOS MODELOS
path_VIC='/opt/VIC-4.2d/VIC-VIC.4.2.d/src/'
path_route='/opt/VIC_Routing-1.1_Fortran/src/'

# RUTA DONDE SE ENCUENTRAN LAS OBSERVACIONES DE CAUDAL
path_obs_Q='/home/gonzalo/'

# RUTA DE DATOS DE ENTRADA A VIC
path_in_vic='/inputs-VIC/' # modificar

# RUTA DE SALIDA DE CADA SIMULACION
path_out_vic='/home/gonzalo/Outputs/out-vic-7/' # modificar
path_out_route='/home/gonzalo/Outputs/out-rout-7/' # modificar

# NOMBRES DE ARCHIVOS DE SUELO DE ENTRADA Y DE SALIDA
archivo_suelo_entrada='soil_file_uruguay_cierre_Concordia_sinCALIB.prn' # modificar
archivo_suelo_salida='soil_file_uruguay_ByMyA--Calibracion_'

# NOMBRE DE ARCHIVO DE SUELO AUXILIAR
archivo_suelo_aux='soil_aux--Calibracion7.prn' 

# NOMBRES DE ARCHIVOS DE CONTROL DE LOS MODELOS
control_file_VIC='control_file_VIC-Calibracion7.prn'
control_file_route='control_file_route_calibracion_7.prn'

# PERIODO DE CALIBRACION
t_ini='2004-01-01'
t_fin='2010-12-31'

cascade='FALSE'

# ARCHIVOS DE ESTADISTICOS PARA EVALUAR LA CALIBRACION
salida_RMSE='RMSE_uruguay_ByMyA--Calibracion_ERA_TERA7_2004-2010_Cascade_PELOTASyCANOAS.prn' # modificar
salida_NS='N-S_uruguay_ByMyA--Calibracion_ERA_TERA7_2004-2010_Cascade_PELOTASyCANOAS.prn' # modificar
#####################################################################

# VIC control file lines ------------------------------------------
line="FORCING1    ${path_in_vic}data_"
sed -i "138s#.*#${line}#" ${path_control_vic}${control_file_VIC}

line="SOIL            ${path_control_vic}soil_aux--Calibracion7.prn"
sed -i "159s#.*#${line}#" ${path_control_vic}${control_file_VIC}

line="VEGLIB          ${path_control_vic}LDAS_veg_lib.txt"
sed -i "163s#.*#${line}#" ${path_control_vic}${control_file_VIC}

line="VEGPARAM          ${path_control_vic}vegetacion_lpb.prn"
sed -i "164s#.*#${line}#" ${path_control_vic}${control_file_VIC}

line="RESULT_DIR      ${path_out_vic}"
sed -i "187s#.*#${line}#" ${path_control_vic}${control_file_VIC}
# -----------------------------------------------------------------

# ROUT control file lines -----------------------------------------
line="${path_control_rout}rout_direccion.prn"
sed -i "3s#.*#${line}#" ${path_control_rout}${control_file_route}

line="${path_control_rout}lp_xmask.asc"
sed -i "12s#.*#${line}#" ${path_control_rout}${control_file_route}

line="${path_control_rout}lp_frac.asc"
sed -i "15s#.*#${line}#" ${path_control_rout}${control_file_route}

line="${path_control_rout}Loca_7p7_gonza.asc"
sed -i "17s#.*#${line}#" ${path_control_rout}${control_file_route}

line="${path_out_vic}fluxes_"
sed -i "19s#.*#${line}#" ${path_control_rout}${control_file_route}

line="${path_out_route}"
sed -i "22s#.*#${line}#" ${path_control_rout}${control_file_route}

line="${path_control_rout}uh_all"
sed -i "27s#.*#${line}#" ${path_control_rout}${control_file_route}
# -----------------------------------------------------------------


for combinacion in {1..4}-{7..7}-{1..6}-{1..1}-{1..7}-{1..5}-{1..5}
do
rm ${path_ppal}parametros-cal7.R
rm ${path_ppal}estadisticos-cal7.R

echo ${combinacion}
cal_param_1=$(echo "$combinacion" | cut --delimiter='-' --fields=1)
cal_param_2=$(echo "$combinacion" | cut --delimiter='-' --fields=2)
cal_param_3=$(echo "$combinacion" | cut --delimiter='-' --fields=3)
cal_param_4=$(echo "$combinacion" | cut --delimiter='-' --fields=4)
cal_param_5=$(echo "$combinacion" | cut --delimiter='-' --fields=5)
cal_param_6=$(echo "$combinacion" | cut --delimiter='-' --fields=6)
cal_param_7=$(echo "$combinacion" | cut --delimiter='-' --fields=7)

cd ${path_ppal}
echo ${cal_param_1} ${cal_param_2} ${cal_param_3} ${cal_param_4} ${cal_param_5} ${cal_param_6} ${cal_param_7} >> ${path_ppal}LOG7.txt

##################### Script 1 de R  ##############################
echo "#
#**********************************************************************************
# Gonzalo M. Diaz
# MINISTERIO DE DEFENSA - Servicio Meteorologico Nacional, Buenos Aires, 11.02.2016
#
#**********************************************************************************
#
rm(list=ls())
####################################################################
########################## RUTA DE ARCHIVOS ########################
####################################################################
path.entrada <- '${path_files}'
path.salida <- '${path_files}'
####################################################################
#
####################################################################
################## NOMBRE DE ARCHIVO DE SALIDA #####################
####################################################################
entrada <- '${archivo_suelo_entrada}'
salida <- '${archivo_suelo_salida}'
####################################################################
####################################################################

cascade <- '${cascade}'

binf <- seq(from = 0.05 , to = 0.2 , by = 0.05)
Ws <- seq(from = 0.3 , to = 0.7 , by = 0.05)
Dsmax <- seq(from = 5 , to = 30 , by = 5)
Ds <- seq(from = 0.001, to = 0.001)
expt <- seq(from = -6, to = 0, by = 1)
thck2 <- c(0.1, seq(from = 0.5, to = 2, by = 0.5))
thck3 <- c(0.1, seq(from = 0.5, to = 2, by = 0.5))

if (cascade == 'TRUE')
  {soil_file <- read.table(paste0(path.entrada, entrada))
   IDs.modif <- read.table(paste0(path.entrada, 'IDs-a-modificar-de-CONCO.prn'))
   rows.modif <- which(soil_file[, 2] %in% IDs.modif[, 1] == TRUE)} else
  {soil_file <- read.table(paste0(path.entrada, entrada))
   rows.modif <- seq(from = 1, to = nrow(soil_file), by = 1)}

soil_file[rows.modif, 5] <- binf[${cal_param_1}]
soil_file[rows.modif, 8] <- Ws[${cal_param_2}]
soil_file[rows.modif, 7] <- Dsmax[${cal_param_3}]
soil_file[rows.modif, 6] <- Ds[${cal_param_4}]
soil_file[rows.modif, 10] <- soil_file[rows.modif, 10] + expt[${cal_param_5}]
a <- which(soil_file[, 10] < 3)
soil_file[a, 10] <- 3.01
soil_file[rows.modif, 11] <- soil_file[rows.modif, 11] + expt[${cal_param_5}]
a <- which(soil_file[, 11] < 3)
soil_file[a, 11] <- 3.01
soil_file[rows.modif, 12] <- soil_file[rows.modif, 12] + expt[${cal_param_5}]
a <- which(soil_file[, 12] < 3)
soil_file[a, 12] <- 3.01
soil_file[rows.modif, 24] <- thck2[${cal_param_6}]
soil_file[rows.modif, 25] <- thck3[${cal_param_7}]
###########################################################################
#################### GUARDADO DE MATRIZ EN ARCHIVO ########################
write.table(soil_file,paste0(path.salida,salida,as.character(${cal_param_1}),'-',
                                                as.character(${cal_param_2}),'-',
                                                as.character(${cal_param_3}),'-',
                                                as.character(${cal_param_4}),'-',
                                                as.character(${cal_param_5}),'-',
                                                as.character(${cal_param_6}),'-',
                                                as.character(${cal_param_7}),'.prn'),
            row.names = FALSE, col.names = FALSE,sep='\t')
###########################################################################
###########################################################################

###########################################################################
############################ FINALIZADO ###################################
###########################################################################" >> ${path_ppal}parametros-cal7.R
################################################################################################

Rscript ${path_ppal}'parametros-cal7.R' >> ${path_ppal}LOG7.txt
cp ${path_files}${archivo_suelo_salida}${cal_param_1}'-'${cal_param_2}'-'${cal_param_3}'-'${cal_param_4}'-'${cal_param_5}'-'${cal_param_6}'-'${cal_param_7}'.prn' ${path_files}${archivo_suelo_aux}

${path_VIC}vicNl -g ${path_files}${control_file_VIC}
rm ${path_files}${archivo_suelo_aux}

cd ${path_files}
rm *7.uh_s

${path_route}rout ${path_control_rout}${control_file_route} >> ${path_ppal}LOG7.txt

cd ${path_ppal}


##################### Script 2 de R ###############################
echo "#
#**********************************************************************************
# Gonzalo M. Diaz
# MINISTERIO DE DEFENSA - Servicio Meteorologico Nacional, Buenos Aires, 28.06.2017
#
#**********************************************************************************
#
rm(list=ls())
suppressMessages(library('hydroGOF'))

# ------------------------------------------------------------------
# --------------- INDICAR EL PERIODO DE CALIBRACION ----------------
t.ini <- '${t_ini}'
t.fin <- '${t_fin}'
# ------------------------------------------------------------------

# ------------------------------------------------------------------
# ------------------------ RUTA DE ARCHIVOS ------------------------
path        <- '${path_ppal}'
path.Q.hist <- '${path_obs_Q}'
path.modelo <- '${path_out_route}'
# ------------------------------------------------------------------

# ------------------------------------------------------------------
# ---------------- NOMBRE DE ARCHIVO DE SALIDA ---------------------
salida.RMSE <- '${salida_RMSE}'
salida.NS   <- '${salida_NS}'
# ------------------------------------------------------------------
#
#
#
# ------------------------------------------------------------------
# --- SE LEEN LOS DATOS OBSERVADOS DE CAUDAL Y SE CARGAN EN obs ----
obs.hist <- read.csv(paste0(path.Q.hist,'1990-2022_puertos_uruguay_conBrasil.csv'), stringsAsFactors = FALSE, header = TRUE)

#obs.real <- read.csv(paste0(path.Q.real, 'Q_puertos_uruguay.csv'), header = TRUE)
#obs.real <- data.frame(fechas = obs.real[, 'X'], 
#                       SOBER = NA, 
#                       GARRU = obs.real[, 'GARRU'], 
#                       PASOL = obs.real[, 'PASOL'], 
#                       CONCO = NA)

#obs <- rbind(obs.hist, obs.real)
obs <- obs.hist
# ------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ----- SE LEE LA SALIDA DEL MODELO, SE TRANSFORMA LA UNIDAD Y SE AGREGA COLUMNA DATE ------
mod.PELOT <- read.table(paste0(path.modelo, 'PELO7.day'), header = FALSE)
mod.CANOA <- read.table(paste0(path.modelo, 'CANO7.day'), header = FALSE)
mod.IRAI <- read.table(paste0(path.modelo, 'IRAI7.day'), header = FALSE)
mod.SOBER <- read.table(paste0(path.modelo, 'SOBE7.day'), header = FALSE)
mod.GARRU <- read.table(paste0(path.modelo, 'GARR7.day'), header = FALSE)
mod.PASOL <- read.table(paste0(path.modelo, 'PASO7.day'), header = FALSE)
mod.CONCO <- read.table(paste0(path.modelo, 'CONC7.day'), header = FALSE)

mod.PELOT <- transform(mod.PELOT, Q.m3.seg = V4 / 35.3)
mod.CANOA <- transform(mod.CANOA, Q.m3.seg = V4 / 35.3)
mod.IRAI <- transform(mod.IRAI, Q.m3.seg = V4 / 35.3)
mod.SOBER <- transform(mod.SOBER, Q.m3.seg = V4 / 35.3)
mod.GARRU <- transform(mod.GARRU, Q.m3.seg = V4 / 35.3)
mod.PASOL <- transform(mod.PASOL, Q.m3.seg = V4 / 35.3)
mod.CONCO <- transform(mod.CONCO, Q.m3.seg = V4 / 35.3)

date.completo <- as.character(with(as.data.frame(cbind(mod.SOBER[, 'V1'], mod.SOBER[, 'V2'], mod.SOBER[, 'V3'])), 
                                   paste(mod.SOBER[, 'V1'], mod.SOBER[, 'V2'], mod.SOBER[, 'V3'], sep = '-')))

date.completo <- as.numeric(format(as.Date(date.completo), '%Y%m%d'))

mod.PELOT <- cbind(date.completo, mod.PELOT)
mod.CANOA <- cbind(date.completo, mod.CANOA)
mod.IRAI <- cbind(date.completo, mod.IRAI)
mod.SOBER <- cbind(date.completo, mod.SOBER)
mod.GARRU <- cbind(date.completo, mod.GARRU)
mod.PASOL <- cbind(date.completo, mod.PASOL)
mod.CONCO <- cbind(date.completo, mod.CONCO)
# -----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
# ----- FILAS ENTRE DONDE SE UBICA EL PERIODO DE CALIBRACION -----------------------------
fila.t.ini <- which(mod.SOBER[, 'date.completo'] == format(as.Date(t.ini), '%Y%m%d'))
fila.t.fin <- which(mod.SOBER[, 'date.completo'] == format(as.Date(t.fin), '%Y%m%d'))
# ----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
# ----- SE PREPARAN LAS VARIABLES MODELADAS Y OBSERVADAS PARA CALCULAR ESTADISTICOS ------
mod.TOTAL <- data.frame(fechas = seq.Date(as.Date(t.ini), as.Date(t.fin), 1), 
                        PELOT = mod.PELOT[fila.t.ini:fila.t.fin, 'Q.m3.seg'],
                        CANOA = mod.CANOA[fila.t.ini:fila.t.fin, 'Q.m3.seg'],
                        IRAI = mod.IRAI[fila.t.ini:fila.t.fin, 'Q.m3.seg'],
                        SOBER = mod.SOBER[fila.t.ini:fila.t.fin, 'Q.m3.seg'],
                        GARRU = mod.GARRU[fila.t.ini:fila.t.fin, 'Q.m3.seg'],
                        PASOL = mod.PASOL[fila.t.ini:fila.t.fin, 'Q.m3.seg'],
                        CONCO = mod.CONCO[fila.t.ini:fila.t.fin, 'Q.m3.seg'])

mod.TOTAL <- as.data.frame(with(mod.TOTAL, mod.TOTAL[(fechas >= t.ini & fechas <= t.fin),
                                                     c('fechas', 'PELOT','CANOA','IRAI','SOBER', 'GARRU', 'PASOL', 'CONCO')]))

#mod.TOTAL <- as.data.frame(with(mod.TOTAL, mod.TOTAL[(fechas >= t.ini & fechas <= t.fin),
#                                                     c('fechas', 'SOBER')]))

pos.ini   <- which(obs == t.ini)
pos.fin   <- which(obs == t.fin)

obs.TOTAL <- obs[pos.ini:pos.fin, ]
# ----------------------------------------------------------------------------------------


# ------------------------------------------------------------------
# ------------- CALCULO DE ESTADISTICOS: NASH-SUTCLIFFE ------------
RMSE.PELOT <- hydroGOF::rmse(mod.TOTAL[, 'PELOT'], obs.TOTAL[, 'PELOT'], na.rm = TRUE)
RMSE.CANOA <- hydroGOF::rmse(mod.TOTAL[, 'CANOA'], obs.TOTAL[, 'CANOA'], na.rm = TRUE)
RMSE.IRAI <- hydroGOF::rmse(mod.TOTAL[, 'IRAI'], obs.TOTAL[, 'IRAI'], na.rm = TRUE)
RMSE.SOBER <- hydroGOF::rmse(mod.TOTAL[, 'SOBER'], obs.TOTAL[, 'SOBER'], na.rm = TRUE)
RMSE.GARRU <- hydroGOF::rmse(mod.TOTAL[, 'GARRU'], obs.TOTAL[, 'GARRU'], na.rm = TRUE)
RMSE.PASOL <- hydroGOF::rmse(mod.TOTAL[, 'PASOL'], obs.TOTAL[, 'PASOL'], na.rm = TRUE)
RMSE.CONCO <- hydroGOF::rmse(mod.TOTAL[, 'CONCO'], as.numeric(obs.TOTAL[, 'CONCO']), na.rm = TRUE)

NS.PELOT <- hydroGOF::NSE(mod.TOTAL[, 'PELOT'], obs.TOTAL[, 'PELOT'], na.rm = TRUE)
NS.CANOA <- hydroGOF::NSE(mod.TOTAL[, 'CANOA'], obs.TOTAL[, 'CANOA'], na.rm = TRUE)
NS.IRAI <- hydroGOF::NSE(mod.TOTAL[, 'IRAI'], obs.TOTAL[, 'IRAI'], na.rm = TRUE)
NS.SOBER <- hydroGOF::NSE(mod.TOTAL[, 'SOBER'], obs.TOTAL[, 'SOBER'], na.rm = TRUE)
NS.GARRU <- hydroGOF::NSE(mod.TOTAL[, 'GARRU'], obs.TOTAL[, 'GARRU'], na.rm = TRUE)
NS.PASOL <- hydroGOF::NSE(mod.TOTAL[, 'PASOL'], obs.TOTAL[, 'PASOL'], na.rm = TRUE)
NS.CONCO <- hydroGOF::NSE(mod.TOTAL[, 'CONCO'], as.numeric(obs.TOTAL[, 'CONCO']), na.rm = TRUE)
# ------------------------------------------------------------------

# ------------------------------------------------------------------
# ------------------ GUARDADO DE MATRIZ EN ARCHIVO -----------------
write.table(t(c(${cal_param_1}, ${cal_param_2}, ${cal_param_3}, ${cal_param_4}, ${cal_param_5}, ${cal_param_6}, ${cal_param_7}, RMSE.PELOT,RMSE.CANOA,RMSE.IRAI,RMSE.SOBER, RMSE.GARRU, RMSE.PASOL, RMSE.CONCO)), 
            paste0(path, salida.RMSE), 
            append = TRUE, row.names = FALSE, col.names = FALSE, 
            sep='\t')

#write.table(t(c(${cal_param_1}, ${cal_param_2}, ${cal_param_3}, ${cal_param_4}, ${cal_param_5}, ${cal_param_6}, ${cal_param_7}, RMSE.SOBER)),
#            paste0(path, salida.RMSE),
#            append = TRUE, row.names = FALSE, col.names = FALSE,
#            sep='\t')


write.table(t(c(${cal_param_1}, ${cal_param_2}, ${cal_param_3}, ${cal_param_4}, ${cal_param_5}, ${cal_param_6}, ${cal_param_7}, NS.PELOT,NS.CANOA,NS.IRAI,NS.SOBER, NS.GARRU, NS.PASOL, NS.CONCO)), 
            paste0(path, salida.NS), 
            append = TRUE, row.names = FALSE, col.names = FALSE, 
            sep='\t')

#write.table(t(c(${cal_param_1}, ${cal_param_2}, ${cal_param_3}, ${cal_param_4}, ${cal_param_5}, ${cal_param_6}, ${cal_param_7}, NS.SOBER)),
#            paste0(path, salida.NS),
#            append = TRUE, row.names = FALSE, col.names = FALSE,
#            sep='\t')
# ------------------------------------------------------------------

###########################################################################
############################ FINALIZADO ###################################
###########################################################################" >> ${path_ppal}estadisticos-cal7.R

###################################################################################################

Rscript ${path_ppal}'estadisticos-cal7.R' >> ${path_ppal}LOG7.txt

done


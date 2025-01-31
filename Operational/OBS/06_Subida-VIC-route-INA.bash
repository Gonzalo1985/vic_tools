#!/bin/bash

#**********************************************************************************
# Gonzalo M. Diaz
# MINISTERIO DE DEFENSA - Servicio Meteorologico Nacional, Buenos Aires, 15.06.2018
#
#**********************************************************************************
# Paso 06 -> De la operatividad del Modelo VIC + routeo
#            Subida de las salidas del Modelo VIC + routeo al grupo INA en FTP SMN
#**********************************************************************************
# El script corre las lineas para 'colgar' en el FTP del SMN (ftp.smn.gov.ar) las
# salidas producidas operativamente de las simulaciones de VIC + routeo de los
# puertos del rio Uruguay
#**********************************************************************************

###################################################################################################
### RUTA DE:
##### LOS ARCHIVOS DE SALIDA DEL MODELO route
path_route='/data/oper-hidro/VIC/Outputs/Out_route/'
path_para_ina='/data/oper-hidro/VIC/Outputs/Out_route/paraINA/'
###################################################################################################
### NOMBRES DE:
##### LOS ARCHIVOS A SUBIR, FECHA Y DEL FTP DONDE CARGAR
archivo_1='SMN_VIC0125_obs_GFS025_SOBER_'
archivo_2='SMN_VIC0125_obs_GFS025_GARRU_'
archivo_3='SMN_VIC0125_obs_GFS025_PASOL_'
#archivo_4='SMN_VIC0125_obs_GFS025_CONCE_'
archivo_5='SMN_VIC0125_obs_GFS025_CONCO_'
archivo_6='SMN_VIC0125_obs_GFS025_CANOA_'
archivo_7='SMN_VIC0125_obs_GFS025_PELOT_'
archivo_8='SMN_VIC0125_obs_GFS025_IRAII_'
DATE=`date +%Y%m%d`

USER='dpa'
PASSW='dpadpa&'
site='ftp.smn.gov.ar'
filesdir='/vila/VIC-salidas/'
###################################################################################################

cp ${path_route}'SOBER.day' ${path_para_ina}${archivo_1}${DATE}'.day'
cp ${path_route}'GARRU.day' ${path_para_ina}${archivo_2}${DATE}'.day'
cp ${path_route}'PASOL.day' ${path_para_ina}${archivo_3}${DATE}'.day'
#cp ${path_route}'CONCE.day' ${path_para_ina}${archivo_4}${DATE}'.day'
cp ${path_route}'CONCO.day' ${path_para_ina}${archivo_5}${DATE}'.day'
cp ${path_route}'CANOA.day' ${path_para_ina}${archivo_6}${DATE}'.day'
cp ${path_route}'PELOT.day' ${path_para_ina}${archivo_7}${DATE}'.day'
cp ${path_route}'IRAII.day' ${path_para_ina}${archivo_8}${DATE}'.day'

lftp -e 'mput '${path_para_ina}${archivo_1}${DATE}'.day'';exit' -u ${USER},${PASSW} ${site}${filesdir}
lftp -e 'mput '${path_para_ina}${archivo_2}${DATE}'.day'';exit' -u ${USER},${PASSW} ${site}${filesdir}
lftp -e 'mput '${path_para_ina}${archivo_3}${DATE}'.day'';exit' -u ${USER},${PASSW} ${site}${filesdir}
#lftp -e 'mput '${path_para_ina}${archivo_4}${DATE}'.day'';exit' -u ${USER},${PASSW} ${site}${filesdir}
lftp -e 'mput '${path_para_ina}${archivo_5}${DATE}'.day'';exit' -u ${USER},${PASSW} ${site}${filesdir}
lftp -e 'mput '${path_para_ina}${archivo_6}${DATE}'.day'';exit' -u ${USER},${PASSW} ${site}${filesdir}
lftp -e 'mput '${path_para_ina}${archivo_7}${DATE}'.day'';exit' -u ${USER},${PASSW} ${site}${filesdir}
lftp -e 'mput '${path_para_ina}${archivo_8}${DATE}'.day'';exit' -u ${USER},${PASSW} ${site}${filesdir}

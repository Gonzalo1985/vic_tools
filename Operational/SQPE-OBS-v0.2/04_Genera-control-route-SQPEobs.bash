#!/bin/bash

#**********************************************************************************
# Gonzalo M. Diaz
# MINISTERIO DE DEFENSA - Servicio Meteorologico Nacional, Buenos Aires, 11.09.2020
#
#**********************************************************************************
# Paso 04 -> De la operatividad del pronóstico hidrológico con VIC + routeo
#            Generación del archivo de Control del modelo route para la corrida
#            con SQPE-OBS-v0.2
#**********************************************************************************
# El script arma el archivo de control del route. Algunos de los parametros del 
# archivo de control son escritos en un archivo (param_control_file.txt) generado 
# en el paso 02
#**********************************************************************************

###################################################################################################
### RUTA DE: 
##### LOS ARCHIVOS DE SUELO Y VEGETACION DEL VIC
##### LOS ARCHIVOS DE PARAMETROS DEL route
##### LOS ARCHIVOS (fluxes) DE ENTRADA AL route
##### LOS ARCHIVOS (day,month,etc) DE SALIDA DEL route
path_PF_VIC='/data/oper-hidro/VIC/Parameter_Files/PF_VIC/SQPE-OBS-v0.2/'
path_PF_route='/data/oper-hidro/VIC/Parameter_Files/PF_route/SQPE-OBS-v0.2/'
path_fluxes='/data/oper-hidro/VIC/Outputs/Out_VIC_SQPE-OBS-v0.2/'
path_streamflow='/data/oper-hidro/VIC/Outputs/Out_route_SQPE-OBS-v0.2/'
###################################################################################################

CONTROL_route='CF_route.prn'
rm ${path_PF_route}${CONTROL_route}

###################################################################################################
### A PARTIR DEL ARCHIVO DEL paso 02 (param_control_file.txt) SE DEFINEN 16 VARIABLES 
### QUE DEBE LEER ESTE SCRIPT PARA ARMAR EL ARCHIVO DE CONTROL DEL VIC
cd ${path_PF_VIC}
value=$(<param_control_file.txt)
PART=($value)
#PART=(${value// / })
START_YEAR=$(echo ${PART[5]} | sed 's/[\"]//g')
START_MONTH=$(echo ${PART[3]} | sed 's/[\"]//g')
END_YEAR=$(echo ${PART[29]} | sed 's/[\"]//g')
END_MONTH=$(echo ${PART[27]} | sed 's/[\"]//g')
###################################################################################################
cd ${path_PF_route}

echo "# INPUT FILE FOR GENERAL BASIN
# NAME OF FLOW DIRECTION FILE
${path_PF_route}rout_dir.prn
#NAME OF VELOCITY FILE
.false.
1.5
# NAME OF DIFF FILE
.false.
800
# NAME OF XMASK FILE
.true.
${path_PF_route}lp_xmask.asc
# NAME OF FRACTION FILE
.true.
${path_PF_route}lp_frac.asc
# NAME OF STATION FILE
${path_PF_route}Loc_file.asc
# PATH OF INPUTS FILES AND PRECISION
${path_fluxes}fluxes_
4
# PATH OF OUTPUT FILES
${path_streamflow}
# MONTHS TO PROCESS
${START_YEAR} ${START_MONTH} ${END_YEAR} ${END_MONTH}
${START_YEAR} ${START_MONTH} ${END_YEAR} ${END_MONTH}
# NAME OF UNIT HYDROGRAPH FILE
${path_PF_route}uh_all
" >> $CONTROL_route 2>&1



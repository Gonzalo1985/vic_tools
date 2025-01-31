#!/bin/bash

#**********************************************************************************
# Gonzalo M. Diaz
# MINISTERIO DE DEFENSA - Servicio Meteorologico Nacional, Buenos Aires, 05.01.2016
#
#**********************************************************************************
# Paso 04 -> De la operatividad del Modelo VIC + routeo
#            Generación del archivo de Control del modelo route para la corrida
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
path_PF_VIC='/data/oper-hidro/VIC/Parameter_Files/PF_VIC/OBS/'
path_PF_route='/data/oper-hidro/VIC/Parameter_Files/PF_route/OBS/'
path_fluxes='/data/oper-hidro/VIC/Outputs/Out_VIC/'
path_streamflow='/data/oper-hidro/VIC/Outputs/Out_route/'
###################################################################################################

CONTROL_route='control_file_route.prn'
rm ${path_PF_route}${CONTROL_route}

###################################################################################################
### A PARTIR DEL ARCHIVO DEL paso 03 (param_control_file.txt) SE DEFINEN 7 VARIABLES 
### QUE DEBE LEER ESTE SCRIPT PARA ARMAR EL ARCHIVO DE CONTROL DEL VIC
### VARIABLES: ${PART[0]} , ${PART[1]} , ${PART[2]} , ${PART[3]} , ${PART[4]} , ${PART[5]} , ${PART[6]}
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
${path_PF_route}rout_direccion.prn
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
${path_PF_route}Location_file.asc
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



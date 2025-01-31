#!/bin/bash

#**********************************************************************************
# Gonzalo M. Diaz
# MINISTERIO DE DEFENSA - Servicio Meteorologico Nacional, Buenos Aires, 11.09.2020
#
#**********************************************************************************
# Paso 05 -> De la operatividad del pronóstico hidrológico con VIC + routeo
#            Corrida de los modelos VIC + routeo propiamente dicho forzado por
#            SQPE-OBS-v0.2
#**********************************************************************************
# El script corre las lineas de comando para correr el modelo VIC y luego el 
# modelo de routeo
#**********************************************************************************

###################################################################################################
### RUTA DE: 
##### LOS ARCHIVOS PARA CORRER EL MODELO VIC
##### LOS ARCHIVOS PARA CORRER EL MODELO route
##### LOS ARCHIVOS DE SUELO Y VEGETACION DEL VIC
##### LOS ARCHIVOS DE PARAMETROS DEL route
path_VIC='/data/oper-hidro/VIC/MHs/VIC-VIC.4.2.b/src/'
path_route='/data/oper-hidro/VIC/MHs/VIC_Routing-1.1_Fortran/src/'
path_PF_VIC='/data/oper-hidro/VIC/Parameter_Files/PF_VIC/SQPE-OBS-v0.2/'
path_PF_route='/data/oper-hidro/VIC/Parameter_Files/PF_route/SQPE-OBS-v0.2/'
###################################################################################################

cd ${path_VIC}
${path_VIC}vicNl -g ${path_PF_VIC}'control_file_VIC.prn'
cd ${path_route}
${path_route}rout ${path_PF_route}'CF_route.prn'



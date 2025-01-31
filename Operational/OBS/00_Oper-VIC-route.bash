#!/bin/bash

#**********************************************************************************
# Gonzalo M. Diaz
# MINISTERIO DE DEFENSA - Servicio Meteorologico Nacional, Buenos Aires, 08.01.2016
#**********************************************************************************
#
###################################################################################
### RUTA DE: 
##### LOS SCRIPTS DEL PROCESO DE VIC+ROUTE OPERATIVOS
path='/home/gdiaz/Documentos/VIC+route/OBS'
path_post='/home/gdiaz/Documentos/VIC+route/POST-PROCESAMIENTO'
###################################################################################
#
LOG=${path}'/LOG_VIC-route_operativo.txt'
rm ${LOG}
echo "---------------------------------------------------------------------------------------" >> $LOG 2>&1
echo "COMANDOS DE SALIDA DE LOS SCRIPTS DEL PROCESO DE SIMULACION DEL VIC Y ROUTE OPERATIVOS" >> $LOG 2>&1
echo "---------------------------------------------------------------------------------------" >> $LOG 2>&1
date >> $LOG 2>&1
echo " 
     " >> $LOG 2>&1
#
#
#**********************************************************************************
# Paso 01 -> De la operatividad del Modelo VIC + routeo
#            Kriging sobre las observaciones de la red de estaciones del SMN
#**********************************************************************************
Rscript ${path}/01_Interpola-Kriging.R >> $LOG 2>&1

#**********************************************************************************
# Paso 02 -> De la operatividad del Modelo VIC + routeo
#            Genera archivos "data" para leer por el VIC como archivos de entrada
#**********************************************************************************
Rscript ${path}/02b_Genera-data-VIC.R >> $LOG 2>&1

#**********************************************************************************
# Paso 03 -> De la operatividad del Modelo VIC + routeo
#            Generación del archivo de Control del modelo VIC para la corrida
#**********************************************************************************
${path}/03_Genera-control-VIC.bash >> $LOG 2>&1

#**********************************************************************************
# Paso 04 -> De la operatividad del Modelo VIC + routeo
#            Generación del archivo de Control del modelo route para la corrida
#**********************************************************************************
${path}/04_Genera-control-route.bash >> $LOG 2>&1

#**********************************************************************************
# Paso 05 -> De la operatividad del Modelo VIC + routeo
#            Corrida de los modelos VIC + routeo propiamente dicho
#**********************************************************************************
${path}/05_Corre-VIC-route.bash >> $LOG 2>&1

#**********************************************************************************
# Paso 06 -> De la operatividad del Modelo VIC + routeo
#            Subida de las salidas del Modelo VIC + routeo al grupo INA en FTP SMN
#**********************************************************************************
${path}/06_Subida-VIC-route-INA.bash >> $LOG 2>&1


echo " 
     " >> $LOG 2>&1
echo "---------------------------------------------------------------------------------------------" >> $LOG 2>&1
echo "COMANDOS DE SALIDA DE LOS SCRIPTS DEL POST-PROCESAMIENTO DE SIMULACION VIC Y ROUTE OPERATIVOS" >> $LOG 2>&1
echo "---------------------------------------------------------------------------------------------" >> $LOG 2>&1
echo " 
     " >> $LOG 2>&1
#
#
# ---------------------------------------------------------------------------------#
# Paso 01 -> Del post-procesamiento de los datos del Modelo VIC + routeo
#            Cálculo de estadísticos de la corrida operativa de VIC + routeo
# ---------------------------------------------------------------------------------#
Rscript ${path_post}/01_estadisticos-obs+imerg.R >> $LOG 2>&1

# ---------------------------------------------------------------------------------#
# Paso 02 -> Del post-procesamiento de los datos del Modelo VIC + routeo
#            Graficos de la evolucion temporal de los caudales de los puertos y su
#            pronostico
# ---------------------------------------------------------------------------------#
Rscript ${path_post}/02_graficos-obs+imerg.R >> $LOG 2>&1


echo "   " >> $LOG 2>&1
echo "-------------------------------------------FIN-----------------------------------------" >> $LOG 2>&1
echo "   " >> $LOG 2>&1
date >> $LOG 2>&1

cp ${path}'/LOG_VIC-route_operativo.txt' /ms-36/hidro/LOGs/



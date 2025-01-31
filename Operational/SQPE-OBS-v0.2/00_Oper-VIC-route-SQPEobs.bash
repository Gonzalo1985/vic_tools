#!/bin/bash

#**********************************************************************************
# Gonzalo M. Diaz
# MINISTERIO DE DEFENSA - Servicio Meteorologico Nacional, Buenos Aires, 04.09.2020
#**********************************************************************************
#
###################################################################################
### RUTA DE: 
##### LOS SCRIPTS DEL PROCESO DE VIC+ROUTE OPERATIVOS
path='/home/gdiaz/Documentos/VIC+route/SQPE-OBS-v0.2'
path_post='/home/gdiaz/Documentos/VIC+route/POST-PROCESAMIENTO'
###################################################################################
#
LOG=${path}'/LOG_VIC-route_operativo_SQPEobs.txt'
rm ${LOG}
echo "-----------------------------------------------------------------------------------------------------------------" >> $LOG 2>&1
echo "COMANDOS DE SALIDA DE LOS SCRIPTS DEL PROCESO DE SIMULACION DEL VIC Y ROUTE OPERATIVOS FORZADOS CON SQPE-OBS-v0.2" >> $LOG 2>&1
echo "-----------------------------------------------------------------------------------------------------------------" >> $LOG 2>&1
date >> $LOG 2>&1
echo " 
     " >> $LOG 2>&1
#
#
#************************************************************************************
# Paso 01 -> De la operatividad del pronóstico hidrológico con VIC + routeo
#            Interpolación Inverse-distance weighted(IDW) a los datos SQPE-OBS-v0.1
#************************************************************************************
Rscript ${path}/01_Interpola-IDW-SQPEobs.R >> $LOG 2>&1

#************************************************************************************
# Paso 02 -> De la operatividad del pronóstico hidrológico con VIC + routeo
#            Genera archivos "data" con precipitación Estimad SQPE-OBS-v0.1 para leer
#            por el VIC como archivos de entrada
#************************************************************************************
Rscript ${path}/02b_Genera-data-VIC-SQPEobs.R >> $LOG 2>&1

#************************************************************************************
# Paso 03 -> De la operatividad del pronóstico hidrológico con VIC + routeo
#            Generación del archivo de Control del modelo VIC para la corrida 
#            con SQPE-OBS-v0.2
#************************************************************************************
${path}/03_Genera-control-VIC-SQPEobs.bash >> $LOG 2>&1

#************************************************************************************
# Paso 04 -> De la operatividad del pronóstico hidrológico con VIC + routeo
#            Generación del archivo de Control del modelo route para la corrida
#            con SQPE-OBS-v0.2
#************************************************************************************
${path}/04_Genera-control-route-SQPEobs.bash >> $LOG 2>&1

#************************************************************************************
# Paso 05 -> De la operatividad del pronóstico hidrológico con VIC + routeo
#            Corrida de los modelos VIC + routeo propiamente dicho forzado por
#            SQPE-OBS-v0.2
#************************************************************************************
${path}/05_Corre-VIC-route-SQPEobs.bash >> $LOG 2>&1


echo "   " >> $LOG 2>&1
echo "-------------------------------------------FIN-----------------------------------------" >> $LOG 2>&1
echo "   " >> $LOG 2>&1
date >> $LOG 2>&1




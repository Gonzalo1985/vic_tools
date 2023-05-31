#!/bin/bash
#**********************************************************************************
# Gonzalo M. Diaz
# MINISTERIO DE DEFENSA - Servicio Meteorologico Nacional, Buenos Aires, 17.03.2020
#**********************************************************************************
#
# Bash script that defines all points inside the watershed that contribute to the
# indicated closing point
#
###################################################################################
start_time="$(date -u +%s)"
### PATH and LOG
path='/home/gdiaz/Documentos/Desarrollos/vic_tools/InWshed/'
LOG='aux_ModRuteo.txt'
###################################################################################

# Parameters and path definitions
lon_left='-66.8125'   # west longitude
lat_bottom='-37.9375' # south latitude

control_file='control_route.prn'
flow_file='rout_direccion.prn'
xmask_file='lp_xmask.asc'
fraction_file='lp_frac.asc'
location_file='Location_File.asc'
uh='uh_all'
# --------------------------------------------------------
rm ${path}${LOG}
rm ${path}'control_route.prn'
rm ${path}'Location_File.asc'
rm ${path}'find_latlon-watershed.R'

# User input parameters
lon=${1}
lat=${2}
nom=${3}
echo "La LONGITUD elegida del punto de cierre es "${lon}
echo "La LATITUD  elegida del punto de cierre es "${lat}
# --------------------------------------------------------

# ----------------------------------------------
# -- Definicion de cantidad de desplazamiento --
# ----- en lon y lat para el Location File -----
pos_lon=$(echo "$lon - $lon_left" | bc)
pos_lat=$(echo "$lat - $lat_bottom" | bc)

pos_lon=$(echo "$pos_lon / 0.125" | bc)
pos_lat=$(echo "$pos_lat / 0.125" | bc)
# ----------------------------------------------


# WRITING of Location File
echo "1 ${nom} ${pos_lon} ${pos_lat} -9999
NONE" >> ${path}${location_file}
# ---------------------------------------------------------------------------------------


# WRITING of Routing Model Control File
echo "# INPUT FILE FOR GENERAL BASIN
# NAME OF FLOW DIRECTION FILE
${path}${flow_file}
#NAME OF VELOCITY FILE
.false.
1.5
# NAME OF DIFF FILE
.false.
800
# NAME OF XMASK FILE
.true.
${path}${xmask_file}
# NAME OF FRACTION FILE
.true.
${path}${fraction_file}
# NAME OF STATION FILE
${path}${location_file}
# PATH OF INPUTS FILES AND PRECISION
/data/oper-hidro/VIC/Outputs/Out_VIC_testing_dataset/fluxes_
4
# PATH OF OUTPUT FILES
/data/oper-hidro/VIC/Outputs/Out_route_testing_dataset/
# MONTHS TO PROCESS
2020 1 2020 2
2020 1 2020 2
# NAME OF UNIT HYDROGRAPH FILE
${path}uh_all" >> ${path}${control_file}
# ---------------------------------------------------------------------------------------


# EXECUTION of the Routing Model
/data/oper-hidro/VIC/MHs/VIC_Routing-1.1_Fortran/src/rout ${path}${control_file} >> $LOG 2>&1
# ---------------------------------------------------------------------------------------


# WRITING of the R Script that uses lon and lat from the LOG and creates the output file
echo "rm(list=ls())

aux.ModRuteo <- read.fwf('${path}aux_ModRuteo.txt',
                         widths = 108, stringsAsFactors = FALSE)

fila.a.leer <- which(grepl('Number of grid cells upstream of present station',
                           aux.ModRuteo[,1]) == TRUE)

cantidad.de.puntos <- aux.ModRuteo[fila.a.leer,]
cantidad.de.puntos <- as.numeric(substr(x = cantidad.de.puntos, 
                                        start = 57, 
                                        stop = nchar(cantidad.de.puntos)))

fila.inicial <- 13 + cantidad.de.puntos + 3
fila.final <- fila.inicial + cantidad.de.puntos - 1

vector.puntos <- aux.ModRuteo[fila.inicial:fila.final,]
vector.outlier <- which(nchar(vector.puntos) != nchar(vector.puntos[1]))
if (length(vector.outlier) != 0)
  {vector.puntos <- vector.puntos[-vector.outlier]}

vector.lat <- substr(x = vector.puntos, start = 92 , stop = 99 )
vector.lon <- substr(x = vector.puntos, start = 101, stop = 108)

vector.puntos <- cbind(as.numeric(vector.lat), as.numeric(vector.lon))
colnames(vector.puntos) <- c('lat', 'lon')

write.table(x = vector.puntos, 'puntos-cuenca-cierre_en_${lat}_${lon}.txt', sep = '\t', row.names = FALSE, col.names = TRUE)
" >> ${path}'find_latlon-watershed.R'
# ---------------------------------------------------------------------------------------

/usr/bin/Rscript ${path}'find_latlon-watershed.R'

end_time="$(date -u +%s)"
elapsed="$(($end_time-$start_time))"

echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "
echo " - - - - End of process - approximate elapsed time: ${elapsed} seconds - - - -"
echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "


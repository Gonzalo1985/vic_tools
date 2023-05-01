rm(list=ls())

aux.ModRuteo <- read.fwf('/home/gdiaz/Documentos/Desarrollos/vic_tools/InWshed/aux_ModRuteo.txt',
                         widths = 108, stringsAsFactors = FALSE)

cantidad.de.puntos <- aux.ModRuteo[5,]
cantidad.de.puntos <- as.numeric(substr(x = cantidad.de.puntos, 
                                        start = 57, 
                                        stop = nchar(cantidad.de.puntos)))

fila.inicial <- 13 + cantidad.de.puntos + 2
fila.final <- fila.inicial + cantidad.de.puntos

vector.puntos <- aux.ModRuteo[fila.inicial:fila.final,]
vector.outlier <- which(nchar(vector.puntos) != nchar(vector.puntos[1]))
vector.puntos <- vector.puntos[-vector.outlier]

vector.lat <- substr(x = vector.puntos, start = 92 , stop = 99 )
vector.lon <- substr(x = vector.puntos, start = 101, stop = 108)

vector.puntos <- cbind(as.numeric(vector.lat), as.numeric(vector.lon))
colnames(vector.puntos) <- c('lat', 'lon')

write.table(x = vector.puntos, 'puntos-cuenca-cierre_en_-27.0625_-52.9375.txt', sep = '\t', row.names = FALSE, col.names = TRUE)


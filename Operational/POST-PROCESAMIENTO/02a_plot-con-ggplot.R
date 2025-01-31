# ----------------------------------------------------------------------------
# Carga de Librerias para graficado con ggplot ----
suppressMessages(library("ggplot2"))
suppressMessages(library("xts"))
suppressMessages(library("scales"))
suppressMessages(library("ggrepel"))
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# Nombres de títulos para gráficos y nombres de columnas ----
titulos.graf <- c("Pelotas", "Canoas", "Irai", "El Soberbio",
                  "Garruchos", "Paso de los Libres",
                  "Concordia")
nombres.VIC  <- c("PELOT", "CANOA", "IRAII", "SOBER",
                  "GARRU", "PASOL", "CONCO")
# ----------------------------------------------------------------------------

png(paste0(path.salida, Sys.Date(), "_", colnames(DATA.simula.1)[i], ".png"), width = 8, height = 6, units = 'in', res = 500)

# setea parámetros iniciales de gráfico: título, color de fondo y línea y posición del título
p.3 <- ggplot() + ggtitle(titulos.graf[i]) + 
                  theme(panel.background = element_rect(fill = '#ececec', colour = 'black')) + 
                  theme(plot.title = element_text(hjust = 1))

# Plotea las series simuladas VIC con obs, imerg, banda de RMSE y observaciones de caudal
p.3 <- p.3 +  
       geom_line(data = DATA.simula.1, aes(index(DATA.simula.1), DATA.simula.1[, i]/35.3, colour = "VIC obs"), size = 0.9) +
       geom_ribbon(aes(x = index(DATA.simula.1), 
                       ymin = (DATA.simula.1[, i]/35.3) - estadisticos[nombres.VIC[i], "RMSE"], 
                       ymax = (DATA.simula.1[, i]/35.3) + estadisticos[nombres.VIC[i], "RMSE"], colour = "banda RMSE VIC obs"), 
                   alpha=0.2) +
       geom_line(data = DATA.simula.4, aes(index(DATA.simula.4), DATA.simula.4[, i]/35.3, colour = "VIC SQPE-OBS-v0.2"), size = 0.9) +
       geom_point(data = DATA.observa[,i], aes(index(DATA.observa), DATA.observa[, i], colour = "obs"), size = 1.0)

# Plotea la serie simulada VIC con obs+GFS 0.25° e indica color de cada serie
p.3 <- p.3 + geom_line(data = DATA.prono.1, aes(index(DATA.prono.1), DATA.prono.1[, i]/35.3, colour = "VIC obs+GFS 0.25°"), size = 0.9) + 
       scale_color_manual(values = c("#bababa", "#078446", "#000000", "#0080ff", "#ffa500"))

max.limit <- max(c(max(DATA.observa[,i], DATA.simula.1[,i]/35.3, DATA.simula.4[,i]/35.3)))

# Define ejes X e Y: nombres, posiciones, etc.
p.3 <-  p.3 + 
        scale_y_continuous(name = "Caudal Diario (m^3/seg)", limits = c(0,25000), oob = rescale_none) + #max.limit+1000
        scale_x_date(name = "", limits = as.Date(c(rango.graf[1], rango.graf[3])), date_breaks = "5 days") +
        theme(axis.text.x = element_text(angle = 90, vjust = 0))

# Define los niveles de alerta y evacuación
p.3 <- p.3 + 
       geom_hline(yintercept = nivel.pto.aler[i], linetype = "dashed", color = "#cfcd00") +
       geom_hline(yintercept = nivel.pto.evac[i], linetype = "dashed", color = "#ff0000") +
       annotate("text", x = index(DATA.simula.1)[10], y = nivel.pto.aler[i] - 500, label= "Nivel de alerta", size = 3.0) +
       annotate("text", x = index(DATA.simula.1)[10], y = nivel.pto.evac[i] - 500, label= "Nivel de evacuación", size = 3.0)

# Anota los valores de los estadísticos [R, RMSE y NS] para las simulaciones con observaciones en modo operativo
#if (i == 2)
#  {p.3 <- p.3 + 
#          annotate("label", fill =  "#d3d5e7", x = index(DATA.simula.1)[10], y = 28500, label = "obs vs VIC-obs:", size = 2.5) +
#          annotate("text", x = index(DATA.simula.1)[33], y = 30000, label = paste0("R = ", estadisticos["GARRU", "R"]), size = 2.5) +
#          annotate("text", x = index(DATA.simula.1)[33], y = 28500, label = paste0("RMSE = ", estadisticos["GARRU", "RMSE"]), size = 2.5) +
#          annotate("text", x = index(DATA.simula.1)[33], y = 27000, label = paste0("NS = ", estadisticos["GARRU", "NS"]), size = 2.5) +
#          annotate("label", fill = "#d3d5e7", x = index(DATA.simula.1)[10], y = 23000, label = "obs vs VIC-Imerg:", size = 2.5) +
#          annotate("text", x = index(DATA.simula.1)[33], y = 24500, label = paste0("R = ", estadisticos.imerg["GARRU", "R"]), size = 2.5) +
#          annotate("text", x = index(DATA.simula.1)[33], y = 23000, label = paste0("RMSE = ", estadisticos.imerg["GARRU", "RMSE"]), size = 2.5) +
#          annotate("text", x = index(DATA.simula.1)[33], y = 21500, label = paste0("NS = ", estadisticos.imerg["GARRU", "NS"]), size = 2.5) +
#          annotate("label", fill = "#d3d5e7", x = index(DATA.simula.1)[60], y = 28500, label = "obs vs VIC-SQPE-v0.1:", size = 2.5) +
#          annotate("text", x = index(DATA.simula.1)[85], y = 30000, label = paste0("R = ", estadisticos.sqpe.01["GARRU", "R"]), size = 2.5) +
#          annotate("text", x = index(DATA.simula.1)[85], y = 28500, label = paste0("RMSE = ", estadisticos.sqpe.01["GARRU", "RMSE"]), size = 2.5) +
#          annotate("text", x = index(DATA.simula.1)[85], y = 27000, label = paste0("NS = ", estadisticos.sqpe.01["GARRU", "NS"]), size = 2.5)
#  }

# Anota los valores de los estadísticos [R, RMSE y NS] para las simulaciones con observaciones en modo operativo
#if (i == 3)
#  {p.3 <- p.3 + 
#          annotate("label", fill =  "#d3d5e7", x = index(DATA.simula.1)[10], y = 28500, label = "obs vs VIC-obs:", size = 2.5) +
#          annotate("text", x = index(DATA.simula.1)[33], y = 30000, label = paste0("R = ", estadisticos["PASOL", "R"]), size = 2.5) +
#          annotate("text", x = index(DATA.simula.1)[33], y = 28500, label = paste0("RMSE = ", estadisticos["PASOL", "RMSE"]), size = 2.5) +
#          annotate("text", x = index(DATA.simula.1)[33], y = 27000, label = paste0("NS = ", estadisticos["PASOL", "NS"]), size = 2.5) +
#          annotate("label", fill = "#d3d5e7", x = index(DATA.simula.1)[10], y = 23000, label = "obs vs VIC-Imerg:", size = 2.5) +
#          annotate("text", x = index(DATA.simula.1)[33], y = 24500, label = paste0("R = ", estadisticos.imerg["PASOL", "R"]), size = 2.5) +
#          annotate("text", x = index(DATA.simula.1)[33], y = 23000, label = paste0("RMSE = ", estadisticos.imerg["PASOL", "RMSE"]), size = 2.5) +
#          annotate("text", x = index(DATA.simula.1)[33], y = 21500, label = paste0("NS = ", estadisticos.imerg["PASOL", "NS"]), size = 2.5) +
#          annotate("label", fill = "#d3d5e7", x = index(DATA.simula.1)[60], y = 28500, label = "obs vs VIC-SQPE-v0.1:", size = 2.5) +
#          annotate("text", x = index(DATA.simula.1)[85], y = 30000, label = paste0("R = ", estadisticos.sqpe.01["PASOL", "R"]), size = 2.5) +
#          annotate("text", x = index(DATA.simula.1)[85], y = 28500, label = paste0("RMSE = ", estadisticos.sqpe.01["PASOL", "RMSE"]), size = 2.5) +
#          annotate("text", x = index(DATA.simula.1)[85], y = 27000, label = paste0("NS = ", estadisticos.sqpe.01["PASOL", "NS"]), size = 2.5)
#  }

print(p.3)

dev.off()


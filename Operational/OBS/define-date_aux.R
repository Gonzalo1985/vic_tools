if (as.integer(mes_aux) == 1 | as.integer(mes_aux) == 3 |
    as.integer(mes_aux) == 5 | as.integer(mes_aux) == 7 |
    as.integer(mes_aux) == 8 | as.integer(mes_aux) == 10 |
    as.integer(mes_aux) == 12)
  {date_aux <- as.Date(paste0(ano_aux, "-",
                              mes_aux, "-",
                              as.integer(dia_aux) + (31-as.integer(dia_aux))))}


if (as.integer(mes_aux) == 4 | as.integer(mes_aux) == 6 |
    as.integer(mes_aux) == 9 | as.integer(mes_aux) == 11)
  {date_aux <- as.Date(paste0(ano_aux, "-",
                              mes_aux, "-",
                              as.integer(dia_aux) + (30-as.integer(dia_aux))))}

if (as.integer(mes_aux) == 2){
  if (as.integer(ano_aux)%%4==0 & as.integer(ano_aux)%%100!=0 |
      as.integer(ano_aux)%%400==0)
    {date_aux <- as.Date(paste0(ano_aux, "-",
                                mes_aux, "-",
                                as.integer(dia_aux) + (29-as.integer(dia_aux))))} else
    {date_aux <- as.Date(paste0(ano_aux, "-",
                                mes_aux, "-",
                                as.integer(dia_aux) + (28-as.integer(dia_aux))))}
}
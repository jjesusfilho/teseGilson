


g2 <- list.files(here::here("data-raw"),pattern = "Julgados_", full.names = T)


julgamentos <- purrr::map_dfr(g2, ~{
  
  ano <- stringr::str_extract(.x,"\\d{4}")
  
  read_delim(.x, 
             delim = ";", escape_double = FALSE, locale = locale(encoding = "ISO-8859-1"), 
             trim_ws = TRUE) |> 
    janitor::clean_names() |> 
    filter(classe == "Apelação Criminal")
})


julgamentos <- julgamentos |> 
     mutate(dta_julg = janitor::convert_to_datetime(
       dta_julg,
       character_fun=lubridate::dmy, truncated=1))

julgamentos <- julgamentos |> 
  mutate(dta_distr = janitor::convert_to_datetime(
    dta_distr,
    character_fun=lubridate::dmy, truncated=1))

julgamentos <- julgamentos |> 
    mutate(ano_julg = year(dta_julg))

DBI::dbExecute(conn,"set search_path = gilson")
DBI::dbWriteTable(conn,"apelacoes", julgamentos)



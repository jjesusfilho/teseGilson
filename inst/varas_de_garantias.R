#!/usr/bin/env Rscript

### Esses são os foros que apareceram no ESAJ com juizes de garantias.

### A coleta foi realizada em 12/04/2025

sequencias <- c("385","378") |> 
  purrr::map(~{
    
    JurisMiner::cnj_sequencial(1500001,1520000,ano = 2025,segmento = 8,uf = 26,distribuidor = .x)
  }) |> 
  unlist()

diretorio <- here::here("data-raw/garantias/api")


esajapollo::apollo_tjsp_api_baixar(valor = sequencias, diretorio = diretorio)

df <- esajapollo::apollo_tjsp_api_ler(diretorio = diretorio)

df <- df |> 
     dplyr::filter(!is.na(cd_processo)) |> 
     dplyr::mutate(data_recebimento = lubridate::dmy(data_recebimento))

DBI::dbExecute(conn,"create schema gilson")

DBI::dbExecute(conn,"set search_path = gilson")

DBI::dbWriteTable(conn,"api_garantias", df)

DBI::dbExecute(conn,"comment on table  api_garantias is 'Esta tabela representa a coleta realizada da api do esaj em Santos e Sorocaba no juiz de garantias.
               devemos retornar a essas bases mais adiante para sabe se houve condenação'")






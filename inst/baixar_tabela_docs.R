#!/usr/bin/env Rscript

conn <- DBI::dbConnect(odbc::odbc(), Driver = "PostgreSQL Unicode", 
                       Server = "localhost", Database = "projetos", UID = "postgres", 
                       PWD = "8fxQv2VYYzEH7Mev")


cd_processo <- DBI::dbGetQuery(conn,"select distinct cd_processo from gilson.amostra") |> 
  dplyr::pull(cd_processo) |> 
  JurisMiner::dividir_sequencia(n = 2000)

DBI::dbDisconnect(conn)

#gmailr::gm_auth("jjesusfilho@gmail")

diretorio <- here::here('data-raw/tabela_docs')

purrr::walk(cd_processo, ~{
  
  tjsp::tjsp_autenticar(email_provider = "gmail")
  
  tjsp::tjsp_baixar_tabela_cd_processo(.x, diretorio = diretorio)
  
})


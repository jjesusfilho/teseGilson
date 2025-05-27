#!/usr/bin/env Rscript

conn <- DBI::dbConnect(odbc::odbc(), Driver = "PostgreSQL Unicode", 
                           Server = "localhost", Database = "projetos", UID = "postgres", 
                           PWD = "8fxQv2VYYzEH7Mev")

DBI::dbExecute(conn,"set search_path = gilson")

cd_processo <- DBI::dbGetQuery(conn,"select distinct cdprocesso from historico_parte_coletado d1
                               where not exists(
                               select from cpopg_dados d2
                               where d1.cdprocesso = d2.codigo_processo)
                               ") |> 
       dplyr::pull(cdprocesso) |> 
       JurisMiner::dividir_sequencia(n = 3000)


#gmailr::gm_auth("jjesusfilho@gmail")

diretorio <- here::here('data-raw/cpopg')

purrr::walk(cd_processo, ~{
  
  tjsp::tjsp_autenticar(email_provider = "gmail")
  
  tjsp::tjsp_baixar_cpopg_cd_processo(.x, diretorio = diretorio)
  
})


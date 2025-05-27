#!/usr/bin/env Rscript

diretorio <- here::here("data-raw/historico_partes")

db <- JurisMiner::listar_arquivos(diretorio) |> 
      tibble::tibble(arquivo = _) |> 
      dplyr::mutate(cdprocesso = stringr::str_extract(arquivo,"(?<=cd_processo_)[A-Z0-9]+"))

#DBI::dbWriteTable(conn,"historico_parte_coletado", dplyr::select(db,cdprocesso))

conn <- DBI::dbConnect(odbc::odbc(), Driver = "PostgreSQL Unicode", 
                       Server = "localhost", Database = "projetos", UID = "postgres", 
                       PWD = "8fxQv2VYYzEH7Mev")

DBI::dbExecute(conn,"set search_path = gilson")

leitura <- DBI::dbGetQuery(conn,"select cdprocesso from historico_parte_coletado d1
                           where not exists(
                           select from historico_parte_principal d2
                           where d1.cdprocesso = d2.cdprocesso
                           )
                           ")

arquivos <- db |> 
    dplyr::semi_join(leitura) |> 
    dplyr::pull(arquivo) |> 
    JurisMiner::dividir_sequencia(n = 2000)

purrr::walk(arquivos, purrr::possibly(~{
  
lista <- tjsp::tjsp_ler_historico_parte_cd_processo(.x)


lista <- purrr::compact(lista)

principal <- purrr::map_dfr(lista, ~{
  
  .x[["principal"]]
})



dbx::dbxInsert(conn,"historico_parte_principal", principal)

documentos <- purrr::map_dfr(lista, ~{
  
  .x[["documentos"]]
})

dbx::dbxInsert(conn,"historico_parte_documentos", documentos )

historico <- purrr::map_dfr(lista, ~{
  
  .x[["historico"]]
})

dbx::dbxInsert(conn,"historico_parte_historico",historico )


link <- purrr::map_dfr(lista, ~{
  
  .x[["link"]]
})

dbx::dbxInsert(conn,"historico_parte_link", link )

}, NULL))

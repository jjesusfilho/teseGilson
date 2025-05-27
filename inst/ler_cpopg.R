#!/usr/bin/env Rscript


conn <- DBI::dbConnect(odbc::odbc(), Driver = "PostgreSQL Unicode", 
                       Server = "localhost", Database = "projetos", UID = "postgres", 
                       PWD = "8fxQv2VYYzEH7Mev")

DBI::dbExecute(conn,"set search_path = gilson")

diretorio <- here::here('data-raw/cpopg')

arquivos <- JurisMiner::listar_arquivos(diretorio) |> 
            JurisMiner::dividir_sequencia(n = 1000)


purrr::walk(arquivos, ~{
  
dados <-   tjsp::tjsp_ler_dados_cpopg(.x)

DBI::dbAppendTable(conn,"cpopg_dados", dados, where_cols = "codigo_processo")

partes <-  tjsp::tjsp_ler_partes_cd_processo(.x)


DBI::dbAppendTable(conn,"cpopg_partes", partes)


mov <- tjsp::tjsp_ler_movimentacao(.x)
  

DBI::dbAppendTable(conn,"cpopg_mov", mov)


peticoes_diversas <- tjsp::tjsp_ler_peticoes_diversas(.x)
  

DBI::dbAppendTable(conn,"cpopg_peticoes_diversas", peticoes_diversas)

historico_classes <- tjsp::tjsp_ler_historico_classes(.x)
  

DBI::dbAppendTable(conn,"cpopg_historico_classes", historico_classes)

unlink(.x)

rm(dados, partes, mov,peticoes_diversas, historico_classes)

})


DBI::dbDisconnect(conn)




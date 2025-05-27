

diretorio <- here::here('data-raw/tabela_docs')


a <- JurisMiner::listar_arquivos(diretorio) |> 
     JurisMiner::dividir_sequencia(g = 5)
  


future::plan(future.callr::callr(), workers = 5)



tb <- furrr::future_map_dfr(a, ~{
  
  .x |> 
    tjsp::tjsp_ler_tabela_docs_cd_processo()
    
  
})

DBI::dbExecute(conn,"set search_path = gilson")


dbCreateTable(conn,"tabela_docs", tabela)

q <- "create table tabela_docs (cd_processo_pg text,
                  cd_processo_sg text,
instancia text,
id_doc text,
doc_name text,
pagina_inicial text,
pagina_final text,
url_doc text)"


DBI::dbExecute(conn, q)

dbx::dbxInsert(conn, "tabela_docs", tabela, batch_size = 10000)


library(readr)



f <- function(x, pos){
x |> 
    dplyr::select(dplyr::any_of(c("cd_processo_pg", "cd_processo_sg", "instancia", "id_doc", 
                                                     "doc_name", "pagina_inicial", "pagina_final", "url_doc"))) |> 
DBI::dbAppendTable(conn, DBI::SQL("gilson.tabela_docs"),value = _ )
  
}


#df <- data.table::fread("tabela.csv",nrows=10)

DBI::dbAppendTable(conn,DBI::SQL("gilson.tabela_docs"), df)

readr::read_csv2_chunked("tabela.csv", callback = readr::DataFrameCallback$new(f),
                              chunk_size = 1000, col_types = "c")

k<- read.csv2("tabela.csv", nrows= 10)


tabela <- tabela |> 
      dplyr::mutate(grupo = dplyr::ntile(n = 100)) |> 
      dplyr::group_split(grupo)
arquivos <- paste0("tabelas/",1:100,".rds")

purrr::walk2(tabela, arquivos, ~{
      
saveRDS(.x, .y)
    })



a <- JurisMiner::listar_arquivos("tabelas")


purrr::walk(a, ~{
  readRDS(.x) |> 
    dplyr::select(-grupo) |> 
    DBI::dbAppendTable(conn,DBI::SQL("gilson.tabela_docs"),value = _)
})

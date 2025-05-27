#!/usr/bin/env Rscript


conn <- DBI::dbConnect(odbc::odbc(), Driver = "PostgreSQL Unicode", 
                       Server = "localhost", Database = "projetos", UID = "postgres", 
                       PWD = "8fxQv2VYYzEH7Mev")

DBI::dbExecute(conn,"set search_path = gilson")

q <- "with cte as (
     select id,  cd_processo,ano_recebimento, foro, 
     row_number() over (partition by foro order by random())::int as n
     from api_filtrada_com_entrancia d1
     where not exists(
     select from amostra d2
     where d1.cd_processo = d2.cd_processo
     )
)
select * from cte
where n >= 30 
order by random()
limit 120000"

cd_processo <- DBI::dbGetQuery(conn, q) |> 
            dplyr::filter(n >= 30) |> 
            dplyr::group_by(foro) |> 
            dplyr::filter(dplyr::n() >= 30) |> 
            dplyr::pull(cd_processo) |> 
JurisMiner::dividir_sequencia(n = 3000)

DBI::dbDisconnect(conn)

diretorio <- here::here("data-raw/historico_partes")

gmailr::gm_auth("jjesusfilho@gmail.com")

purrr::walk(cd_processo, purrr::possibly(~{

tjsp::tjsp_autenticar(email_provider = "gmail")
  
purrr::walk(.x, purrr::possibly(~{
  

tjsp::tjsp_baixar_historico_parte_cd_processo(.x,diretorio )
  
},NULL))

},NULL))



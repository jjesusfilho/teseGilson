library(tidyverse)
DBI::dbExecute(conn,"set search_path = gilson")
tabela <- DBI::dbGetQuery(conn,"select * from tabela_docs where cd_processo_pg = '0M0001YXI0000'")

tabela <- tabela |> 
     mutate(id_doc = as.numeric(id_doc),pagina_inicial = as.numeric(pagina_inicial)) |> 
     arrange(id_doc, pagina_inicial)


hp <- DBI::dbGetQuery(conn,"select * from historico_parte_historico where evento ~* 'Acórdão'")

hp <- DBI::dbGetQuery(conn,"select * from historico_parte_historico where cdprocesso ~* '01001DHQT0000'")


q <- "with cte as (
select cdprocesso from historico_parte_historico where evento ~* 'Acórdão'
)
select * from historico_parte_historico d1 where exists 
(select from cte 
where d1.cdprocesso = cte.cdprocesso)"

base <- DBI::dbGetQuery(conn, q)


sentenca <- base |> 
      filter(str_detect(evento, "^(?i)sentença"))

condena <- base |> 
  filter(str_detect(evento, "(?i)sentença condena"))

acordaos <- base |> 
      filter(cdprocesso %in% condena$cdprocesso, str_detect(evento, "(?i)Acórdão - Sentença"))

df1 <- count(acordaos, evento, sort = T) 



flagrante <- DBI::dbGetQuery(conn,"select * from cpopg_mov 
                             where descricao ~* 'flagrante'")


auto <- DBI::dbGetQuery(conn,"select * from cpopg_historico_classes
                        where classe = 'Auto de Prisão em Flagrante'")


b <- union(auto$processo, flagrante$processo)



sentencas <- DBI::dbGetQuery(conn,"
                             select processo, movimento
                             from gilson.cpopg_mov
                             where movimento ~* '^Julgad'
                             ")


s <- DBI::dbGetQuery(conn,"select * from gilson.cpopg_mov where processo = '00002586420188260556'")



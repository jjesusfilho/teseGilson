
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
  filter(cdprocesso %in% condena$cdprocesso, str_detect(evento, "(?i)Acórdão - Sentença")) |> 
    separate_wider_delim(cols = evento, delim = '/', names = c("sentenca","acordao"), too_many = "drop",
                         too_few = "align_start") |> 
      filter(str_detect(acordao,'(?i)(condena|abso)')) |> 
    mutate(sentenca = str_extract(sentenca, "Senten.+"),
           acordao = ifelse(str_detect(acordao,"(?i)condena"), "Condenatória","Absolutória")) |> 
      count(sentenca,acordao)

flagrante <- DBI::dbGetQuery(conn,"select * from cpopg_mov 
                             where descricao ~* 'flagrante'")


auto <- DBI::dbGetQuery(conn,"select * from cpopg_historico_classes
                        where classe = 'Auto de Prisão em Flagrante'")


flagrantes  <- union(auto$processo, flagrante$processo)
n_flagrantes <- length(flagrantes)

ano_autuacao <- DBI::dbGetQuery(conn,"select count(*)::int as n,extract(year from dta_distr) as ano
                               from apelacoes
                               where assunto !~* '(aborto|cídio)'
                               and assunto != 'Crimes contra a vida'
                                group by extract(year from dta_distr)")


apelacoes <- DBI::dbGetQuery(conn,"select assunto as crime, result_julg as merito,
                               parte_ativa as apelante, ano_julg as ano 
                               from apelacoes
                               where assunto !~* '(aborto|cídio)'
                               and assunto != 'Crimes contra a vida'")



apelacoes |> 
    filter(merito %in% c("Provimento","Provimento em Parte","Não-Provimento")) |> 
    mutate(merito = ifelse(merito == "Não-Provimento","Não-provimento", "Provimento")) |> 
    mutate(apelante = ifelse(apelante == 'Minstério Público',"Ministério Público", apelante)) |> 
    count(apelante, merito, ano) |> 
    mutate(ano = as.factor(ano)) |> 
    ggplot(aes(x = n, y = ano, fill = merito))+
    geom_bar(stat = "identity") +
    facet_grid(~apelante,scales = "free")


apelacoes <- apelacoes |> 
   mutate(merito2 = tjsp::tjsp_classificar_recurso(merito))

apelacoes <- apelacoes |>  
  mutate(merito2 = case_when(
    str_detect(merito, "(?i)provimento e ") ~ "Provimento/Não-Provimento",
    str_detect(merito, "(?i)Não.{1,3}Provimento") ~ "Não-Provimento",
    str_detect(merito,"(?i)extinção da punibilidade") ~ "Extinção da punibilidade",
    merito2 == "provido" ~ "Provimento",
    merito2 == "improvido" ~ "Não-Provimento",
    merito2 == "parcial" ~ "Provimento parcial",
    is.na(merito) ~ "Outros",
    TRUE ~ merito2
))

apelacoes <- apelacoes |> 
mutate(merito2 = str_to_sentence(merito2,locale ="pt"))

DBI::dbWriteTable(conn,"apelacoes2", apelacoes, overwrite = T)

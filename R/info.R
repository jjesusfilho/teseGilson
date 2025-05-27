

mov <- DBI::dbGetQuery(conn,"select count(*)::int as n, movimento from gilson.cpopg_mov
                       group by movimento")


info <- c("Arquivado Definitivamente - Processo Findo com Condenação",
          "Condenação à Pena Privativa de Liberdade SEM Decretação da prisão",
          "Sentença de Absolvição - Não existir prova suficiente para condenação (Art. 386, VII, CPP)",
          "Julgada Procedente a Ação",
          "Condenação à Pena Privativa de Liberdade Substituída por Restritiva de Direito",
          "Extinta a Punibilidade por Cumprimento da Suspensão Condicional do Processo",
          "Condenação à Pena Privativa de Liberdade com Suspensão Condicional da Pena - SURSIS",
          ""
          )

regex <- "(sentença|condenação|extinta a punibilidade|^julgad[ao]|^sentença|Extinto o Processo|absolvição|	
Trancamento)"

q <- glue::glue_sql(conn,"select cd_processo, movimento from gilson.cpopg_mov
                    where movimento ~* {regex} ", .con = conn)


s <- DBI::dbGetQuery(conn, "select cd_processo, movimento from gilson.cpopg_mov
where movimento ~* '(^sentença|condenação|extinta a punibilidade|^julgad[ao]|^sentença|Extinto o
  Processo|absolvição|Trancamento)'")


s <- s |> 
    
    dplyr::mutate(decisao = dplyr::case_when(
      stringr::str_detect(movimento, "(?i)condena")  ~ "procedente",
      stringr::str_detect(movimento, "(?i)\\bprocedente")  ~ "procedente",
      stringr::str_detect(movimento, "(?i)absol")  ~ "improcedente",
      stringr::str_detect(movimento, "(?i)improcedente")  ~ "improcedente",
      stringr::str_detect(movimento, "(?i)condenacao")  ~ "procedente",
    ))

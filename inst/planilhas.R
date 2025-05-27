
arquivo <- "data-raw/Pesquisa_CPA_2024_032303_Dr_GILSON (1).xlsx"
planilhas <- openxlsx::getSheetNames(arquivo)


lista <- planilhas |> 
    purrr::map(~{
      readxl::read_xlsx(arquivo, sheet = .x)
      
    })


glossario <- lista[[15]]

denuncias <- lista[[2]]



sent <- lista[[3]] |> 
     janitor::clean_names() |> 
     group_by(ano,resumo) |> 
     summarise(total = sum(total))

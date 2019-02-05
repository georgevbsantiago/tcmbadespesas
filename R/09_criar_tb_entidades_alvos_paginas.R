#' @title Função que gera os dados das entidades alvos que servirão de parâmetro
#' para as requisições das páginas
#' 
#' @param cod_municipios_alvos Código dos Municípios alvos
#' @param sgbd Define qual é o Banco de Dados a ser utilizado.
#' Por padrão, é definido o SQLite.
#' 
#' @importFrom magrittr %>%
#'

criar_tb_entidades_alvos_paginas <- function(cod_municipios_alvos, sgbd){


    tb_dcalendario <- DBI::dbReadTable(connect_sgbd(sgbd), "tabela_dcalendario") %>%
        dplyr::select("ano") %>%
        tibble::as_tibble() %>%
        dplyr::distinct()
    
    DBI::dbDisconnect(connect_sgbd(sgbd))


    tb_municipios_alvos_novos <- DBI::dbReadTable(connect_sgbd(sgbd), "tabela_tcm_dmunicipios_entidades") %>%
        tibble::as_tibble() %>% 
        dplyr::filter(cod_municipio %in% cod_municipios_alvos) %>%
        dplyr::mutate(pagina = "1") %>%
        dplyr::select("cod_municipio", "nm_municipio",
                      "cod_entidade", "nm_entidade", "pagina")
        

    # !!! Verificar a necessidade de realizar essa troca
    # tb_municipios_alvos_novos <- tidyr::crossing(tb_dcalendario,
    #                                              tb_municipios_alvos_novos) %>% 
    tb_municipios_alvos_novos <- merge.data.frame(tb_dcalendario,
                                                  tb_municipios_alvos_novos) %>%
                                tibble::as_tibble() %>%
                                dplyr::arrange(desc(ano)) %>%
                                dplyr::mutate(filtro = paste0(ano, cod_municipio))
        
        


    tb_municipios_alvos_anteriores <- DBI::dbReadTable(connect_sgbd(sgbd),
                                                       "tabela_entidades_alvos_paginas") %>%
                                      tibble::as_tibble() %>% 
                                      dplyr::arrange(desc(ano)) %>%
                                      dplyr::mutate(filtro = paste0(ano, cod_municipio))
        


    tb_municipios_alvos_atualizada <- tb_municipios_alvos_novos %>%
        # o sinal ! antes de cod_municipio é um
        # operador lógico para excluir os dados da coluna (Lei de De Morgan)
                                      dplyr::filter(!filtro %in% tb_municipios_alvos_anteriores$filtro) %>%
                                      dplyr::arrange(desc(ano)) %>%
                                      dplyr::mutate_all(~stringi::stri_trans_general(., "latin-ascii"))
    #!!! Aqui, termina o armengue no código, pois não consegui usar a função dplyr::filter com dois critérios como um.
    # No futuro, subistituir o techo aciima pelo debaixo que está comentado.

    
    DBI::dbWriteTable(connect_sgbd(sgbd),
                      "tabela_entidades_alvos_paginas",
                      tb_municipios_alvos_atualizada,
                      append = TRUE)

    DBI::dbDisconnect(connect_sgbd(sgbd))


    print("Tabela 'tabela_entidades_alvos_paginas' gerada com sucesso!")

}

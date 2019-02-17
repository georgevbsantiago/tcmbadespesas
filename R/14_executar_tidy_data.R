#' @title Função que transforma os dados para o padrão "tidy data"
#'
#' @param sgbd Define qual é o Banco de Dados a ser utilizado.
#' Por padrão, é definido o SQLite.
#' 
#' @importFrom magrittr %>%
#'
#' @export

executar_tidy_data <- function(sgbd) {


    tb_despesas_municipios <- DBI::dbReadTable(connect_sgbd(sgbd), "tabela_despesas_municipais") %>%
        tibble::as_tibble() %>%
        tidyr::separate(col = favorecido,
                        into = c("cod_favorecido",
                                 "nm_favorecido"),
                        sep = " - ",
                        remove = TRUE, extra = "merge") %>%
        tidyr::separate(col = fonte_de_recurso_tcm,
                        into = c("cod_fonte_de_recurso_tcm",
                                 "nm_fonte_de_recurso_tcm"),
                        sep = " - ",
                        remove = TRUE, extra = "merge") %>%
        tidyr::separate(col = fonte_de_recurso_gestor,
                        into = c("cod_fonte_de_recurso_gestor",
                                 "nm_fonte_de_recurso_gestor"),
                        sep = " - ",
                        remove = TRUE, extra = "merge") %>%
        tidyr::separate(col = orgao,
                        into = c("cod_orgao",
                                 "nm_orgao"),
                        sep = " - ",
                        remove = TRUE, extra = "merge") %>%
        tidyr::separate(col = unidade_orcamentaria,
                        into = c("cod_unidade_orcamentaria",
                                 "nm_unidade_orcamentaria"),
                        sep = " - ",
                        remove = TRUE, extra = "merge") %>%
        tidyr::separate(col = funcao,
                        into = c("cod_funcao",
                                 "nm_funcao"),
                        sep = " - ",
                        remove = TRUE, extra = "merge") %>%
        tidyr::separate(col = subfuncao,
                        into = c("cod_subfuncao",
                                 "nm_subfuncao"),
                        sep = " - ",
                        remove = TRUE, extra = "merge") %>%
        tidyr::separate(col = programa,
                        into = c("cod_programa",
                                 "nm_programa"),
                        sep = " - ",
                        remove = TRUE, extra = "merge") %>%
        tidyr::separate(col = tipo_acao,
                        into = c("cod_tipo_acao",
                                 "nm_tipo_acao"),
                        sep = " - ",
                        remove = TRUE, extra = "merge") %>%
        tidyr::separate(col = acao,
                        into = c("cod_acao",
                                 "nm_acao"),
                        sep = " - ",
                        remove = TRUE, extra = "merge") %>%
        tidyr::separate(col = natureza_da_despesa_tcm,
                        into = c("cod_natureza_da_despesa_tcm",
                                 "nm_natureza_da_despesa_tcm"),
                        sep = " - ",
                        remove = TRUE, extra = "merge") %>%
        tidyr::separate(col = natureza_da_despesa_gestor,
                        into = c("cod_natureza_da_despesa_gestor",
                                 "nm_natureza_da_despesa_gestor"),
                        sep = " - ",
                        remove = TRUE, extra = "merge") %>%
        tidyr::separate(col = fonte_de_recurso_tcm_2,
                        into = c("cod_fonte_de_recurso_tcm_2",
                                 "nm_fonte_de_recurso_tcm_2"),
                        sep = " - ",
                        remove = TRUE, extra = "merge") %>%
        tidyr::separate(col = fonte_de_recurso_gestor_2,
                        into = c("cod_fonte_de_recurso_gestor_2",
                                 "nm_fonte_de_recurso_gestor_2"),
                        sep = " - ",
                        remove = TRUE, extra = "merge") %>%
        dplyr::mutate(valor_das_retencoes = stringr::str_replace(valor_das_retencoes, "-", "0")) %>%
        dplyr::mutate(cod_favorecido = stringr::str_replace_all(cod_favorecido, "[.-]", "")) %>%
        dplyr::mutate(tipo_de_documento = stringr::str_replace(tipo_de_documento, "[º]", ".")) %>%
        dplyr::mutate_at(c("valor_do_pagamento",
                           "valor_das_retencoes",
                           "valor_do_empenho"),
                         ~valor_monetario(.)) %>%
        dplyr::mutate_at(c("data_do_pagamento",
                           "data_empenho"),
                         ~lubridate::dmy(.)) %>%
        dplyr::mutate_at(dplyr::vars(fase:declaracao),
                         ~stringr::str_to_upper(.)) %>%
        dplyr::mutate_all(~stringr::str_trim(.)) %>%
        dplyr::mutate_all(~stringi::stri_trans_general(., "latin-ascii"))

    #Desconectar do DBI::dbReadTable
    DBI::dbDisconnect(connect_sgbd(sgbd))

    DBI::dbWriteTable(connect_sgbd(sgbd),
                      "tabela_despesas_municipais_tidy_data",
                      tb_despesas_municipios,
                      overwrite = TRUE)

    DBI::dbDisconnect(connect_sgbd(sgbd))

    message("Os dados foram colocados no padrão Tidy Data e salvos no Bando de Dados em 'tabela_despesas_municipais_tidy_data'")


    readr::write_delim(tb_despesas_municipios,
                       file.path("dados_exportados",
                                 "tabela_despesas_municipais_tidy_data.csv"),
                       delim = ";")

    message("Os dados foram colocados no padrão Tidy Data Internacional e salvos em CSV no diretório 'dados_exportados'")


    tb_despesas_municipios_BR <- tb_despesas_municipios %>%
        dplyr::mutate_at(c("valor_das_retencoes",
                           "valor_do_pagamento",
                           "valor_do_empenho"),
                         ~stringr::str_replace(., "[.]", ","))


    readr::write_delim(tb_despesas_municipios_BR,
                       file.path("dados_exportados",
                                 "tabela_despesas_municipais_tidy_data_BR.csv"),
                       delim = ";")


    message("Os dados foram colocados no padrão Tidy Data Brasil (R$) e salvos em CSV no diretório 'dados_exportados'")


}



######################################################################################

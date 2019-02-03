#' @title Função que realiza a extração de dados das despesas do arquivo html
#'
#' @description Função que realiza a extração de dados de despesas que estao no arquivo html
#' 
#' @param sgbd Define qual é o Banco de Dados a ser utilizado.
#' Por padrão, é definido o SQLite.
#' 
#' @importFrom magrittr %>%
#'
#' @export
#' 

executar_data_wrangling_html_despesas <- function(sgbd = "sqlite") {


    tb_requisicoes <- DBI::dbReadTable(connect_sgbd(sgbd), "tabela_requisicoes") %>%
                      dplyr::filter(arq_html_despesa_tratado == "N" & nm_arq_html_despesa != "")

    DBI::dbDisconnect(connect_sgbd(sgbd))


    if (nrow(tb_requisicoes) == 0) {

        message("Todos os Arquivos HTML das despesas já foram tratados")

    } else {

        purrr::pwalk(tb_requisicoes, data_wrangling_html_despesas, sgbd)

        DBI::dbDisconnect(connect_sgbd(sgbd))

        message("Todos os Arquivos HTML das despesas foram tratados com sucesso!")

    }


}


######################################################################################


data_wrangling_html_despesas <- function(id, ano, cod_municipio, nm_municipio,
                                         cod_entidade, nm_entidade, pagina,
                                         status_request_html_pag, log_request_html_pag,
                                         nm_arq_html_pag, documento, valor_documento,
                                         link_despesa, nm_arq_html_despesa,
                                         hash_arq_html_despesa,
                                         log_tratamento_arq_html_despesa, sgbd, ...){

    # Realiza o parser no arquivo HTML
    nm_municipio <- limpar_nome(nm_municipio)
    
    nm_entidade <- limpar_nome(nm_entidade)
    
    subdir_resp_html_desp_entidade <- file.path("resposta_scraping_html",
                                               nm_municipio,
                                               nm_entidade
                                               )
    
    parser_arq_html <- xml2::read_html(file.path(subdir_resp_html_desp_entidade, nm_arq_html_despesa),
                                       encoding = "UTF-8")


    pegar_dados_html <- parser_arq_html %>%
                        rvest::html_nodes("label+ span") %>%
                        rvest::html_text() %>%
                        stringr::str_trim()


    log_parser_arq_html_despesa <- log_data_hora()


    tb_despesas_municipais <- tibble::tibble(
            fase = pegar_dados_html[1],
            data_do_pagamento = pegar_dados_html[2],
            valor_do_pagamento = pegar_dados_html[3],
            documento = pegar_dados_html[4],
            empenho = pegar_dados_html[5],
            data_empenho = pegar_dados_html[6],
            tipo_de_empenho = pegar_dados_html[7],
            favorecido = pegar_dados_html[8],
            valor_do_empenho = pegar_dados_html[9],
            valor_das_retencoes = pegar_dados_html[10],
            restos_a_pagar = pegar_dados_html[11],
            conta_bancaria = pegar_dados_html[12],
            fonte_de_recurso_tcm = pegar_dados_html[13],
            fonte_de_recurso_gestor = pegar_dados_html[14],
            tipo_de_documento = pegar_dados_html[15],
            # Enriqueci a tabela com o dado do código do município
            cod_municipio = cod_municipio,
            municipio = pegar_dados_html[16],
            # Enriqueci a tabela com o dado do código da entidade municipal
            cod_entidade = cod_entidade,
            nm_entidade = pegar_dados_html[17],
            poder = pegar_dados_html[18],
            orgao = pegar_dados_html[19],
            unidade_orcamentaria = pegar_dados_html[20],
            funcao = pegar_dados_html[21],
            subfuncao = pegar_dados_html[22],
            programa = pegar_dados_html[23],
            tipo_acao = pegar_dados_html[24],
            acao = pegar_dados_html[25],
            natureza_da_despesa_tcm = pegar_dados_html[26],
            natureza_da_despesa_gestor = pegar_dados_html[27],
            fonte_de_recurso_tcm_2 = pegar_dados_html[28],
            fonte_de_recurso_gestor_2 = pegar_dados_html[29],
            licitacao = pegar_dados_html[30],
            dispensa_inexigibilidade = pegar_dados_html[31],
            contrato = pegar_dados_html[32],
            declaracao = pegar_dados_html[33],
            foreign_key = id,
            nm_arq_html_despesa = nm_arq_html_despesa,
            hash_arq_html_despesa = hash_arq_html_despesa,
            log_tratamento_arq_html_despesa = log_parser_arq_html_despesa,
            link = link_despesa
            )


    DBI::dbWithTransaction(connect_sgbd(sgbd), {

        DBI::dbWriteTable(connect_sgbd(sgbd),
                          "tabela_despesas_municipais",
                          tb_despesas_municipais,
                          append = TRUE)

        # Grava "S" na tabela 'tabela_requisicoes' para controlar os arquivos HTML já tratados
        DBI::dbExecute(connect_sgbd(sgbd), 'UPDATE tabela_requisicoes
                                            SET arq_html_despesa_tratado = "S",
                                                log_tratamento_arq_html_despesa = :log_parser_arq_html_despesa
                                            WHERE id = :id;',
                       params = list(log_parser_arq_html_despesa = as.character(log_parser_arq_html_despesa),
                                     id = as.character(id)))

    }
    )

    DBI::dbDisconnect(connect_sgbd(sgbd))

    return(print(paste("Tratado:", nm_arq_html_despesa, "-", nm_entidade)))


}

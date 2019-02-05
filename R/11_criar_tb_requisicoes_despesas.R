#' @title Função que gera a Tabela de Requisições "tabela_paginas_links"
#'
#'
#' @param sgbd Define qual é o Banco de Dados a ser utilizado.
#' Por padrão, é definido o SQLite.
#' 
#' @importFrom magrittr %>%
#' 

criar_tb_requisicoes_despesas <- function(sgbd) {


    tab_html_num_pags <- DBI::dbReadTable(connect_sgbd(sgbd), "tabela_paginas_links") %>%
                         dplyr::filter(arq_html_pag_tratado == "N")

    DBI::dbDisconnect(connect_sgbd(sgbd))


    purrr::pwalk(tab_html_num_pags, parser_arq_html_pags, sgbd)


    print("Tabela de requisições criada com sucesso")



}


######################################################################################


parser_arq_html_pags <- function(id, ano, cod_municipio, nm_municipio,
                                 cod_entidade, nm_entidade, pagina,
                                 status_request_html_pag, log_request_html_pag,
                                 nm_arq_html_pag, hash_arq_html_pag, sgbd, ...) {

    nm_municipio <- limpar_nome(nm_municipio)
    
    nm_entidade <- limpar_nome(nm_entidade)
    
    subdir_resp_html_pag_entidade <- file.path("resposta_scraping_links",
                                               nm_municipio,
                                               nm_entidade
                                               )
    
    # Registra o horário do parser para ser usado como registro do log na coluna 'log_tratamento_arq_html_pag'
    log_parser <- log_data_hora()

    # Realiza o parser no arquivo HTML
    parser_arq_html <- xml2::read_html(file.path(subdir_resp_html_pag_entidade,
                                                 nm_arq_html_pag))

    # Extrai a tabela do arquivo HTML
    convert_html_tab <- parser_arq_html %>%
                        rvest::html_node("#tabelaResultado") %>%
                        rvest::html_table()

    # Extrai os registros da coluna Documento da tabela
    doc_arq_html_pag <- convert_html_tab %>%
                        .$Documento %>%
                        stringr::str_replace_all("[/*]", "-") %>%
                        as.character()

    # Extrai os registros da coluna Empenho da tabela
    emp_arq_html_pag <- convert_html_tab %>%
                        .$Empenho %>%
                        as.character()

    # Extrai os registros da coluna Valor da tabela
    valor_arq_html_pag <- convert_html_tab %>%
                          .$Valor %>%
                          valor_monetario()

    # Extrai os links que estavam que estabam incorporados na tag 'a' da coluna Documento
    link_arq_html_pag <- parser_arq_html %>%
                         rvest::html_nodes("a") %>%
                         rvest::html_attrs() %>%
                         unlist()


    # Agrega todos os dados para formar a tabela de requisições
    tb_requisicoes <- tibble::tibble(
                                    ano = ano,
                                    cod_municipio = cod_municipio,
                                    nm_municipio = nm_municipio,
                                    cod_entidade = cod_entidade,
                                    nm_entidade = nm_entidade,
                                    pagina = pagina,
                                    status_request_html_pag = status_request_html_pag,
                                    log_request_html_pag = log_request_html_pag,
                                    nm_arq_html_pag = nm_arq_html_pag,
                                    arq_html_pag_tratado = "S",
                                    hash_arq_html_pag = hash_arq_html_pag,
                                    log_tratamento_arq_html_pag = log_parser,
                                    documento = doc_arq_html_pag,
                                    empenho = emp_arq_html_pag,
                                    valor_documento = valor_arq_html_pag,
                                    link_despesa = link_arq_html_pag,
                                    nm_arq_html_despesa = "",
                                    status_request_html_despesa = "N",
                                    log_request_html_despesa = "",
                                    arq_html_despesa_tratado = "N",
                                    hash_arq_html_despesa = "",
                                    log_tratamento_arq_html_despesa = ""
                                    )

    # Carrega a 'tabela_requisicoes' para servir de teste lógico na etapa seguinte
    tb_requisicoes_anterior <- DBI::dbReadTable(connect_sgbd(sgbd), "tabela_requisicoes") %>%
                               dplyr::filter(cod_entidade == cod_entidade & pagina == pagina)

    DBI::dbDisconnect(connect_sgbd(sgbd))


    tb_requisicoes_atualizada <- tb_requisicoes %>%
        # Exclui as URL iguais que já existiam na tabela, proveniente de HTML com informações parciais
        dplyr::filter(!link_arq_html_pag %in% tb_requisicoes_anterior$link_despesa)


    # Garante que as duas operações a seguir serão executadas no SGBD. Caso contrário, não altera o BD
    DBI::dbWithTransaction(connect_sgbd(sgbd), {

                # Grava a tabela 'tb_requisicoes' no Bando de Dados na tabela 'tabela_requisicoes'
                DBI::dbWriteTable(connect_sgbd(sgbd),
                                  "tabela_requisicoes",
                                  tb_requisicoes_atualizada,
                                  append = TRUE)
        
                # Grava "S" na tabela '' para controlar os arquivos HTML já tratados
                DBI::dbExecute(connect_sgbd(sgbd), 'UPDATE tabela_paginas_links
                                                    SET arq_html_pag_tratado = "S",
                                                        log_tratamento_arq_html_pag = :log_parser
                                                    WHERE cod_entidade = :cod_entidade AND
                                                          pagina = :pagina;',
                               params = list(log_parser = as.character(log_parser),
                                             cod_entidade = as.character(cod_entidade),
                                             pagina = as.character(pagina)))

    }
    )

    DBI::dbDisconnect(connect_sgbd(sgbd))


    print(paste("Parser:", nm_arq_html_pag, "-", nm_entidade))



}

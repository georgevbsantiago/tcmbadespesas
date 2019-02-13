#' @title Função que executa o Web Scraping das Páginas de despesas do TCM-ba
#'
#' @param sgbd Define qual é o Banco de Dados a ser utilizado.
#' Por padrão, é definido o SQLite.
#' 
#' @importFrom magrittr %>%
#' 
#' @export

executar_scraping_html_despesas <- function(sgbd = "sqlite") {


    tb_requisicoes <- DBI::dbReadTable(connect_sgbd(sgbd), "tabela_requisicoes") %>%
                      dplyr::filter(status_request_html_despesa == "N")

    DBI::dbDisconnect(connect_sgbd(sgbd))


    message("Iniciando Web Scraping dos arquivos HTML das Despesas")


    purrr::pwalk(tb_requisicoes, scraping_html_despesas, sgbd)


    message("O Web Scraping dos arquivos HTML das Despesas foi concluído")

# ------------------------------------------------------------------------------------
    
    # Rotina para executar uma segunda tentativa do Scraping
    # para requisitar as URL com timeout ou 404, ou os HTML com inconsistência
    tb_requisicoes_2 <- DBI::dbReadTable(connect_sgbd(sgbd), "tabela_requisicoes") %>%
                        dplyr::filter(status_request_html_despesa == "N")

    DBI::dbDisconnect(connect_sgbd(sgbd))


    if (nrow(tb_requisicoes_2) > 0){

                message("Segunda tentativa para requisitar as URL com 'timeout' ou 404, ou os HTML com inconsistência")
        
                purrr::pwalk(tb_requisicoes_2, scraping_html_despesas, sgbd)
        
                message("A Segunda tentativa do Web Scraping dos arquivos HTML das Despesas foi concluída")
        
                DBI::dbDisconnect(connect_sgbd(sgbd))

    }


}


######################################################################################


scraping_html_despesas <- function(id, ano, cod_municipio, nm_municipio,
                                   cod_entidade, nm_entidade, pagina,
                                   status_request_html_pag, log_request_html_pag,
                                   nm_arq_html_pag, documento, valor_documento,
                                   link_despesa, sgbd, ...) {

    nm_municipio <- limpar_nome(nm_municipio)
    
    nm_entidade <- limpar_nome(nm_entidade)
    
    subdir_resp_html_desp_mun <- file.path("resposta_scraping_html",
                                          nm_municipio
                                          )
    
    subdir_resp_html_desp_entidade <- file.path("resposta_scraping_html",
                                               nm_municipio,
                                               nm_entidade
                                               )
    
    if (dir.exists(subdir_resp_html_desp_mun) == FALSE) {
        
            dir.create(subdir_resp_html_desp_mun)
    }
    
    if (dir.exists(subdir_resp_html_desp_entidade) == FALSE) {
        
            dir.create(subdir_resp_html_desp_entidade)
    }
    
    

    scraping_html_purrr <- purrr::safely(httr::GET)

    scraping_html <- scraping_html_purrr(link_despesa, httr::timeout(35))

    log_request <- log_data_hora()
    

# Teste de timeout ---------------------------------------------------------------------------------

    # Verifica houve timeout. Se sim, esperar 20 segundos e tentar novamente.
    if (is.null(scraping_html$result) == TRUE) {

            message("#### Erro: 'Timeout' da Primeira tentativa para: ",
                    nm_arq_html_pag, " - doc: ", documento, " ####")
    
            gravar_erro(log_request = log_request,
                        nm_log_erro = "timeout - primeira tentativa",
                        entrada = scraping_html,
                        id = id,
                        cod_entidade = cod_entidade,
                        nm_entidade = nm_entidade,
                        ano = ano, 
                        mes = "-",
                        outros = link_despesa,
                        sgbd = sgbd
                        )
            
            message("#### Iniciando Segunda tentativa para: ",
                    nm_arq_html_pag, " - doc: ", documento, " ...")
    
            # Pausa antes da segunad tentativa
            Sys.sleep(10)
    
    
            # Segunda tentativa. Se houver timeout novamente, pular para a próxima requisição.
            scraping_html <- scraping_html_purrr(link_despesa, httr::timeout(35))
    
            log_request <- log_data_hora()
    
    
                        if (is.null(scraping_html$result) == TRUE) {
                
                            gravar_erro(log_request = log_request,
                                        nm_log_erro = "timeout - segunda tentativa",
                                        entrada = scraping_html,
                                        id = id,
                                        cod_entidade = cod_entidade,
                                        nm_entidade = nm_entidade,
                                        ano = ano, 
                                        mes = "-",
                                        outros = link_despesa,
                                        sgbd = sgbd
                                        )
                
                
                            # Parar a iteração e pular para a próxima requisição
                            return(message("#### Erro: 'Timeout' da Segunda tentativa para: ", nm_arq_html_pag,
                                           " - doc: ", documento, " - Pulando para o próximo link de despesa ####"))
                
                
                        }

    }

# Teste de erro 404 ---------------------------------------------------------------------------------

    # Verifica se há erro de querisição 404. Se sim, grava o erro numa tabela de log no BD.
    if (scraping_html$result$status_code == 404) {

            gravar_erro(log_request = log_request,
                        nm_log_erro = "erro - 404",
                        entrada = scraping_html,
                        id = id,
                        cod_entidade = cod_entidade,
                        nm_entidade = nm_entidade,
                        ano = ano, 
                        mes = "-",
                        outros = link_despesa,
                        sgbd = sgbd
                        )
    
    
            # Parar a iteração e pular para a próxima requisição.
            return(message("#### Erro 404 de Requisição para: ",
                           nm_arq_html_pag, " - doc: ", documento,
                           " - Pulando para o próximo link de desepesa ####"))


    }

# Teste de erro 500 ---------------------------------------------------------------------------------
    
    # Verifica se há erro de querisição 500. Se sim, grava o erro numa tabela de log no BD.
    if (scraping_html$result$status_code == 500) {
        
        gravar_erro(log_request = log_request,
                    nm_log_erro = "erro - 500",
                    entrada = scraping_html,
                    id = id,
                    cod_entidade = cod_entidade,
                    nm_entidade = nm_entidade,
                    ano = ano, 
                    mes = "-",
                    outros = link_despesa,
                    sgbd = sgbd
                    )
        
        
        message("#### Erro 500 de Requisição para: ",
                nm_arq_html_pag, " - doc: ", documento,
                " - Pausa de 70 segundos")
        
        Sys.sleep(70)
        
        # Parar a iteração e pular para a próxima requisição.
        return(message("#### Pulando para o próximo link de desepesa ####"))
        
        
    }
    
# Parser no HTML----------------------------------------------------------------------------------------------------- 

    # Realiza um teste no parser do HTML para certificar que o resultado não é NULO.
    parser_html_safely <- purrr::safely(xml2::read_html)
    
    
    # scraping_html$result é proveniente da função 'scraping_html_purrr'
    parser_html_despesas <- scraping_html$result %>%
                            parser_html_safely()
        
    
# Verificação 1 ----------------------------------------------------------------------------------------------------- 
    
    if (is.null(parser_html_despesas$result) == TRUE) { 
        
        gravar_erro(log_request = log_request,
                    nm_log_erro = "Parser do HTML retornou NULO",
                    entrada = scraping_html,
                    id = id,
                    cod_entidade = cod_entidade,
                    nm_entidade = nm_entidade,
                    ano = ano,
                    mes = "-",
                    outros = link_despesa,
                    sgbd = sgbd
                    )
        
        
        return(message("### O parser no HTML ", nm_arq_html_pag, " - doc: ",
                       documento, "retornou NULO. Tentar mais tarde. ###"))
        
    }

# Verificação 2 -----------------------------------------------------------------------------------------------------
    
    # Realiza um teste no HTML para saber se os dados estão completos, ou se houve erro durante a resposta do TCM
    teste_html_despesas <- parser_html_despesas$result %>%     
                           rvest::html_nodes("label+ span") %>%
                           rvest::html_text() %>%
                           stringr::str_trim()

    # Primeiro critério que será usado no teste de integridade do arquivo HTML
    # Critério identificado após vários Web Scrapings
    teste <- "-"

    # Retirei o critério 'teste_html_despesas[13] == teste_1', pois o arquivo está com
    # a informação '-' na base de dados do TCM
    if (teste_html_despesas[8] == teste | teste_html_despesas[8] == "" | is.na(teste_html_despesas[8])) {


            nm_arquivo_html_log <- paste0("log_", ano, "-", cod_entidade,
                                          "-pag_", pagina, "-doc_", documento,
                                          "-val_", valor_documento, "_.html")
            
            gravar_erro(
                        log_request = log_request,
                        nm_log_erro = "HTML de despesa incompleto",
                        entrada = scraping_html,
                        id = id,
                        cod_entidade = cod_entidade,
                        nm_entidade = nm_entidade,
                        ano = ano,
                        mes = "-",
                        outros = link_despesa,
                        sgbd = sgbd
                        )
            
            
            pegar_arquivo_html_log_rds <- parser_html_despesas$result %>%
                                          rvest::html_node("div.col-xs-12.content.padding_content") %>%
                                          saveRDS(file.path("log_html", nm_arquivo_html_log_rds))
               

            pegar_arquivo_html_log <- parser_html_despesas$result %>%
                                      rvest::html_node("div.col-xs-12.content.padding_content") %>%
                                      xml2::write_html(file.path("log_html", nm_arquivo_html_log))
    
    
            return(message("### O HTML ", nm_arq_html_pag, " - doc: ",
                           documento, " não está com informações completas. Tentar mais tarde. ###"))
            

# Salvar HTML-----------------------------------------------------------------------------------------------------

        # Se tudo estiver OK com a requisição e com o arquivo HTML, então executa esse bloco de código.
    } else {

            # Salva o arquivo HTML no HD para ser tratado por outra função
            nome_arquivo_html <- paste0(ano, "-", cod_entidade,
                                        "-pag_", pagina, "-doc_", documento,
                                        "-val_", valor_documento, "_.html") %>%
                                 stringr::str_replace_all("[/*]", "-")
    
                if (file.exists(file.path(subdir_resp_html_desp_entidade, nome_arquivo_html)) == TRUE) {
        
                            sufixo <- format(Sys.time(), "%H_%M_%S")
                
                            nome_arquivo_html <- paste0(gsub("_.html", "", nome_arquivo_html),
                                                        "-d_", sufixo, "_.html")
        
                }
    
    
            # scraping_html$result é proveniente da função 'scraping_html_purrr'
            pegar_html_despesas <- parser_html_despesas$result %>%
                                   rvest::html_node("div.col-xs-12.content.padding_content") %>%
                                   xml2::write_html(file.path(subdir_resp_html_desp_entidade,
                                                              nome_arquivo_html))
    
    
            # Gera o Hash do Arquivo HTML que foi gravado
            hash_arq_html_despesa <- digest::sha1(file.path(subdir_resp_html_desp_entidade,
                                                            nome_arquivo_html))
    
    
    
            # Grava "S" na tabela 'tabela_paginas_links' para controlar os arquivos HTML já tratados
            DBI::dbExecute(connect_sgbd(sgbd), 'UPDATE tabela_requisicoes
                                                SET status_request_html_despesa = "S",
                                                    nm_arq_html_despesa = :nome_arquivo_html,
                                                    log_request_html_despesa = :log_request,
                                                    hash_arq_html_despesa = :hash_arq_html_despesa
                                                WHERE id = :id;',
                           params = list(nome_arquivo_html = as.character(nome_arquivo_html),
                                         log_request = as.character(log_request),
                                         hash_arq_html_despesa = as.character(hash_arq_html_despesa),
                                         id = as.character(id)))
    
            DBI::dbDisconnect(connect_sgbd(sgbd))
    
            print(paste("Scraping -", "Ano:", ano, "- Pág:", pagina, "- Doc:", documento,
                        "- Valor:", valor_documento, "-", nm_entidade))

    }


}


######################################################################################

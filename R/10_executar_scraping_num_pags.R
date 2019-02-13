#' @title Função que executa o Web Scraping das Páginas do TCM-ba
#'
#'
#' @param sgbd Define qual é o Banco de Dados a ser utilizado.
#' Por padrão, é definido o SQLite.
#' 
#' 
#' @importFrom magrittr %>%
#' 

executar_scraping_num_pags <- function(sgbd) {


    entidades_alvos <- DBI::dbReadTable(connect_sgbd(sgbd), "tabela_entidades_alvos_paginas")

    DBI::dbDisconnect(connect_sgbd(sgbd))
    
    print("Iniciando Web Scraping das páginas_links das entidades alvos!")
    

    purrr::pwalk(entidades_alvos, scraping_num_pags, sgbd)


    print("Web Scraping das páginas_links das entidades alvos finalizado!")



}


######################################################################################

scraping_num_pags <- function(id, ano, cod_municipio, nm_municipio,
                              cod_entidade, nm_entidade, pagina, sgbd, ...) {


    nm_municipio <- limpar_nome(nm_municipio)
    
    nm_entidade <- limpar_nome(nm_entidade)
    
    subdir_resp_html_pag_mun <- file.path("resposta_scraping_links",
                                          nm_municipio
                                          )
    
    subdir_resp_html_pag_entidade <- file.path("resposta_scraping_links",
                                               nm_municipio,
                                               nm_entidade
                                               )
    
    if (dir.exists(subdir_resp_html_pag_mun) == FALSE) {
        dir.create(subdir_resp_html_pag_mun)
    }
    
    if (dir.exists(subdir_resp_html_pag_entidade) == FALSE) {
        dir.create(subdir_resp_html_pag_entidade)
    }
    
    # Tabela que será utilizada durante o loop para identificar as páginas que já foram raspadas.
    tb_pag_links <- DBI::dbReadTable(connect_sgbd(sgbd), "tabela_paginas_links")
    
    DBI::dbDisconnect(connect_sgbd(sgbd))


    repeat {


        site_tcm <- paste0("http://www.tcm.ba.gov.br/consulta-de-despesas/?pg=", pagina,
                           "&txtEntidade=&ano=", ano,
                           "&favorecido=&entidade=", cod_entidade,
                           "&orgao=&orcamentaria=&despesa=&recurso=&desp=P&dtPeriodo1=&dtPeriodo2=")


        scraping_html_purrr <- purrr::safely(httr::GET)

        scraping_tcm_paginas <- scraping_html_purrr(site_tcm, httr::timeout(20))

        # Grava a hora e data da requisição para ser incluída no arquivo HMTL e no BD
        log_request <- log_data_hora()

# Teste de timeout ---------------------------------------------------------------------------------
        
        # Verifica houve timeout. Se sim, esperar 10 segundos e tentar novamente.
        if (is.null(scraping_tcm_paginas$result) == TRUE) {

            message("#### Erro: 'Timeout' da Primeira tentativa para a Página: ", pagina,
                    " da entidade: ", nm_entidade, " ####")

            gravar_erro(log_request = log_request,
                        nm_log_erro ="timeout - primeira tentativa",
                        entrada = scraping_tcm_paginas,
                        id = id,
                        cod_entidade = cod_entidade,
                        nm_entidade = nm_entidade,
                        ano = ano, 
                        mes = "-",
                        outros = paste("Página:", pagina),
                        sgbd = sgbd
                        )


            message("#### Iniciando Segunda tentativa para a Página: ",
                    pagina, " da entidade: ", nm_entidade, " ...")

            # Pausa antes da segunad tentativa
            Sys.sleep(5)


                # Segunda tentativa. Se houver timeout novamente, pular para a próxima requisição.
                scraping_tcm_paginas <- scraping_html_purrr(site_tcm, httr::timeout(35))


                        if (is.null(scraping_tcm_paginas$result) == TRUE) {
            
                            gravar_erro(log_request = log_request,
                                        nm_log_erro ="timeout - segunda tentativa",
                                        entrada = scraping_tcm_paginas,
                                        id = id,
                                        cod_entidade = cod_entidade,
                                        nm_entidade = nm_entidade,
                                        ano = ano, 
                                        mes = "-",
                                        outros = paste("Página:", pagina),
                                        sgbd = sgbd
                            )
            
                            # Parar a iteração e pular para a próxima requisição
                            message("#### Erro: 'Timeout' Segunda tentativa para a Página: ", pagina,
                                    "da entidade: ", nm_entidade,
                                    "#### /n ###### Pulando para a próxima entidade ######")
            
                            break()
            
            
                        }

        }

# Parser no HTML-----------------------------------------------------------------------------------------------------
        
        parser_html_tabela <- scraping_tcm_paginas$result %>%
                              xml2::read_html() %>%
                              rvest::html_node("#tabelaResultado")
        
# Verificação 1 -----------------------------------------------------------------------------------------------------    
        
        # Variável que será utilizada para verificar se há ou não tabela na página html
        verificador_tabela <- parser_html_tabela %>% 
                              length()

        # Verifica se há tabela na página html
        if (verificador_tabela == 0 ) {

                    message("Não foi identificado tabela na Página: ", pagina, " da entidade: ", nm_entidade)
        
                    break()

        }

# Verificação 2 -----------------------------------------------------------------------------------------------------
        
        # Verifica se há tabela, pelo seu tamanho, no HTML.
        # Servirá como gatilho de parar o repeat quando chegar na última página
        gatinho_to_break <- parser_html_tabela %>%
                            rvest::html_table() %>%
                            .$Documento %>%
                            length()

        # Se o gatilho de verificação for igual a 0, então ele pula para a próxima entidade municipal
        if (gatinho_to_break == 0 ) {

                    message("Fim das requisições de ", nm_entidade, " na Página: ", pagina)
        
                    break()

        }

# Verificação 3 -----------------------------------------------------------------------------------------------------
        
        # Verifica se a requisição já consta no BD
        
        nm_arq_html_pag <- paste0(ano, "-", cod_entidade,
                                  "-pag_", pagina, "_", ".html")



        if (nm_arq_html_pag %in% tb_pag_links$nm_arq_html_pag & gatinho_to_break < 20) {


                    message("Fim das requisições de ", nm_entidade, " na Página: ", pagina, " - P")
        
                    break()

        }

        
# Salvar HTML-----------------------------------------------------------------------------------------------------
        
        if (nm_arq_html_pag %in% tb_pag_links$nm_arq_html_pag & gatinho_to_break == 20) {

                    print(paste0("Scraping - ", nm_entidade, " - ", ano," - Página: ", pagina, "- Continuação"))
        
                    pegar_paginas <- parser_html_tabela %>%
                                     xml2::write_html(file.path(subdir_resp_html_pag_entidade,
                                                                nm_arq_html_pag))
        
                    # Gera o Hash do Arquivo HTML que foi gravado
                    hash_arq_html <- digest::sha1(file.path(subdir_resp_html_pag_entidade,
                                                            nm_arq_html_pag))
                    
                    pagina <- pagina + 1
        
        
                    DBI::dbWithTransaction(connect_sgbd(sgbd), {
        
                            DBI::dbExecute(connect_sgbd(sgbd), 'UPDATE tabela_entidades_alvos_paginas
                                                                SET pagina = :pagina
                                                                WHERE id = :id',
                                                       params = list(pagina = as.character(pagina),
                                                                     id = as.character(id)))
            
                            DBI::dbExecute(connect_sgbd(sgbd), 'UPDATE tabela_paginas_links
                                                                SET arq_html_pag_tratado = "N",
                                                                    hash_arq_html_pag = :hash_arq_html
                                                                WHERE nm_arq_html_pag = :nm_arq_html_pag',
                                                       params = list(hash_arq_html = as.character(hash_arq_html),
                                                                     nm_arq_html_pag = as.character(nm_arq_html_pag)))
            
                    }
                    )
        
                    DBI::dbDisconnect(connect_sgbd(sgbd))
                    
        
                    break()
    
    
        } else {
    
    
                    pegar_paginas <- parser_html_tabela %>%
                                     xml2::write_html(file.path(subdir_resp_html_pag_entidade,
                                                                nm_arq_html_pag))
        
                    # Gera o Hash do Arquivo HTML que foi gravado
                    hash_arq_html <- digest::sha1(file.path(subdir_resp_html_pag_entidade,
                                                            nm_arq_html_pag))
        
                    tb_paginas_links <- tibble::tibble(ano = ano,
                                                       cod_municipio = cod_municipio,
                                                       nm_municipio = nm_municipio,
                                                       cod_entidade = cod_entidade,
                                                       nm_entidade = nm_entidade,
                                                       pagina = pagina,
                                                       status_request_html_pag = "S",
                                                       log_request_html_pag = log_request,
                                                       nm_arq_html_pag = nm_arq_html_pag,
                                                       arq_html_pag_tratado = "N",
                                                       hash_arq_html_pag = hash_arq_html,
                                                       log_tratamento_arq_html_pag = ""
                                                       )
        
        
                    DBI::dbWriteTable(connect_sgbd(sgbd),
                                      "tabela_paginas_links",
                                      tb_paginas_links,
                                      append = TRUE
                                      )
        
                    DBI::dbDisconnect(connect_sgbd(sgbd))
    
    
    }

        print(paste0("Scraping - ", nm_entidade, " - ", ano, " - Página: ", pagina))


        if (gatinho_to_break < 20) {

                pagina <- pagina

        }

        if (gatinho_to_break == 20) {

                pagina <- pagina + 1

        }


        DBI::dbExecute(connect_sgbd(sgbd), 'UPDATE tabela_entidades_alvos_paginas
                                            SET pagina = :pagina
                                            WHERE id = :id',
                                   params = list(pagina = as.character(pagina),
                                                 id = as.character(id)))

        DBI::dbDisconnect(connect_sgbd(sgbd))


    }


}


######################################################################################

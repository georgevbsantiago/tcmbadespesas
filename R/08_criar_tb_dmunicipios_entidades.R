#' @title Função que gera a tabela "tabela_tcm_dmunicipios_entidades" no Banco de Dados
#'
#' @param sgbd Define o Sistema de Banco de Dados a ser utilizado.
#' Por padrão, é definido como sqlite
#'
#' @importFrom magrittr %>%
#'


criar_tb_dmunicipios_entidades <- function(sgbd = "sqlite") {
    
    
    cod_nm_mun <- DBI::dbReadTable(connect_sgbd(sgbd),
                                   "tabela_tcm_dmunicipios")
    
    
    #Gera a tabela com dados dos municípios e entidades, a partir do scraping do WS do TCM-Ba
    scraping_mun_ent <- purrr::pmap_dfr(cod_nm_mun, scraping_tcm_entidades_ws)
    
    
    DBI::dbWriteTable(connect_sgbd(sgbd),
                      "tabela_tcm_dmunicipios_entidades",
                      scraping_mun_ent,
                      overwrite = TRUE)
    
    DBI::dbDisconnect(connect_sgbd(sgbd))
    
    
    print("A tabela `tabela_tcm_dmunicipios_entidades` foi criado com sucesso no BD")
    
    
}

######################################################################################



scraping_tcm_entidades_ws <- function(cod_municipio, nm_municipio, log_create) {
    
    # URL do Web Service do TCM-Ba;
    url_tcm_entidades_ws <- url_tcm_entidades_ws()
    
    # Scraping do código e nome dos entes municipais via Web Service;
    resultado <- paste0(url_tcm_entidades_ws, cod_municipio) %>%
        httr::GET() %>%
        httr::content() %>%
        purrr::map_dfr(~tibble::as_tibble(.))
    
    
    # Tratamento dos dados obtidos via Web Service;
    resultado_tratado <- resultado %>%
        magrittr::set_names(c("cod_entidade",
                              "nm_entidade")) %>%
        dplyr::mutate(cod_municipio = cod_municipio,
                      nm_municipio = nm_municipio,
                      log_create = log_data_hora()) %>%
        dplyr::mutate_all(~stringr::str_to_upper(.)) %>%
        dplyr::mutate_all(~stringr::str_trim(.)) %>%
        dplyr::select(cod_municipio,
                      nm_municipio,
                      cod_entidade,
                      nm_entidade,
                      log_create)
    
    
    # Print para visualizar a progressão do scraping
    print(paste("Scraping:", resultado_tratado$cod_municipio, "-", resultado_tratado$nm_municipio,
                "|", resultado_tratado$cod_entidade, "-", resultado_tratado$nm_entidade))
    
    
    # Função return() para que o output seja o dataframe que está na variável 'resultado_tratado';
    return(resultado_tratado)
    
}

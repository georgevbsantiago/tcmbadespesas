#' @title Função do URL do TCM-Ba
#'
#'

url_tcm <- function () {
    
    url_tcm <-  "http://www.tcm.ba.gov.br/consulta-de-despesas/"
    
}

###################################################################

#' @title Função do Web Service do TCM-Ba
#'
#'

url_tcm_entidades_ws <- function(){
    
    url_tcm_entidades_ws <- "http://www.tcm.ba.gov.br/Webservice/index.php/entidades?cdMunicipio="
    
}

###################################################################


#' @title Função para registrar o fuso horário
#' 
#' @description Função usada para registrar o fuso horário do Brasil
#' mesmo que o servidor tenha o fuso horário de outro país
#' 

log_data_hora <- function () {

    format(lubridate::now(), tz ="Brazil/East", usetz = TRUE)

}

###################################################################

#' @title Função para padronizar valores monetários
#' 
#' @description Limpa os valores monetários de caracteres especiais.
#' Ex: 'R$ 1.059,00' para '1059.00'
#'
#' @param x string
#' 

valor_monetario <- function (x) {
    
    x <- as.character(x)
    
    readr::parse_number(x, locale = readr::locale(grouping_mark = ".",
                                                  decimal_mark = ","))
    
}

###################################################################


#' @title Função para limpar nomes de caracteres especiais
#' 
#' @description Limpa o nome dos entes municipais para retirar caracteres especiais
#'
#' @param x string
#'


limpar_nome <- function (x) {
    
    resultado <- stringr::str_replace_all(x, "[/]", "") %>%
        stringr::str_replace_all("[*]", "") %>%
        stringr::str_replace_all("[ª]", "") %>%
        stringr::str_replace_all("[º]", "") %>%
        stringr::str_trim() %>%
        stringr::str_to_upper () %>%
        stringi::stri_trans_general(., "latin-ascii")
    
    return(resultado)
    
}


###################################################################################

#' @title Função para gravar erro da execução do código
#' 
#' @param log_request Valor gerado pela função log_data_hora()
#' @param nm_log_erro Nome do erro atribuído pelo desenvolvedor;
#' @param entrada Resultado após execução da função envolvida pela função purrr::safely
#' @param id Número do ID no Banco de Dados;
#' @param cod_entidade Código da Entidade Municipal do Web Scraping;
#' @param nm_entidade Nome da Entidade Municipal do Web Scraping;
#' @param ano Ano de referência da Entidade Municipal;
#' @param mes Mês de referência da Entidade Municipal;
#' @param outros Outras informações adicionadas pelo Desenvolvedor;
#' @param sgbd Nome do Banco de Dados usado na execução do Código
#' 
#' @export

gravar_erro <- function(log_request, nm_log_erro = "", entrada = "",
                        id = "", cod_entidade = "", nm_entidade = "",
                        ano = "", mes = "", outros = "", sgbd = "sqlite") {
    
    
    if(is.null(entrada$result) == TRUE) {
        
        entrada_resultado <- "NULO"
        
        entrada_error <- entrada$error$message
        
    }
    
    if(is.null(entrada$error) == TRUE) {
        
        entrada_resultado <- entrada$result$status_code
        
        entrada_error <- "NULO"
    }
    
    
    tb_error <- tibble::tibble(
                                data_time = log_request,
                                nm_log_erro = nm_log_erro,
                                entrada_result = entrada_resultado,
                                entrada_error = entrada_error,
                                foreign_key = id,
                                cod_entidade = cod_entidade,
                                nm_entidade = nm_entidade,
                                ano = ano,
                                mes = mes,
                                outros = outros,
                                sgbd = sgbd
                                )
    
    write_sqlite <- purrr::safely(DBI::dbWriteTable)
    
    
    result_sql <- write_sqlite(connect_sgbd(sgbd),
                               "tabela_log",
                               tb_error,
                               append = TRUE)
    
    DBI::dbDisconnect(connect_sgbd(sgbd))
    
    
    while(is.null(result_sql$result) == TRUE) {
        
        result_sql <- write_sqlite(connect_sgbd(sgbd),
                                   "tabela_log",
                                   tb_error,
                                   append = TRUE)
        
        DBI::dbDisconnect(connect_sgbd(sgbd))
        
    }
    
}

###################################################################################


inicio_exe_ws_data_time <- function(arq_rds_id_ws) {
    
    
    ws_id <- readRDS(arq_rds_id_ws)
    
    ws_id$inicio_ws_data_time <- log_data_hora()
    ws_id$fim_ws_data_time <- "- - -"
    
    saveRDS(object = ws_id,
            file = arq_rds_id_ws)
    
}


###################################################################################

fim_exe_ws_data_time <- function(arq_rds_id_ws) {
    
    ws_id <- readRDS(arq_rds_id_ws)
    
    ws_id$fim_ws_data_time <- log_data_hora()
    
    saveRDS(object = ws_id,
            file = arq_rds_id_ws)
    
}

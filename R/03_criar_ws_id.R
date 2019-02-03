#' @title Função que cria o ID do Web Scraping
#'
#' @param nome_scraping Nome do Web Scraping
#' @param arq_rds_id_ws Nome do Arquivo RDS com os metadados do Web Scraping
#' @param sgbd Nome do SGBD usado pelo Banco de Dados
#'


criar_ws_id <- function(nome_scraping, arq_rds_id_ws, sgbd) {
    

        ws_id <- list(nome = nome_scraping,
                      file_id = arq_rds_id_ws,
                      dir_wd = getwd(),
                      dir_ws = dir(),
                      sgbd_ws = sgbd,
                      data_time_create = log_data_hora(),
                      inicio_ws_data_time = "-",
                      fim_ws_data_time = "-"
                      )

        saveRDS(object = ws_id,
                file = arq_rds_id_ws)
        

        print("A identidade do Web Scraping foi definida com Sucesso!")
    
}


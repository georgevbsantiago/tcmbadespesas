#' @title Função que cria o Banco de Dados
#' 
#' @param sgbd Define o Sistema de Banco de Dados a ser utilizado. Por padrão, é definido como sqlite
#'


criar_bd <- function(sgbd = "sqlite") {
    
    
    if(sgbd == "sqlite") {
        
        if(file.exists(file.path("bd_sqlite",
                                 "bd_tcm_despesas_municipios.db")) == FALSE) {
            
            
            conexao_segura_sqlite <- purrr::safely(DBI::dbConnect)
            
            sqlite_bd <- conexao_segura_sqlite(RSQLite::SQLite(),
                                               dbname = file.path("bd_sqlite",
                                                                  "bd_tcm_despesas_municipios.db"))
            
            DBI::dbDisconnect(connect_sgbd(sgbd))
            
            
        }
        
        if(is.null(sqlite_bd$result)) {
            
            stop("### Ocorreu um erro durante a criação do Bando de Dados no SQLite!",
                 "### Verifique se o diretório foi criado corretamente ou se você tem permissão para criar o SQLite no diretório!")
        }
        
        
        print("Banco de Dados do SQLite criado com Sucesso!")
        
    }
    
    
    #if(sgbd == "mysql") {}
    
    
}


##################################################################################

#' @title Função que cria a conexão com o Banco de Dados
#' 
#' @param sgbd Define o Sistema de Banco de Dados a ser utilizado. Por padrão, é definido como sqlite
#'


connect_sgbd <- function(sgbd = "sqlite") {
    
    
    if(sgbd == "sqlite") {
        
        
        conexao_segura_sqlite <- purrr::safely(DBI::dbConnect)
        
        sqlite_bd <- conexao_segura_sqlite(RSQLite::SQLite(),
                                           dbname = file.path("bd_sqlite",
                                                              "bd_tcm_despesas_municipios.db"))
        
        while(is.null(sqlite_bd$result) == TRUE) {
            
            print("Banco de Dados bloqueado - Tentando conectar novamente...")
            
            log_data_time <- log_data_hora()
            
            # Grava uma log em CSV, caso haja problemas em conectar com o SGBD
            tibble::tibble(data_time = log_data_time,
                           nm_log_erro = "Erro ao acesso o SQLite",
                           sgbd = "sqlite") %>%
            readr::write_delim(file.path("bd_sqlite",
                                         "log_sgbd.csv"),
                               delim = ";",
                               append = TRUE)
            
            # Tentar novamente a conexão com o BD
            sqlite_bd <- conexao_segura_sqlite(RSQLite::SQLite(),
                                               dbname = file.path("bd_sqlite",
                                                                  "bd_tcm_despesas_municipios.db"))
        }
        
        
        return(sqlite_bd$result)
        
    }
    
    
    #if(bd == "mysqlite") {}
    
    
    
}

###################################################################

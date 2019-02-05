#' @title Função que realiza o backup dos arquivos
#'
#' @description Função que executa o backup do Banco de Dados, dos arquivos HTML,
#' e dos arquivos CSVs no ambiente local e na nuvem (DropBox).
#' Obs: É preciso configurar o token do DropBox para a função funcionar.
#' Saiba como gerar o seu Token em: [linked phrase](https://github.com/karthik/rdrop2)
#'
#' @param backup_local É definido como "SIM" como padrão para realizar
#' o Backup do Banco de Dados e dos arquivos HTML e CSV.
#' Mas pode ser marcado como "NAO".
#' @param backup_nuvem É definido como "NAO" como padrão.
#' Mas pode ser marcado como "SIM", caso deseje realizar
#' o backup no DroBox.
#' 
#' @importFrom magrittr %>%
#' 


executar_backup_arquivos <- function(backup_local = "SIM",
                                     backup_nuvem = "NAO") {
    
    
    if(!backup_local %in% c("SIM", "NAO")) {
        
            stop("Digite SIM ou NAO para o argumento 'backup_local' da função")
        
    }
    
    if(!backup_nuvem %in% c("SIM", "NAO")) {
        
            stop("Digite SIM ou NAO para o argumento 'backup_nuvem' da função")
    }
    
    
    
    if(backup_local == "NAO") {
        
            message("Não realizado o Backup local, conforme determinado pelo usuário")
        
        
    } else {
    
            # Define o padrão do nome a ser utilizado para identificar o BK dos arquivos;
            sufixo <- log_data_hora() %>%
                       stringr::str_replace_all("[:]", "-") %>%
                       stringr::str_replace_all("[ ]", "_")
            
            
            nome_dir_bk <- file.path("backup", paste0("backup_", sufixo))
            
            dir.create(nome_dir_bk)
            
            
            bd_sqlite <- file.path("bd_sqlite", "bd_tcm_despesas_municipios.db")
            
            #lista_arquivos_html <- dir("resposta_scraping_links")
                
            id_ws <- dir(pattern = "id_ws")
            
            
            
            zip_bd_sqlite <- file.path(nome_dir_bk, paste0("bk_bd_", sufixo, ".zip"))
            
            #zip_arquivos_html <- file.path(nome_dir_bk, paste0("bk_html_", sufixo, ".zip"))
            
            zip_arquivo_id_ws <- file.path(nome_dir_bk, paste0("bk_id_ws", sufixo, ".zip"))
            
            
            zip::zip(zip_bd_sqlite, bd_sqlite,
                     recurse = FALSE, compression_level = 9)
            
            print("Arquivo de Backup do BD gerado com sucesso!")
            
            
            # zip::zip(zip_arquivos_html, lista_arquivos_html,
            #          recurse = FALSE, compression_level = 9)
            # 
            # print("Arquivo de Backup dos HTMLs gerado com sucesso!")
            
            
            zip::zip(zip_arquivo_id_ws, id_ws,
                     recurse = FALSE, compression_level = 9)
            
            print("Arquivo de Backup dos ID_WS gerado com sucesso!")
            
            
            print("Backup concluído com Sucesso!")
            
            #--------------------------------------------------------------------
            
            ####### O DropBox pode ser acessado com um token ou criando uma chave API
            
            # Saiba como gerar o seu Token em: https://github.com/karthik/rdrop2
    
    }

    
    if(backup_nuvem == "NAO") {
        
            message("Não realizado o Backup na nuvem, conforme determinado pelo usuário")
        
        
    } else {
    
    
            if(file.exists("token_dropbox.rds") == FALSE) {
                
                stop("Realize o processo de autenticação do DropBox ",
                     "e salve o TOKEN no arquivo 'token_dropbox.rds' na pasta raiz do Web Scraping.",
                     "Veja as instruções no arquivo '11_backup_dropbox.R deste pacote")
                
            }
            
            
            token_dropbox <- readRDS("token_dropbox.rds")
            
            print("Iniciando processo de Autenticação do Token no DropBox!")
            
            dir_bk_dropbox <- "web_scraping_tcmba_despesas/backup"
            
            if(rdrop2::drop_exists(dir_arquivo_dropbox,
                                   dtoken = token_dropbox) == FALSE) {
                
                rdrop2::drop_create(dir_arquivo_dropbox,
                                    dtoken = token_dropbox)
            }
            
            
            print("Iniciando o UPLOAD do arquivo de backup do BD para o DropBox...")
            
            
            
            rdrop2::drop_upload(zip_bd_sqlite,
                                path = dir_bk_dropbox,
                                dtoken = token_dropbox)
            
            print("Backup do Banco de Dados (.zip) exportado com sucesso para o DropBox!")
            
            
            
            # rdrop2::drop_upload(zip_arquivos_html,
            #                     path = dir_bk_dropbox,
            #                     dtoken = token_dropbox)
            # 
            # print("Backup do Arquivos HTMLs exportado com sucesso para o DropBox!")
            # 
            

            rdrop2::drop_upload(zip_arquivo_id_ws,
                                path = dir_bk_dropbox,
                                dtoken = token_dropbox)
            
            print("Backup dos Arquivos ID_WS exportado com sucesso para o DropBox!")
            
            # Para realizar o download direto do arquivo, é preciso
            # Alterar o p número (ano final do URL) do 'dl' de 0 para 1
            # De: https://www.dropbox.com/s/qwvohhrtrz95mzq2/bk_arquivos_csv.zip?dl=0
            # Para: https://www.dropbox.com/s/qwvohhrtrz95mzq2/bk_arquivos_csv.zip?dl=1
            
    }
    
    
    
}

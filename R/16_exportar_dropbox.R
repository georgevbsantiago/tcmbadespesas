#' @title Função que exporta os arquivos CSV para o DropBox, com o objetivo
#' conectar com o Power BI
#' 
#' @description 
#' Obs: É preciso configurar o token do DropBox para a função funcionar.
#' Saiba como gerar o seu Token em: [linked phrase](https://github.com/karthik/rdrop2)
#' 
#' @param exportar_nuvem É definido como "NAO" como padrão. Mas pode ser marcado como "SIM"
#' para realizar a Exportação do arquivo .zip (com diversos CSVs) para o DropBox.
#' 
#' @importFrom magrittr %>%
#'


exportar_csv_dropbox <- function(exportar_nuvem = "NAO") {

    if(!exportar_nuvem %in% c("SIM", "NAO")) {

          stop("Digite SIM ou NAO para o argumento 'exportar_nuvem' da função")

    }
  
  
    if(exportar_nuvem == "NAO") {
    
          stop("Não realizado a exportação para o DropBox, conforme determinado pelo usuário")

    }
    
  
    # ---------------------------------------------------------------------------
    ####### O DropBox pode ser acessado com um token ou criando uma chave API

    # Saiba como gerar o seu Token em: https://github.com/karthik/rdrop2
  
    arquivos_csv_gz <- file.path("dados_exportados",
                                 "tabela_despesas_municipais_tidy_data_BR.csv.gz")


    if(file.exists("token_dropbox.rds") == FALSE) {

          stop("Realize o processo de autenticação do DropBox ",
               "e salve o TOKEN no arquivo 'token_dropbox.rds' na pasta raiz do Web Scraping.",
               "Veja as instruções no arquivo '11_backup_dropbox.R deste pacote")
    }


    token_dropbox <- readRDS("token_dropbox.rds")

    print("Iniciando processo de Autenticação do Token no DropBox!")

    dir_arquivo_dropbox <- "web_scraping_tcmba_despesas/arquivos_csv"

    if(rdrop2::drop_exists(dir_arquivo_dropbox,
                           dtoken = token_dropbox) == FALSE) {

        rdrop2::drop_create(dir_arquivo_dropbox,
                            dtoken = token_dropbox)
    }


    print("Iniciando o UPLOAD do arquivo 'CSV.gz' para o DropBox...")

    rdrop2::drop_upload(arquivos_csv_gz,
                        path = dir_arquivo_dropbox,
                        mode = "overwrite",
                        dtoken = token_dropbox)

    print("Backup do arquivo 'CSV.gz' exportado com sucesso para o DropBox!")

    # Para realizar o download direto do arquivo, é preciso
    # Alterar o p número (ano final do URL) do 'dl' de 0 para 1
    # De: https://www.dropbox.com/s/ykxn1twikwpwwie/tabela_despesas_municipais_tidy_data_BR.csv.gz?dl=0
    # Para: https://www.dropbox.com/s/ykxn1twikwpwwie/tabela_despesas_municipais_tidy_data_BR.csv.gz?dl=1

}





#' @title Função que cria os diretório do Web Scraping
#'
#' @description Os diretórios do Web Scraping são criados no diretório de trabalho escolhido pelo usuário
#'


criar_diretorios <- function() {


        dir.create("bd_sqlite")
        
        dir.create("resposta_scraping_links")
        
        dir.create("resposta_scraping_html")
        
        dir.create("log_html")
        
        dir.create("dados_exportados")
        
        dir.create("backup")
        
    
        print("As pastas foram criadas com sucesso no diretório raiz")


}

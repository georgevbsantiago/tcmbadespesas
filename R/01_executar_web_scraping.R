#' @title Função que executa o Web Scraping
#'
#' @description Essa função foi desenvolvida para executar todas as etapas do Web Scraping
#' e, então, coletar os dados públicos das Despesas dos Municípios do Estado da Bahia
#' custodiados no site do TCM-Ba
#' 
#' @param nome_scraping Nome do Diretório que será criado para alocar os dados do Web Scraping
#' @param ano_inicio Exercíco (ano) inicial da coleta de dados
#' @param cod_municipios_alvos Código do Município alvo
#' @param repetir É definido "SIM" como padrão. Mas pode ser marcado como "NAO",
#' caso não deseje repetir (na próxima execução) as consulta do Web Scraping
#' que falharam ou que não foram identificadas resposta do ente municipal
#' no dia de execução do Web Scraping
#' @param backup_local É definido como "SIM" como padrão para realizar
#' o Backup do Banco de Dados e dos arquivos HTML e CSV.
#' Mas pode ser marcado como "NAO". 
#' @param backup_nuvem Realiza o Backup dos dados para o DropBox. Como padrão, é definido "NAO".
#' Obs: É preciso configurar o token do DropBox antes de executar
#' (ver instruções na função 'exportar_csv_dropbox').
#' @param exportar_nuvem É definido como "NAO" como padrão para realizar
#' Exportar os CSVs para o DropBox com o objetivo de conectar o Power BI
#' @param sgbd Define qual é o Banco de Dados a ser utilizado.
#' Por padrão, é definido o SQLite.
#' 
#' @examples 
#' \dontrun{
#' executar_web_scraping(nome_scraping = "ws_tcmba_despesas",
#'                       ano_inicio = 2019,
#'                       cod_municipios_alvos = c(2928703),
#'                       sgbd = "sqlite",
#'                       repetir = "SIM",
#'                       backup_local = "SIM",
#'                       backup_nuvem = "NAO",
#'                       exportar_nuvem = "NAO")
#'}
#'
#'
#' @export

executar_web_scraping <- function(nome_scraping = "ws_tcmba_despesas",
                                  ano_inicio = 2019,
                                  cod_municipios_alvos = c(2928703),
                                  sgbd = "sqlite",
                                  repetir = "SIM",
                                  backup_local = "SIM",
                                  backup_nuvem = "NAO",
                                  exportar_nuvem = "NAO") {

  # 2928703 é o código do Município de Santo Antônio de Jesus
  
  # Etapas de padronização dos argumentos preenchidos pelo usuário
  nome_scraping <- as.character(nome_scraping)
  ano_inicio <- as.integer(ano_inicio)
  cod_municipios_alvos <- as.integer(cod_municipios_alvos)
  sgbd <- stringr::str_to_lower(as.character(sgbd))
  repetir <- stringr::str_to_upper(as.character(repetir))
  backup_local <- stringr::str_to_upper(as.character(backup_local))
  backup_nuvem <- stringr::str_to_upper(as.character(backup_nuvem))
  
  
  # Etapas de verificação dos argumentos preenchidos pelo usuário
  if(nome_scraping == "") {
    
        stop("Defina uma nome para o Scraping")
  }
  
  if(stringr::str_detect(nome_scraping, "[*//={}]") == TRUE) {
    
        stop("Não utilize os caracteres inválidos no nome do Scraping")
  }
  
  
  if(length(ano_inicio) > 1){
    
        stop("Informe o ano de início do Web Scraping: 2016, 2017, 2018 ou 2019")
    
  }
  
  if(!ano_inicio %in% c(2016, 2017, 2018, 2019)){
    
        stop("Informe um dos seguintes anos: 2016, 2017, 2018 ou 2019")
    
  }
  
  # verificardor_cod_municipio <- tcm_cod_municipios$cod_municipio %>% 
  #                               stringr::str_detect(cod_municipios_alvos) %>%
  #                               all()
  # 
  # 
  # if(verificardor_cod_municipio == FALSE){
  # 
  #     stop("Informe código(s) de município(s) válido(s). Consulta 'tcmbadespessa::tcm_cod_municipios'")
  # 
  # }

  
  
  if(!sgbd %in% c("sqlite", "mysql")) {
    
        stop("Digite o SQLite ou o MySql para conectar ao Banco de Dados")
  }
  
  
  if(!repetir %in% c("SIM", "NAO")) {
    
        stop("Digite SIM ou NAO para o argumento 'repetir' da função")
  }
  
  
  if(!backup_local %in% c("SIM", "NAO")) {
    
        stop("Digite SIM ou NAO para o argumento 'backup_local' da função")
  }
  
  if(!backup_nuvem %in% c("SIM", "NAO")) {
    
        stop("Digite SIM ou NAO para o argumento 'backup_nuvem' da função")
  }
  
# ----------------------------------------------------------------------------------------------------
  
  # Rotina para verificar se o Web Scraping está executando pela primeira vez, ou se é uma continuação.
  
  arq_rds_id_ws <- paste0("id_", nome_scraping, ".rds")
  
  if (dir.exists(nome_scraping) == FALSE &
      file.exists(arq_rds_id_ws) == FALSE) {
    
          # Função que cria o diretório com o nome do Web Scraping
          dir.create(nome_scraping)
          
          # Função que define o diretório Raiz
          setwd(nome_scraping)
          
          print("O Diretório principal foi criado com Sucesso!")
          
          # Função que define o Diretório Raiz e crias demais diretórios
          criar_diretorios()
          
          # Função que cria a identidade do Web Scraping
          criar_ws_id(nome_scraping, arq_rds_id_ws, sgbd)
          
          # Função que cria o Banco de Dados
          criar_bd(sgbd)
          
          # Função que cria 5 tabelas no Banco de Dados.
          criar_tabelas_bd(sgbd)
    
  } else {
    
    print("Executado Web Sacraping...")
    
  }
  
  
  if(dir.exists(nome_scraping) == TRUE) {
    
    setwd(nome_scraping)
    
    print("O Diretório Raiz foi definido com Sucesso!")
    
  }
  
  
  if(file.exists(arq_rds_id_ws) == TRUE) {
    
    info_ws <- readRDS(arq_rds_id_ws)
    
    print(paste("Nome do Web Scraping:", info_ws$nome))
    print(paste("Diretório do Web Scraping:", info_ws$dir_wd))
    print(paste("SGBD do Web Scraping:", info_ws$sgbd_ws))
    print(paste("Data de criação do Web Scraping:", info_ws$data_time_create))
    
    # Registrar a data e hora do início da execução do Web Scraping no arquivo RDS
    inicio_exe_ws_data_time(arq_rds_id_ws)
    
    # ---------------------------------------------------------------------------
    
    
    # Função que cria a tabela dCalendario
    criar_tb_dcalendario(ano_inicio, sgbd)
    
    # Função que faz o Web Scraping do código e nome dos Municípios
    criar_tb_dmunicipios(sgbd)
    
    # Função que obtém o código e nome das Entidades via Web Service
    criar_tb_dmunicipios_entidades(sgbd)
    
    # Função que cria a tabela das entidades alvos, controlando a paginação por cod_municipio e Ano.
    criar_tb_entidades_alvos_paginas(cod_municipios_alvos, sgbd)
    
    # Função executa o Web Scraping das páginas que têm os links que darão acesso
    # as páginas HTML que contêm os dados sobre as despesas
    executar_scraping_num_pags(sgbd)
    
    # Função que Cria a tabela central para Controle das Requisições dos HTML que contêm
    # as informções sobre as despesas municipais
    criar_tb_requisicoes_despesas(sgbd)
    
    # Função cria a tabela de requisições e faz o Web Scraping das páginas HTML que contêm
    # os dados das despesas. #OBS: O tempo de resposta do TCM está entre 10 a 30 segundos
    executar_scraping_html_despesas(sgbd)
    
    # Função que faz o parser dos HTMLs das depesas e o Data Wrangling dos HTMLs
    executar_data_wrangling_html_despesas(sgbd)
    
    # Função que faz o pré-processamento dos dados obtidos do HTML, aplicando o conceito Tidy Data 
    # Por fim, cria uma tabela no padrão Tidy Data no BD e exporta dois arquivos CSV para a pasta
    # dados_exportados. Um arquivo no padrão Tidy Internacional e outro no padrão Brasil (R$).
    executar_tidy_data(sgbd)
    
    # O conceito Tidy Data de Hadley Wickham tem por objetivo arrumar os dados
    # para que eles sejam utilizados em softwares de estatísticas ou
    # de Business Intelligence sem a necessidade de realizar
    # maiores transformações nos dados.
    
    # O Conceito está resumido nestas três regras:
    # - Cada variável deve ter sua própria coluna.
    # - Cada observação deve ter sua própria linha.
    # - Cada valor deve ter sua própria célula.
    
    #(http://r4ds.had.co.nz/tidy-data.html)
    
    # Função que faz o Backup local do Banco de Dados e dos arquivos HTML e CSV.
    # e o Backup em nuvem no DropBox
    executar_backup_arquivos(backup_local, backup_nuvem)
    
    # Exportar os CSVs para o Dropbox para conectar ao Power BI
    exportar_csv_dropbox(exportar_nuvem)
    
    
    # ---------------------------------------------------------------------------
    
    
    # Registrar a data e hora do fim da execução do Web Scraping no arquivo RDS
    fim_exe_ws_data_time(arq_rds_id_ws)
    
    
    print("## Web Scraping finalizado com sucesso! ###")
    
  } else {
    
    stop("Ocorreu algum problema durante a execução do Web Scraping!!!")
    
  }
  
  
}

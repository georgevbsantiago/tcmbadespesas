#' @title Função que cria as tabelas do Banco de Dados no SQLite
#'
#'
#' @param sgbd Define qual é o Banco de Dados a ser utilizado.
#' Por padrão, é definido o SQLite.
#' 
#' 

criar_tabelas_bd <- function(sgbd) {


    if (DBI::dbExistsTable(connect_sgbd(sgbd), "tabela_dcalendario") == FALSE) {

        DBI::dbExecute(connect_sgbd(sgbd), "CREATE TABLE tabela_dcalendario (
                                                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                                                    data TEXT,
                                                    ano TEXT,
                                                    mes TEXT
                                                    );"
        )

        DBI::dbDisconnect(connect_sgbd(sgbd))

    }



    if (DBI::dbExistsTable(connect_sgbd(sgbd), "tabela_tcm_dmunicipios") == FALSE) {

        DBI::dbExecute(connect_sgbd(sgbd), "CREATE TABLE tabela_tcm_dmunicipios (
                                                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                                                    cod_municipio INT,
                                                    nm_municipio TEXT,
                                                    log_create TEXT
                                                    );"
        )

        DBI::dbDisconnect(connect_sgbd(sgbd))

    }


    if (DBI::dbExistsTable(connect_sgbd(sgbd), "tabela_tcm_dmunicipios_entidades") == FALSE) {

        DBI::dbExecute(connect_sgbd(sgbd), "CREATE TABLE tabela_tcm_dmunicipios_entidades (
                                                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                                                    cod_municipio INT,
                                                    nm_municipio TEXT,
                                                    cod_entidade INT,
                                                    nm_entidade TEXT,
                                                    log_create TEXT
                                                    );"
        )

        DBI::dbDisconnect(connect_sgbd(sgbd))

    }


    if (DBI::dbExistsTable(connect_sgbd(sgbd), "tabela_tcm_ddespesas") == FALSE) {

        DBI::dbExecute(connect_sgbd(sgbd), "CREATE TABLE tabela_tcm_ddespesas (
                                                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                                                    cod_municipio INT,
                                                    nm_municipio TEXT,
                                                    cod_entidade INT,
                                                    nm_entidade TEXT,
                                                    cod_despesa INT,
                                                    nm_despesa TEXT,
                                                    log_create TEXT
                                                    );"
        )

        DBI::dbDisconnect(connect_sgbd(sgbd))

    }


    if (DBI::dbExistsTable(connect_sgbd(sgbd), "tabela_tcm_dfontes_recursos") == FALSE) {

        DBI::dbExecute(connect_sgbd(sgbd), "CREATE TABLE tabela_tcm_dfontes_recursos (
                                                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                                                    cod_municipio INT,
                                                    nm_municipio TEXT,
                                                    cod_entidade INT,
                                                    nm_entidade TEXT,
                                                    cod_recurso INT,
                                                    nm_recurso TEXT,
                                                    log_create TEXT
                                                    );"
        )

        DBI::dbDisconnect(connect_sgbd(sgbd))

    }


    if (DBI::dbExistsTable(connect_sgbd(sgbd), "tabela_entidades_alvos_paginas") == FALSE) {

        DBI::dbExecute(connect_sgbd(sgbd), "CREATE TABLE tabela_entidades_alvos_paginas (
                                                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                                                    ano TEXT,
                                                    cod_municipio INT,
                                                    nm_municipio TEXT,
                                                    cod_entidade INT,
                                                    nm_entidade TEXT,
                                                    pagina INT,
                                                    filtro INT
                                                    );"
        )

        DBI::dbDisconnect(connect_sgbd(sgbd))

    }


    if (DBI::dbExistsTable(connect_sgbd(sgbd), "tabela_paginas_links") == FALSE) {

        DBI::dbExecute(connect_sgbd(sgbd), "CREATE TABLE tabela_paginas_links (
                                                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                                                    ano TEXT,
                                                    cod_municipio INT,
                                                    nm_municipio TEXT,
                                                    cod_entidade INT,
                                                    nm_entidade TEXT,
                                                    pagina INT,
                                                    status_request_html_pag TEXT,
                                                    log_request_html_pag TEXT,
                                                    nm_arq_html_pag TEXT,
                                                    arq_html_pag_tratado TEXT,
                                                    hash_arq_html_pag TEXT,
                                                    log_tratamento_arq_html_pag TEXT
                                                    );"
        )

        DBI::dbDisconnect(connect_sgbd(sgbd))

    }

    if (DBI::dbExistsTable(connect_sgbd(sgbd), "tabela_requisicoes") == FALSE) {

        DBI::dbExecute(connect_sgbd(sgbd), "CREATE TABLE tabela_requisicoes (
                                                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                                                    ano TEXT,
                                                    cod_municipio INT,
                                                    nm_municipio TEXT,
                                                    cod_entidade INT,
                                                    nm_entidade TEXT,
                                                    pagina INT,
                                                    status_request_html_pag TEXT,
                                                    log_request_html_pag TEXT,
                                                    nm_arq_html_pag TEXT,
                                                    arq_html_pag_tratado TEXT,
                                                    hash_arq_html_pag TEXT,
                                                    log_tratamento_arq_html_pag TEXT,
                                                    documento TEXT,
                                                    empenho TEXT,
                                                    valor_documento TEXT,
                                                    link_despesa TEXT,
                                                    nm_arq_html_despesa TEXT,
                                                    status_request_html_despesa TEXT,
                                                    log_request_html_despesa TEXT,
                                                    arq_html_despesa_tratado TEXT,
                                                    hash_arq_html_despesa TEXT,
                                                    log_tratamento_arq_html_despesa TEXT
                                                    );"
        )

        DBI::dbDisconnect(connect_sgbd(sgbd))

    }


    if (DBI::dbExistsTable(connect_sgbd(sgbd), "tabela_despesas_municipais") == FALSE) {

        DBI::dbExecute(connect_sgbd(sgbd), "CREATE TABLE tabela_despesas_municipais (
                                                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                                                    fase TEXT,
                                                    data_do_pagamento TEXT,
                                                    valor_do_pagamento TEXT,
                                                    documento TEXT,
                                                    empenho TEXT,
                                                    data_empenho TEXT,
                                                    tipo_de_empenho TEXT,
                                                    favorecido TEXT,
                                                    valor_do_empenho TEXT,
                                                    valor_das_retencoes TEXT,
                                                    restos_a_pagar TEXT,
                                                    conta_bancaria TEXT,
                                                    fonte_de_recurso_tcm TEXT,
                                                    fonte_de_recurso_gestor TEXT,
                                                    tipo_de_documento TEXT,
                                                    cod_municipio TEXT,
                                                    municipio TEXT,
                                                    cod_entidade TEXT,
                                                    nm_entidade TEXT,
                                                    poder TEXT,
                                                    orgao TEXT,
                                                    unidade_orcamentaria TEXT,
                                                    funcao TEXT,
                                                    subfuncao TEXT,
                                                    programa TEXT,
                                                    tipo_acao TEXT,
                                                    acao TEXT,
                                                    natureza_da_despesa_tcm TEXT,
                                                    natureza_da_despesa_gestor TEXT,
                                                    fonte_de_recurso_tcm_2 TEXT,
                                                    fonte_de_recurso_gestor_2 TEXT,
                                                    licitacao TEXT,
                                                    dispensa_inexigibilidade TEXT,
                                                    contrato TEXT,
                                                    declaracao TEXT,
                                                    foreign_key INTEGER,
                                                    nm_arq_html_despesa TEXT,
                                                    hash_arq_html_despesa TEXT,
                                                    log_tratamento_arq_html_despesa TEXT,
                                                    link TEXT
                                                    );"
        )

        DBI::dbDisconnect(connect_sgbd(sgbd))

    }

    if (DBI::dbExistsTable(connect_sgbd(sgbd), "tabela_despesas_municipais_tidy_data") == FALSE) {

        DBI::dbExecute(connect_sgbd(sgbd), "CREATE TABLE tabela_despesas_municipais_tidy_data (
                                                  	id INTEGER,
                                                  	fase TEXT,
                                                  	data_do_pagamento	TEXT,
                                                  	valor_do_pagamento	REAL,
                                                  	documento	TEXT,
                                                  	empenho	TEXT,
                                                  	data_empenho	TEXT,
                                                  	tipo_de_empenho	TEXT,
                                                  	cod_favorecido TEXT,
                                                  	nm_favorecido	TEXT,
                                                  	valor_do_empenho	REAL,
                                                  	valor_das_retencoes	REAL,
                                                  	restos_a_pagar TEXT,
                                                  	conta_bancaria TEXT,
                                                  	cod_fonte_de_recurso_tcm	TEXT,
                                                  	nm_fonte_de_recurso_tcm	TEXT,
                                                  	cod_fonte_de_recurso_gestor	TEXT,
                                                  	nm_fonte_de_recurso_gestor TEXT,
                                                  	tipo_de_documento	TEXT,
                                                  	cod_municipio	TEXT,
                                                  	municipio	TEXT,
                                                  	cod_entidade TEXT,
                                                  	nm_entidade	TEXT,
                                                  	poder	TEXT,
                                                  	cod_orgao	TEXT,
                                                  	nm_orgao TEXT,
                                                  	cod_unidade_orcamentaria	TEXT,
                                                  	nm_unidade_orcamentaria	TEXT,
                                                  	cod_funcao TEXT,
                                                  	nm_funcao	TEXT,
                                                  	cod_subfuncao TEXT,
                                                  	nm_subfuncao TEXT,
                                                  	cod_programa TEXT,
                                                  	nm_programa	TEXT,
                                                  	cod_tipo_acao TEXT,
                                                  	nm_tipo_acao TEXT,
                                                  	cod_acao TEXT,
                                                  	nm_acao	TEXT,
                                                  	cod_natureza_da_despesa_tcm TEXT,
                                                  	nm_natureza_da_despesa_tcm TEXT,
                                                  	cod_natureza_da_despesa_gestor TEXT,
                                                  	nm_natureza_da_despesa_gestor	TEXT,
                                                  	cod_fonte_de_recurso_tcm_2	TEXT,
                                                  	nm_fonte_de_recurso_tcm_2	TEXT,
                                                  	cod_fonte_de_recurso_gestor_2 TEXT,
                                                  	nm_fonte_de_recurso_gestor_2 TEXT,
                                                  	licitacao	TEXT,
                                                  	Dispensa_Inexigibilidade TEXT,
                                                  	contrato TEXT,
                                                  	declaracao TEXT,
                                                  	foreign_key	INTEGER,
                                                  	nm_arq_html_despesa	TEXT,
                                                  	hash_arq_html_despesa	TEXT,
                                                  	log_tratamento_arq_html_despesa	TEXT,
                                                  	link TEXT
                                                    );"
        )

        DBI::dbDisconnect(connect_sgbd(sgbd))

    }
    
    
    if (DBI::dbExistsTable(connect_sgbd(sgbd), "tabela_log") == FALSE) {
        
        DBI::dbExecute(connect_sgbd(sgbd), "CREATE TABLE tabela_log (
                                                            id INTEGER PRIMARY KEY AUTOINCREMENT,
                                                          	data_time TEXT,
                                                          	nm_log_erro TEXT,
                                                          	entrada_result TEXT,
                                                          	entrada_error TEXT,
                                                          	foreign_key TEXT,
                                                          	cod_entidade TEXT,
                                                          	nm_entidade TEXT,
                                                          	ano TEXT,
                                                          	mes TEXT,
                                                          	outros TEXT,
                                                          	sgbd TEXT
                                                            );"
        )
        
        DBI::dbDisconnect(connect_sgbd(sgbd))
        
    }


}

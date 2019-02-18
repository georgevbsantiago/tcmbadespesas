# tcmbadespesas

The goal of tcmbadespesas is to ...
---
title: "Web Scraping - Despesas dos Municípios do Estado da Bahia, via site do Tribunal de Contas dos Municípios do Estado da Bahia - TCM-Ba"
author: "George Santiago"
date: "17 de fevereiro de 2019"
output: html_document, github_document
by: keepgrabbing.py - In memory of Aaron Swartz
---

# O Projeto

O pacote `tcmbadespesas` é uma das ferramentas utilizadas no projeto de "Transparência das Contas Públicas", desenvolvido e executado pelo Observatório Social do Brasil - Município de Santo Antônio de Jesus - Estado da Bahia.

## Sobre a proposta e o objetivo do pacote

O objetivo do pacote `tcmbadespesas` é obter os dados de Despesas dos Municípios da Bahia, custodiados e disponibilizados no site do Tribunal de Contas dos Municípios do Estado da Bahia (TCM-Ba - [link do TCM-Ba](http://www.tcm.ba.gov.br/consulta-de-despesas/)). Para tanto, foi aplicado uma técnica denominada "Web Scraping" para 'capturar' os dados no formato de arquivo eletrônico HTML e, após o seu tratamento e modelagem, consolidar todos os dados num formato *legível por máquina* que permita a sua utilização em ferramentas de análise de dados como Excel, Power Bi, Qlik, Tableau... dentre outras.

Todo o esforço empregado no desenvolvimento desta ferramenta tem como motivação o propósito de tornar o conteúdo das Contas Públicas mais acessíveis ao cidadão, ao capturar dados e, em seguida, aplicar técnicas de visualização que permitam a qualquer pessoa obter respostas a partir de perguntas simples como, por exemplo: Qual são os maiores fornecedores do ente municipal (prefeitura, câmara e entidades da adm. indireta)? Quanto o ente municipal (prefeitura, câmara e entidades da adm. indireta) gasta com despesas de diárias? Quanto o ente municipal (prefeitura. câmara e entidades da adm. indireta) gasta com despesas de Locação de Imóvel? Quanto o ente municipal (prefeitura, câmara e entidades da adm. indireta) gasta com despesas de Combustível? Quanto o ente municipal (prefeitura, câmara e entidades da adm. indireta) gasta com despesas de Merenda Escolar?... dentre outras perguntas.

Além disse, parte do esforço empregado no desenvolvimento desta ferramenta é motivado pelo fato de que o TCM-Ba ainda não disponibiliza os dados municipais custodiados no formato de Dados Abertos (apesar de ter um excelente Portal de Transparência dos Dados Municipais - OBS: Há uma diferença substancial (de propósito e de finalidade jurídica) entre Portal de Transparência e Portal de Dados Abertos. Enquanto o Portal de Transparência visa disponibilizar o acesso de informações com foco em dados legíveis por Humanos, o Portal de Dados Abertos visa disponibilizar dados legíveis por máquinas (computadores) que facilitaram análises - gráficas, estatísticas... - para Humanos. Ou seja, embora Portal de Transparência e Portal de Dados Abertos tenham como objetivo a Transparência dos dados Governamentais, são ferramentas complementares e, por isso, não se confundem). Além disso, numa perspectiva jurídica, cabe pontuar que o Portal de Transparência, assim como o Portal de Dados Abertos, tem fundamento jurídico específicos na Constituição Federal de 1988, na Lei de Responsabilidade Fiscal (Lei n.° 101/2000) e na Lei de Acesso à Informação (Lei n.º 12.527/2011), logo, é dever/obrigação dos entes públicos implementarem as duas funcionalidades.

Nesse contexto, entretanto, cabe informar que após interlocução do Observatório Social do Brasil - Município de Santo Antônio de Jesus com o TCM-Ba (por meio de ofício e eventos institucionais) foi sinalizado que o desenvolvimento de um Portal de Dados Abertos seria desenvolvido, haja vista a sua relevância para a Sociedade.
Com isso, o TCM-Ba, assim como outros Entes Governamentais e Tribunais de Contas do Brasil, consolidam a sua postura de parceria e colaboração com o exercício do Controle Social da Administração Pública. Nesse contexto, assim que o site de Portal de Dados Abertos do TCM-Ba for lançado, o desenvolvimento do presente pacote se tornará desnecessário. Até lá, o seu desenvolvimento será extremamente necessário para viabilizar maior transparência e acesso das despesas municipais.

## Propósito do Web Scraping para o OS-SAJ

Ao fim da execução do "Web Scraping", é gerado um arquivo ".csv" com os dados de despesas coletados e tratados dos municípios indicados.

No caso do Observatório Social de Santo Antônio de Jesus, esses dados serão utilizados para alimentar o "Painel de Monitoramento das Despesas dos Municípios do Estado da Bahia". Contudo, disponibilizaremos os dados por meio do link para que qualquer interessado possa realizar análises dados.


## Etapas e Estratégias do Web Scraping

Como citado no material disponibilizado pelo do Curso-R [link](https://www.curso-r.com/material/webscraping/), há 4 (quatro) tipos de "macro 'desafios' de Web Scraping" que exigem estratégias e técnicas distintas, a saber:

* Uma busca e uma paginação;
* Uma busca e muitas paginações;
* Muitas buscas e uma paginação por busca;
* Muitas buscas e muitas paginações por busca.

Os dois primeiros "macro desafios de Web Scraping" são os mais "fáceis", não exigindo maiores técnicas ou estratégias, especificamente no controle das requisição das páginas HTML. Já os dois últimos, podem representar grandes desafios no desenvolvimento do "Web Scraping", em especial no controle das requisição das páginas HTML, a depender, por exemplo: _i)_ do volume de requisições a serem realizadas; _ii)_ de como o Servidor se comporta com o crescente número de requisições; _iii)_ das estratégias de controle a serem adotadas para não obter dados duplicados ou "esquecer" de raspar determinadas páginas; _iv)_ da infraestrutura que será utilizada para executar o Web Scraping... dentre outros desafios enfrentados a depender do caso concreto.

No caso do "Web Scraping" em apreço, estremos enfrentado o Web Scraping de maior desafio técnico *Muitas buscas e muitas paginações por busca*, pelo menos do ponto de vista da arquitetura de execução do código.

A título de exemplo, ao analisar a quantidade de requisições das despesas de 25 municípios do Estado da Bahia (de uma total de 417) somente do ano de 2018, chegamos ao número aproximado de 280.000 requisições ao site do TCM-Ba! Isso se deve ao "caminho" a ser percorrido até chegar na página HTML com os dados detalhados da respectiva despesa. Para sintetizar o desafio, foi preciso percorrer 02 (duas) macro etapas: 1) Acessar, via requisição POST, as páginas que disponibilizavam as tabelas com os dados sumarizados das despesas do respectivo Ente Municipal (aqui, o desafio foi acessar a primeira página e pecorrer até a última, já que cada página somente disponibilizava 20 linhas de dados); 2) Acessar cada link disponibilizado em cada página acessada (com tabela sumarizada) para chegar ao conteúdo detalhamento das despesas. Por exemplo, ao acessar as despesas de da Prefeitura Municipal de Santo Antônio de Jesus referente ao exercício 2018, vamos acessar uma página com as 20 primeiras despesas sumarizadas e mais os respectivos links para acesso detalhados das respectivas despesas. Num cálculo simples, conclui-se que se o site do TCM-Ba disponibiliza 20 resultados por páginas e identificando que a Prefeitura de Santo Antônio de Jesus tem 744 páginas, teremos que realizar cerca de 14.800 requisições para obter os dados detalhados das despesas, de um total de quase 280.000 ao considerar somente os 25 municípios inicialmente selecionados pelo OS-SAJ. Para incrementar o nosso cálculo, cabe informar que cada requisição de página de despesa detalhada ao site do TCM-Ba demora entre 5 a 12 segundos em regra. Logo, numa perspectiva otimista (ou seja, sem interrupções), ao realizar uma requisição por vez, demoraríamos cerca de 25 dias para concluir a obtenção de todas as 280.000 páginas referentes às despesas executadas somente por 25 municípios!!!

A parti deste contexto, percebe-se que o esforço computacional para requisitar os 417 municípios desmotivaria a obtenção dos dados, já que o tempo que se levaria para obtê-los reduziria o interessa Social (considerando que o interesse social é movido por fatos recentes), pois não conseguiríamos obter dados atualizados, ainda que pensássemos que a atualização dos dados mensalmente.

Ciente dessas informações, conclui-se, portanto, que ao considerar que realizar o web scraping de 417 municípios para obter os dados referentes as despesas de 2018 seria inviável sob a perspectiva computacional e do interesse social. Caso o TCM-Ba adote o Portal de Dados Abertos, obter esse volume de informação demore somente alguns minutos, pois exigirá apenas alguns clicks do usuários para obter os dados tratados e no formato adequado para utilização em ferramentas de análise como o Excel, Power Bi, Qlik, Tableau... dentre outras.

## Estrutura do Código em Linguagem R do Web Scraping

Numa perspectiva de arquitetura das etapas e de organização dos arquivos .R, as funções para execução do código foram divididas em 17 arquivos .R, a saber:

`01_executar_web_scraping.R` - É o 'orquestrador' de toda a execução do código. É neste arquivo que contém a função que executará as funções numa ordem lógica e predefinida para obter o resultado final, ou seja: Os dados de despesas municipais disponíveis em um formato legível por máquina.

`02_criar_diretorios.R` - Cria a estrutura de diretórios na pasta de trabalho (Work Directory) definida pelo usuário.

`03_criar_ws_id.R` - Cria uma arquivo .rds com metadados do Web Scraping. Além disso, serve para identificar a pasta de trabalho (Work Directory) do Web Scraping.

`04_connect_sgbd.R` - Cria a conexão para o Sistema Gerenciador do Banco de Dados e, também, por padrão, cria o arquivo do Banco de Dados do SQLite.

`05_criar_tabelas_bd.R` -  Cria as tabelas no Banco de Dados.

`06_criar_tb_dcalendario.R` - Cria a tabela 'tabela_dcalendario' no BD  (uma tabela dimensão, numa perspectiva do conceito de Business Intelligence - BI), para ser utilizada tanto na confecção das tabelas de requisição, como para construir e manter a tabela a ser utilizada no BI (Power BI a Microsoft) que utilizados no painel de análise.

`07_criar_tb_dmunicipios.R` - Cria a tabela 'tabela_tcm_dmunicipios' no BD (uma tabela dimensão, numa perspectiva do conceito de Business Intelligence - BI), para ser utilizada tanto na confecção das tabelas de requisição, como para construir e manter a tabela a ser utilizada no BI (Power BI a Microsoft) que utilizados no painel de análise.

`08_criar_tb_dmunicipios_entidades.R` - Cria a tabela 'tabela_tcm_dmunicipios_entidades' (uma tabela dimensão, numa perspectiva do conceito de Business Intelligence - BI), para ser utilizada tanto na confecção das tabelas de requisição, como para construir e manter a tabela a ser utilizada no BI (Power BI a Microsoft) que utilizados no painel de análise.

`09_criar_tb_entidades_alvos_paginas.R` - Cria a tabela 'tabela_entidades_alvos_paginas' no BD para ser utilizada na confecção das tabelas de requisição, com o propósito de regisrar as páginas já "raspadas" que contêm as despesas sumarizadas dos entes municipais, bem como os links para as páginas com as despesas detalhadas.

`10_executar_scraping_num_pags.R` - Realiza a execução do "Web Scraping" responsável por obter as páginas com os dados sumarizados e os links das páginas com os dados das despesas detalhadas.

`11_criar_tb_requisicoes_despesas.R` - Realiza o 'parser' (extração) dos dados dos arquivos HTML que contêm as tabelas com os dados sumarizados e os links para acessar as páginas com os dados detalhados das despesas e, então, confeccionar a tabela central de requisições do Banco de Dados.

`12_executar_scraping_html_despesas.R` - Executa o Web Scraping das páginas HTML que contêm os dados detalhados das despesas municipais.

`13_executar_data_wrangling_html_despesas.R` - Realiza o 'parser' (extração) dos dados das despesas municipais que estão armazenados nos arquivos HTML.

`14_executar_tidy_data.R` - Transmuta os dados do arquivo HTML (que já estão armazenados no BD) para o formato 'Tidy Data', com vista a possibilitar a importação dos dados para qualquer software de análise de dados. 

`15_backup_arquivos.R` -  Realiza o Backup dos dados.

`16_exportar_dropbox.R` - Exporta os dados tratados para o DropBox com o objetivo de alimentar a ferramenta de BI ou disponibilizar os dados à Sociedade.

`17_utils.R` - Arquivo que contém diversas funções confeccionadas para utilizar durante a execução do Web Scraping.


## Outros objetivos/propósitos técnicos do Web Scraping

1 - Empregar um comportamento de Web Scraping, em vez de Web Crawler.

2 - Tornar o Web Scraping autônomo e que não pare devido a exceções após ser executado.

3 - Tornar o Web Scraping executável por aplições de automação/tarefas como Cron do Linux.

4 - Tornar o Web Scraping agnóstico de Sistema de Banco de Dados Relacional (pelo menos, aceite o SQLite e MySQL).

5 - Tornar o Web Scraping reprodutível em um ambiente RStuido implantado via Docker

6 - Exportar o resultado do Scraping para um repositório público (ex: DropBox) para que qualquer pessoa possa baixar os dados.

7 - Desenvolver um ChatBot no Telegram para sinalizar ao mantenedor do Web Scraping quando ele inicia e termina, ou quando ocorre um erro que interrompe a execução. (em desenvolvimento)


# Comunidade e Colaboração

O Observatório Social do Brasil, aqui representado pelo Observatório Social do Município de Santo Antônio de Jesus - Ba, gostaria de agradecer ao apoio da Comunidade R para o desenvolvimento do presente pacote, em especial à comunidade [TidyVerse]("https://www.tidyverse.org/), ao [Curso-R](https://www.curso-r.com/) pela colaboração ativa e material disponibilizado, à comunidade R Brasil (no Telegram), e todos aqueles de disponibilizam ebook sobre a linguagem R [link](https://bookdown.org/), posts e desenvolvem pacotes e soluções de infraestrutura para a linguagem R. Sem o esforço, colaboração, cooperativismo e abnegação de todos, esse trabalho não seria possível.

Ademais, quaisquer sugestões, reclamações ou críticas podem ser realizadas no área `issues` do GitHub.


# BUGS e Melhorias

Sabemos que o código disponibilizado na versão 1.0 pode ser melhorado e otimizado a sua performance. Contudo, até onde testamos, os resultados obtidos mostraram-se consistentes ao objetivo final que é alimentar o 'Painel de Monitoramento das Despesas dos Municípios do Estado da Bahia', que tem o acesso disponibilizado a qualquer pessoa por meio do site do Observatório Social de Santo Antônio de Jesus.

Entretanto, registramos os seguintes tópicos para relatar: Prioridades, Bugs, Melhorias, Implementações, Ajuste na Infraestrutura... do código:

```{r eval=FALSE, include=FALSE}

### PRIORIDADES
#!!! Implementar um ChatBot pelo Telegram com o pacote 'Plumber';


-------------------------------------------------------------------------------------

### BUG e WARNING:

# !!! Esse erro é provocado pela função dbWriteTable do pacote 'DBI'. Ainda não há uma correção clara para ele. Por enquanto, é só executar novamente que o erro é superado. 
#  Erro intermitente:
# Error in (function (classes, fdef, mtable):
# unable to find an inherited method for function ‘dbWriteTable’ for signature ‘"SQLiteConnection", "character"

# !!! Tratar esse aviso (abaixo). Provavelmente, ocorre durante a aplicação da função separete na execução do padrão tidy data
# 1: Expected 2 pieces. Missing pieces filled with `NA` in 11 rows [153, 552, 553, 674, 1064, 1065, 1066, 2800, 3001, 3687, 3688]. 
# 2: Expected 2 pieces. Missing pieces filled with `NA` in 11 rows [153, 552, 553, 674, 1064, 1065, 1066, 2800, 3001, 3687, 3688]. 


### MELHORIAS

#!!! Implementar paralelismo (multi-threading) para acelerar as requisicções HTTP e o tratamento dos dados, ou, ainda, permitir a execucação das requisições e o tratamento de dados em paralelo. Contudo, isso depende do pacote 'furrr' que apesar de ter a função 'furrr::pwalk' já disponível na versão do pacote de desenvolvimento no GitHub, ainda não está disponível no CRAN. Em último caso, poderíamos tentar a implementação da função 'furrr::pmap', mas isso ainda depende de testes a serem realizados. Outra possibilidade é usar a nova funcionalidade do RStudio 1.2 (Preview) que permite executar Jobs em segundo plano.

#!!! Implementar uma rotina para evitar timeout nos Webs Scrapings que estão
#    contidos nas funções 'criar_tb_dmunicipios_entidades' e 'criar_tb_dmunicipios'

#!!! Aprimorar as funções que tratam erros de requisição HTTP

#!!! Analisar a utilização da função 'fs::path_file_sanitize()' para sanear caminhos de arquivos (retirar caracteres especiais) e o seu comprimento (maiores que 256 caracteres)

#!!! Verificar a necessidade de realizar essa troca
# tb_municipios_alvos_novos <- tidyr::crossing(tb_dcalendario,
#                                              tb_municipios_alvos_novos) %>%
#
# tb_municipios_alvos_novos <- merge.data.frame(tb_dcalendario,
#                                              tb_municipios_alvos_novos) %>%

#!!! Desenvolver uma nova lógica para a função "executar_scraping_num_pags"

#!!! Criar 3 Banco de Dados. OLTP - Para o Web Scraping; Data Stage Area - Para os Dados Extraídos dos arquivos HMTL de Despesas; 4 - Data WareHouse - Para conectar ao Power BI

#!!! Retirar a condição 'AUTOINCREMENT' no campo de criação das tabelas, conforme sugerido na documentação no SQLite

#!!! Verificar se a rotina de tratamento de erro na função tcmbapessoal::connect_sgbd(sgbd) possibilita
#    acabar com as rotinas de While, já que a função nunca falharia devido a rotina de tcmbapessoal::connect_sgbd(sgbd)

### IMPLEMENTAÇÕES
# NO CÓDIGO
#!!! Colocar uma condição IF para pausar requisições entre 5h30 a 6h00

#!!! Gerar 'alertas' sobre os pagamentos para publicar no Facebook, Telegram ou Facebook
#    Ex: Despesas de festas em períodos não festivos; Ou emitir relatório resumido na forma de imagem
#    para ser enviado via Telegram, após obter os dados completos do mês;
#!!! Integrar o R com o Telegram
# https://blog.datascienceheroes.com/get-notify-when-an-r-script-finishes-on-telegram/

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# NA INFRAESTRUTURA
#...


# FALTA TESTAR
#!!! A abordagem para evitar a criação de links de requisição já existeste na 'tabela_requisicoes'
#    ao tratar páginas de despesas que deixaram de ter menos de 20 links, após a complementação
#    dos dados pelo ente municipal. (Realizei um commit em relação a essa etapa;)


```


# Preparando e Executando o pacote `tcmbadespesas`

## Infraestrutura

Caso o usuário deseje executar o  "Web Scraping" do seu computador pessoas, precisará apensas seguir a sugestão de nomenclattura dos arguimentos abaixo:

```{r eval=FALSE, include=FALSE}

# Instalar o pacote:
devtools::install_github("georgevbsantiago/tcmbadespesas")

library(tcmbadespesas)

setwd("/exemplo/") # Selecionar a pasta de trabalho (Work Directory) que será armazenado os dados coletados pelo 'Web Scraping'.

# Sugestão de argumentos para execução do 'Web Scraping' das despesas municipais de ex: Santo Antônio de Jesus ( cód. 2928703), que abrange a Prefeitura Municipal de SAJ, a Câmara Municipal de SAJ e o Consórcio Público Interfederaivo de Saúde RECONVALE. É possível também adicionar outros municípios. Para consultar o código dos municípios, foi disponibilizado uma tabela por meio da função `tcmbadespesas::tcm_cod_municipios` que armazena os códigos dos municípios extraídos do site do TCM-Ba. Ademais, para saber o propósito de cada argumento, favor consultar a documentação do `tcmbadespesas`por meio do comando `?tcmbadespesas::executar_web_scraping` .

tcmbadespesas::executar_web_scraping(nome_scraping = "ws_tcmba_despesas",
                                     ano_inicio = 2018,
                                     cod_municipios_alvos = c(2928703),
                                     sgbd = "sqlite",
                                     repetir = "SIM",
                                     backup_local = "SIM",
                                     backup_nuvem = "NAO",
                                     exportar_nuvem = "NAO")





```


Na hipótese do usuário preferir contratar um servidor numa infraestrutura de nuvem (ex: DigitalOcean, Microsoft Azure, Amazon Web Service), indicamos, a seguir, algumas dicas e condigurações para implementação do RStudio via Docker.

Nesta sugestão de configuração via VPS na DigitalOcean usando Docker, realizamos a instalação do: Compilador R; do pacote TidyVerse; e do Rstudio, ainda durante a configuração de implementação do "droplet" (nomenclatura de 'servidor' na DigitalOcean). Uma das fontes de consulta utilizadas foi o post: [post com instruções detalhadas no capítulo: 'Run on a remote server'](https://www.andrewheiss.com/blog/2017/04/27/super-basic-practical-guide-to-docker-and-rstudio/) .

As demais configurações sobre o 'Volume' (conceito do Docker que significa a pasta - diretório - compartilhado entre o 'container' Docker e o Host 'servidor') e as configurações de permissão para criação, leitura e escrita do diretório 'os_saj_web_scraping' foram obtidos por meio de consulta no Google. OBS: A configuração de escrita no diretório 'os_saj_web_scraping', que será utilizado como diretório de trabalho do 'Web Scraping', foi necessário, pois caso não seja realizado, o RStudio retorna um erro que informa a impossibilidade de escrever/gravar/salvar os arquivos no diretório selecionado para ser o 'Volume'.

Após implementar o VPS do RStudio via Docker na DigitalOcean como indicado acima, será necessário instalar o pacote `tcmbadespesas`por meio do comando:
`devtools::install_github("georgevbsantiago/tcmbadespesas")` . Após concluída a instalção, basta executar o código demonstado acima.

------------------ Pré-Configuração do Container Docker do Rstudio na Digital Ocean ------------------

```{r eval=FALSE, include=FALSE}

#cloud-config
runcmd:

docker run -d -t -p 8787:8787 --name=web_scraping_ossaj -e ROOT=TRUE -e PASSWORD=senhadoUsuario -v /home/rstudio/os_saj_web_scraping:/home/rstudio/os_saj_web_scraping rocker/tidyverse
  
sudo chgrp -R rstudio /home/rstudio/os_saj_web_scraping

sudo chmod -R 770 /home/rstudio/os_saj_web_scraping

```
_________________________________________________________________________________________________________

#------------------ Configuração do Container Docker do Rstudio no Shell do Linux ------------------

```{r eval=FALSE, include=FALSE}


# Implantar um container com pasta Volume (3 etapas):

docker run -d -t -p 8787:8787 --name=web_scraping_ossaj -e ROOT=TRUE -e PASSWORD=senhadoUsuario -v /home/rstudio/os_saj_web_scraping:/home/rstudio/os_saj_web_scraping rocker/tidyverse

docker exec -d web_scraping_ossaj sudo chgrp -R rstudio /home/rstudio/os_saj_web_scraping

docker exec -d web_scraping_ossaj sudo chmod -R 770 /home/rstudio/os_saj_web_scraping

```


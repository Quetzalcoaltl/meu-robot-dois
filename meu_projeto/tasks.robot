*** Settings ***
Documentation       Template robot main suite.
Library        RPA.Browser.Selenium
Library        RPA.HTTP
Library        RPA.Tables
Library        String
Library        XML
Library        OperatingSystem



*** Variables ***
${global_quantidade_pdfs_downloads_por_pesquisa}    2
${global_caminho_origem_csv_entrada}    C:\\Users\\victo\\Downloads\\LOCALIDADES.csv
${global_caminho_download_padrao}    C:\\Users\\victo\\Downloads
${global_caminho_download_destino}    C:\\Users\\victo\\Downloads\\ArquivosPrime

#uma boa pratica seria colocar esse dicionario em json local ao projeto ou utilizar uma api
&{dicionario_estados}    AC=ACRE    AL=ALAGOAS    AP=AMAPA    AM=AMAZONAS
    ...    BA=BAHIA    CE=CEARA    DF=DISTRITO FEDERAL    ES=ESPIRITO SANTO
    ...    GO=GOIAS    MA=MARANHAO    MT=MATO GROSSO    MS=MATO GROSSO DO SUL
    ...    MG=MINAS GERAIS    PA=PARA    PB=PARAIBA    PR=PARANA    PE=PERNAMBUCO
    ...    PI=PIAUI    RJ=RIO DE JANEIRO    RN=RIO GRANDE DO NORTE
    ...    RS=RIO GRANDE DO SUL    RO=RONDONIA    RR=RORAIMA    SC=SANTA CATARINA
    ...    SP=SAO PAULO    SE=SERGIPE    TO=TOCANTINS 
*** Tasks ***
Complete the challenge
    Open Available Browser    https://cnes.datasus.gov.br/pages/estabelecimentos/consulta.jsp    alias=BrowserPrincipal
    Maximize Browser Window
    Main loop
    


*** Keywords ***
Main loop
   #[Arguments]    ${browser_name_global}
    ${tabela} =  Abertura de Arquivo CSV    ${global_caminho_origem_csv_entrada}
    
    ${num_linhas}    Evaluate    len($tabela)
    FOR    ${linha}    IN RANGE     ${num_linhas}
        ${uf}  RPA.Tables.Get table cell    ${tabela}    ${linha}    UF
        ${municipio}    RPA.Tables.Get table cell    ${tabela}  ${linha}    MUNICIPIO
        #${uf} ${dicionario_estados["${uf}"]}
            # Remover acentos da palavra original
    
        ${municipio_uppercase}    Convert To Upper Case    ${municipio}
        
        # é interessante fazer um validador de palavras acentuadas, utilizando unidecode
        ${elemento_encontrado}    Run Keyword And Return Status     Preenche Valores    ${dicionario_estados["${uf}"]}     ${municipio_uppercase}
        Run Keyword If     ${elemento_encontrado}     
        ...    Run Keyword And Return Status    Trabalha Tabela
    END

Abertura de Arquivo CSV
    # Definir o caminho para o arquivo CSV
    [Arguments]    ${caminho_do_arquivo}    
    # Ler o arquivo CSV usando a biblioteca RPA.Tables
    ${tabela}  Read Table From CSV    ${caminho_do_arquivo}    encoding=utf-8

    RETURN  ${tabela}

Preenche Valores
    [Arguments]    ${uf}    ${municipio}
    # aguarda o elemento estado estar visivel, assim que visivel ele é clicado
    Wait Until Element Is Visible    xpath=//select[@ng-model="Estado"]//option[text()='${uf}']
    Click Element    xpath=//select[@ng-model="Estado"]//option[text()='${uf}']
    
    # aguarda o elemento municipal estar visivel, assim que visivel ele é clicado
    Wait Until Element Is Visible    xpath=//select[@ng-model="Municipio"]//option[text()='${municipio}']
    Click Element    xpath=//select[@ng-model="Municipio"]//option[text()='${municipio}']

    # Clica em pesquisar
    Click Button    Pesquisar

    # uma boa pratica seria verificar se a consulta foi realizada com sucesso

Trabalha Tabela
    
    Wait Until Page Contains Element    xpath://table[@ng-table="tableParams"]
    Sleep    2
    #captura cabeçalho e corpo da tabela respectivamente
    Wait Until Page Contains Element    xpath://table[@ng-table="tableParams"]//tbody
    ${data_corpo}     get text    xpath://table[@ng-table="tableParams"]//tbody
    Wait Until Page Contains Element    xpath://table[@ng-table="tableParams"]//thead
    ${data_cabecalho}    get text    xpath://table[@ng-table="tableParams"]//thead
    #captura os codigos cnes das informações da tabela utilizando expressões regulares regex
    ${lista_cnes}    String.Get Regexp Matches    ${data_corpo}    \\d{4,}
    ${quantidade}    Get Length    ${lista_cnes}

    #iterador da tabela
    ${iterador} =    Convert To Integer    1
    
    #captura todos os hrefs da tabela para que eles sejam futuramente navegados
    @{elementos}    Get Web Elements    xpath=//a[@title="Ficha estabelecimento"]
    
    FOR    ${elemento}    IN    @{elementos}
        Remove Files    ${global_caminho_download_padrao}/fichaCompletaEstabelecimento*.pdf
        ${href}    Get Element Attribute    ${elemento}    href
        #abre para cada um dos itens
        ${browser_name}    Open Available Browser    ${href}
        Maximize Browser Window
        Sleep    1
        Wait Until Page Contains Element    xpath://a[@title="Imprimir ficha completa"]//span[@class="glyphicon glyphicon-print"]
        Click Element    xpath://a[@title="Imprimir ficha completa"]//span[@class="glyphicon glyphicon-print"]
        Sleep    1
        Wait Until Page Contains Element    xpath://input[@ng-change="marcarTodos()" and @id="todos"]
        Click Element    xpath://input[@ng-change="marcarTodos()" and @id="todos"]
        
        Click Button    Imprimir
        Sleep    5
        Close Browser 
        
         Move File    ${global_caminho_download_padrao}/fichaCompletaEstabelecimento.pdf    ${global_caminho_download_destino}/${lista_cnes}[${iterador}]
        Switch Browser	    BrowserPrincipal

        ${iterador}    Evaluate     ${iterador} + 1
        Exit For Loop If    ${iterador} > ${global_quantidade_pdfs_downloads_por_pesquisa}

    END


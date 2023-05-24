Requisitos
==========
o processo foi totalmente desenvolvido sem dependencias extras, basta seguir o tutorial de instalação no portal: https://robocorp.com/docs/courses/beginners-course/set-up-robocorp-lab
=============
Existem algumas variaveis globais que necessitam ser ajustada para que o processo seja operado corretamente, são elas:
  - ${global_quantidade_pdfs_downloads_por_pesquisa}, quantidade de arquivos que serão baixados por consulta, coloquei um numero arbitrario para facilitar os testes  
  - ${global_caminho_origem_csv_entrada}, caminho origem do arquivo csv de entrada com estados e municipios
  - ${global_caminho_download_padrao}, diretorio padrão de download
  - ${global_caminho_download_destino}, diretorio destino do arquivo que será renomeado e movido    
================
- existem alguns pontos de melhorias que foram comentados no codigo, com o intuito de entregar um projeto para feedback o mais rapido o possivel que atenda as especificações elas foram comentadas e seriam corrigidas em uma proxima rodada de homologação
- o projeto foi chamdo de meu-robot-dois pois foi o segundo que desenvolvi, não existe criterio para a nomeação
- qualquer duvida estou disponivel para esclarecimento a respeito das decisões
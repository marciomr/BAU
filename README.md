#BAU

Bibliotecas Autonomas Unificadas (BAU) é um site catalogação e busca de livros de bilbiotecas autônomas (https://bau.sarava.org). O código do site é livre sob licença GPL 3 e está disponível em https://github.com/marciomr/BAU

![BAU](https://github.com/marciomr/BAU/blob/master/public/imagens/BAU.png?raw=true)

##Features

As features incluem: formulário detalhado, auto-preenchimento, busca simples e avançada, gerenciamento de backups, contas de usuários (bibliotecas) entre outros.

###Formulário Detalhado

* ISBN
* Título
* Sub-título
* Volume
* Editora
* Ano
* Língua
* Páginas
* Assunto
* Cidade
* País
* CDD
* Autores
* Palavras Chave
* Link para versão PDF do livro
* Link para imagem da capa
* Descrição

### Auto-preenchimento

Caso o ISBN do livro seja encontrado no [google books](http://books.google.com) ou em alguma outra biblioteca cadastrada o formulário será preenchido automaticamente com os dados extraídos desses meios.

![auto fill](https://github.com/marciomr/BAU/blob/master/public/imagens/auto_fill.png?raw=true)


### Auto-completamento

Ao preencher determinados campos (Autor, Editora etc.) são sugeridas formas de completá-lo dinamicamente.

![auto complete](https://github.com/marciomr/BAU/blob/master/public/imagens/auto_complete.png?raw=true)

### Busca Simples e Avançada

Busque por livros através de uma busca simples:

![busca simples](https://github.com/marciomr/BAU/blob/master/public/imagens/busca_simples.png?raw=true)

ou usando uma busca avançada.

![busca avançada](https://github.com/marciomr/BAU/blob/master/public/imagens/busca_avancada.png?raw=true)

### Gerenciamento de Backups do Catálogo

Interface gráfica intuitiva para gerenciar backups do catálogo:

![backups](https://github.com/marciomr/BAU/blob/master/public/imagens/backups.png?raw=true)

### Contas

Cada biblioteca gerencia apenas seus livros através de uma conta protegida por senha. Os usuários podem buscar tanto o catálogo uma específica biblioteca como de todas as bibliotecas cadastradas.

## Deploy

Instale o [sphinx](http://sphinxsearch.com/)

Clone o repositório no servidor:
```shell
git clone https://github.com/marciomr/BAU.git
```

Crie o arquivo BAU/config/database.yml
Exemplo:
```ruby
production:
  adapter: mysql2
  database: database_development
  username: foo
  password: bar
```

Configure o arquivo BAU/config/sphix.yml adicionando a seguinte linha:

```ruby
bin_path: "/home/bau/sphinx-2.0.4-release/src"
```

Instale as dependencias:
```shell
bundle
```

Crie a pasta backups:
```shell
mkdir public/backups
```

Rode as migration:
```shell
RAILS_ENV=production rake db:migrate
```

Inicie o thinking-sphinx:
```shell
rake ts:start
```

Inicie o servidor (isso depende das configurações locais).

## LICENÇA

Copyright (C) 2012  Márcio Moretto Ribeiro

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

# xlsx_ecommerce_ia

Projeto Rails para gerar e validar um dataset analitico de e-commerce em XLSX, com massa de dados realista, queries de negocio e documentacao para uso por agentes RAG/XLSX.

## Stack

- Ruby `3.3.10`
- Rails `8.1.3`
- SQLite em desenvolvimento, teste e producao local/Kamal
- `caxlsx` para exportacao XLSX
- RuboCop Omakase para estilo

## Setup local

```bash
bundle install
bin/rails db:prepare
bin/rails db:seed
bin/rails test
```

O seed cria aproximadamente:

- `2200` compras em uma janela analitica de 24 meses
- `180` clientes
- `36` produtos
- reviews, carts e cart_items para validar entidades operacionais

## Dataset XLSX

Gere o arquivo analitico com:

```bash
bin/rails runner "puts XlsxExporter.new.call"
```

Arquivo gerado:

```text
dataset_analitico_mei.xlsx
```

Abas exportadas:

- `Fato Vendas`: granularidade de item de compra
- `Dimensão Produtos`: atributos de produto e margem unitária
- `Dimensão Clientes`: perfil do cliente e receita total

Limites documentados:

- `Review` existe no Rails, mas nao e exportado no XLSX atual
- `Cart` e `CartItem` existem no Rails, mas nao sao exportados no XLSX atual
- `ProductView` nao existe no schema atual; taxa de conversao por visualizacao nao e suportada

Veja [conselhos.md](conselhos.md) para perguntas suportadas e limitacoes.

## Queries de negocio

As queries ficam em `app/queries/`:

- `AverageTicketQuery`
- `ProductRankingQuery`
- `CategoryMarginQuery`
- `MonthlyProfitQuery`
- `TopCustomersQuery`

Exemplo:

```bash
bin/rails runner "pp AverageTicketQuery.new(period: 2.years.ago..Time.current).call.first"
```

## Qualidade

```bash
bin/rails test
RUBOCOP_CACHE_ROOT=tmp/rubocop_cache bin/rubocop
```

Estado validado em 2026-06-29:

```text
27 runs, 106 assertions, 0 failures, 0 errors, 0 skips
58 files inspected, no offenses detected
bin/ci passed
```

## Producao

O projeto inclui Dockerfile e configuracao Kamal em `config/deploy.yml`.

Variaveis de ambiente relevantes:

- `RAILS_MASTER_KEY`
- `DATABASE_PATH`
- `CACHE_DATABASE_PATH`
- `QUEUE_DATABASE_PATH`
- `CABLE_DATABASE_PATH`

Por padrao, os bancos SQLite de producao ficam em `storage/`, que deve ser montado como volume persistente.

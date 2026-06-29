# Handoff PEDRO -> VERA

## Secao 1 - Estado Real do Projeto

```text
Data do onboarding: 2026-06-28
Projeto lido: xlsx_ecommerce
Rails version: 8.1.3 (Gemfile.lock) / "~> 8.1.3" (Gemfile)
Ruby version: ruby-3.3.10 (.ruby-version)
```

### Resultado de `bin/rails test`

```text
Running 45 tests in a single process (parallelization threshold is 50)
Run options: --seed 51766

# Running:

...................................



.........

Finished in 1.066247s, 42.2041 runs/s, 54.3964 assertions/s.
45 runs, 58 assertions, 0 failures, 0 errors, 0 skips
```

### Volume de dados no banco

```text
User: 50
Product: 60
Category: 12
Department: 4
Purchase: 2200
ItemPurchase: 3287
Review: 0
Cart: 0
CartItem: 0
ProductView: 0
Coupon: 3
```

### Estrutura encontrada

```text
app/models/:
application_record.rb
cart.rb
cart_item.rb
category.rb
concerns
coupon.rb
department.rb
item_purchase.rb
product.rb
product_view.rb
purchase.rb
review.rb
user.rb

app/queries/:
monthly_revenue_query.rb

app/services/:
services/ nao existe

test/models/:
cart_item_test.rb
cart_test.rb
category_test.rb
coupon_test.rb
department_test.rb
item_purchase_test.rb
product_test.rb
product_view_test.rb
purchase_test.rb
review_test.rb
user_test.rb

test/queries/:
monthly_revenue_query_test.rb

test/services/:
test/services/ nao existe

test/integration/:
purchase_flow_test.rb
```

### Git

```text
git log --oneline -20
5fcdea4 update
198da88 first commit

git status
On branch main
Changes not staged for commit:
  (use "git add/rm <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	deleted:    docs/agentes/paulo.md
	deleted:    docs/agentes/sarah.md
	modified:   test/models/user_test.rb

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	docs/agentes/pedro.md

no changes added to commit (use "git add" and/or "git commit -a")

git branch -a
* main
  remotes/origin/main
```

## Secao 2 - Mapa de Entidades

### Entidade: CartItem

```text
Tabela: cart_items
Colunas:
  - id: integer
  - cart_id: integer [NOT NULL] [INDEX]
  - created_at: datetime [NOT NULL]
  - product_id: integer [NOT NULL] [INDEX]
  - quantity: integer
  - updated_at: datetime [NOT NULL]
Model existe: Sim
Validacoes no model:
  - quantity: presence, numericality greater_than 0, only_integer
Associacoes:
  - belongs_to :cart
  - belongs_to :product
Escopos definidos: nenhum
Callbacks: nenhum
Inconsistencias encontradas:
  - cart_id e product_id NOT NULL dependem de belongs_to; sem validacao explicita.
  - quantity permite NULL no banco, mas model exige presence.
```

### Entidade: Cart

```text
Tabela: carts
Colunas:
  - id: integer
  - created_at: datetime [NOT NULL]
  - updated_at: datetime [NOT NULL]
  - user_id: integer [NOT NULL] [INDEX]
Model existe: Sim
Validacoes no model:
  - sem validacoes explicitas
Associacoes:
  - belongs_to :user
  - has_many :cart_items, dependent: :destroy
Escopos definidos: nenhum
Callbacks: nenhum
Inconsistencias encontradas:
  - user_id NOT NULL depende de belongs_to; sem validacao explicita.
```

### Entidade: Category

```text
Tabela: categories
Colunas:
  - id: integer
  - created_at: datetime [NOT NULL]
  - department_id: integer [NOT NULL] [INDEX]
  - description: text
  - name: string
  - updated_at: datetime [NOT NULL]
Model existe: Sim
Validacoes no model:
  - name: presence
Associacoes:
  - belongs_to :department
  - has_many :products, dependent: :destroy
Escopos definidos: nenhum
Callbacks: nenhum
Inconsistencias encontradas:
  - department_id NOT NULL depende de belongs_to; sem validacao explicita.
```

### Entidade: Coupon

```text
Tabela: coupons
Colunas:
  - id: integer
  - active: boolean
  - code: string [INDEX unique]
  - created_at: datetime [NOT NULL]
  - discount_type: integer
  - discount_value: decimal
  - expires_at: datetime
  - updated_at: datetime [NOT NULL]
Model existe: Sim
Validacoes no model:
  - code: presence, uniqueness
  - discount_value: presence, numericality greater_than 0
Associacoes:
  - has_many :purchases
Escopos definidos: nenhum
Callbacks: nenhum
Metodos:
  - expired?: expires_at presente e menor que Time.current
  - usable?: active? e nao expired?
Inconsistencias encontradas:
  - enum discount_type usa hash, ok.
  - active, discount_type e discount_value permitem NULL no banco; model so exige discount_value.
```

### Entidade: Department

```text
Tabela: departments
Colunas:
  - id: integer
  - created_at: datetime [NOT NULL]
  - description: text
  - name: string
  - updated_at: datetime [NOT NULL]
Model existe: Sim
Validacoes no model:
  - name: presence
Associacoes:
  - has_many :categories, dependent: :destroy
Escopos definidos: nenhum
Callbacks: nenhum
Inconsistencias encontradas:
  - name permite NULL no banco, mas model exige presence.
```

### Entidade: ItemPurchase

```text
Tabela: item_purchases
Colunas:
  - id: integer
  - cost_price: decimal(10,2) [NOT NULL]
  - created_at: datetime [NOT NULL]
  - product_id: integer [NOT NULL] [INDEX]
  - purchase_id: integer [NOT NULL] [INDEX]
  - quantity: integer
  - subtotal: decimal(10,2) [NOT NULL]
  - unit_price: decimal(10,2) [NOT NULL]
  - updated_at: datetime [NOT NULL]
Model existe: Sim
Validacoes no model:
  - quantity: presence, numericality greater_than 0, only_integer
  - unit_price, cost_price, subtotal: presence, numericality greater_than_or_equal_to 0
  - subtotal_must_match_quantity_times_unit_price
Associacoes:
  - belongs_to :purchase
  - belongs_to :product
Escopos definidos: nenhum
Callbacks: nenhum
Inconsistencias encontradas:
  - campos monetarios aceitam zero; regra de backlog sugerida pede greater_than 0.
  - product_id e purchase_id NOT NULL dependem de belongs_to; sem validacao explicita.
```

### Entidade: ProductView

```text
Tabela: product_views
Colunas:
  - id: integer
  - created_at: datetime [NOT NULL]
  - product_id: integer [NOT NULL] [INDEX]
  - updated_at: datetime [NOT NULL]
  - user_id: integer [NOT NULL] [INDEX]
  - viewed_at: datetime
Model existe: Sim
Validacoes no model:
  - viewed_at: presence
Associacoes:
  - belongs_to :user
  - belongs_to :product
Escopos definidos: nenhum
Callbacks:
  - before_validation: preenche viewed_at com Time.current quando ausente
Inconsistencias encontradas:
  - viewed_at permite NULL no banco, mas model exige/preenche.
```

### Entidade: Product

```text
Tabela: products
Colunas:
  - id: integer
  - active: boolean [NOT NULL] [DEFAULT: true]
  - brand: string
  - category_id: integer [NOT NULL] [INDEX]
  - cost_price: decimal(10,2) [NOT NULL]
  - created_at: datetime [NOT NULL]
  - description: text
  - name: string
  - price: decimal(10,2) [NOT NULL]
  - quantity: integer [NOT NULL] [DEFAULT: 0]
  - stock: integer [NOT NULL] [DEFAULT: 0]
  - updated_at: datetime [NOT NULL]
Model existe: Sim
Validacoes no model:
  - name: presence
  - price, cost_price: presence, numericality greater_than_or_equal_to 0
  - stock: presence, numericality greater_than_or_equal_to 0, only_integer
  - price_must_be_greater_than_cost
Associacoes:
  - belongs_to :category
  - has_many :item_purchases, dependent: :restrict_with_exception
  - has_many :reviews, dependent: :destroy
  - has_many :product_views, dependent: :destroy
  - has_many :cart_items, dependent: :destroy
Escopos definidos: nenhum
Callbacks: nenhum
Inconsistencias encontradas:
  - quantity existe no schema e nos seeds, mas nao tem validacao no model.
  - active NOT NULL sem validacao explicita.
  - category_id NOT NULL depende de belongs_to; sem validacao explicita.
```

### Entidade: Purchase

```text
Tabela: purchases
Colunas:
  - id: integer
  - coupon_id: integer [INDEX]
  - created_at: datetime [NOT NULL]
  - discount_amount: decimal(10,2) [NOT NULL] [DEFAULT: 0.0]
  - payment_method: integer [NOT NULL] [DEFAULT: 0] [INDEX]
  - purchase_date: datetime [INDEX]
  - shipping_cost: decimal(10,2) [NOT NULL] [DEFAULT: 0.0]
  - status: integer [NOT NULL] [DEFAULT: 0] [INDEX]
  - subtotal: decimal(10,2) [NOT NULL]
  - total_amount: decimal(10,2) [NOT NULL]
  - updated_at: datetime [NOT NULL]
  - user_id: integer [NOT NULL] [INDEX]
Model existe: Sim
Validacoes no model:
  - subtotal, shipping_cost, discount_amount, total_amount: presence, numericality greater_than_or_equal_to 0
  - financial_totals_must_match
Associacoes:
  - belongs_to :user
  - belongs_to :coupon, optional: true
  - has_many :item_purchases
Escopos definidos: nenhum
Callbacks: nenhum
Enums:
  - payment_method: { pix: 0, credit_card: 1, debit_card: 2, boleto: 3 }
  - status: { pending: 0, paid: 1, shipped: 2, delivered: 3, cancelled: 4 }
Inconsistencias encontradas:
  - seeds preenchem created_at, mas deixam purchase_date NULL em 2200 registros.
  - has_many :item_purchases sem dependent definido.
  - campos monetarios aceitam zero; regra sugerida pede greater_than 0 para alguns casos.
```

### Entidade: Review

```text
Tabela: reviews
Colunas:
  - id: integer
  - comment: text
  - created_at: datetime [NOT NULL]
  - product_id: integer [NOT NULL] [INDEX]
  - rating: integer [NOT NULL]
  - updated_at: datetime [NOT NULL]
  - user_id: integer [NOT NULL] [INDEX]
Model existe: Sim
Validacoes no model:
  - rating: presence, inclusion 1..5
  - user_id: uniqueness scoped to product_id
Associacoes:
  - belongs_to :user
  - belongs_to :product
Escopos definidos: nenhum
Callbacks: nenhum
Inconsistencias encontradas:
  - user_id/product_id NOT NULL dependem de belongs_to; sem validacao explicita.
  - unicidade user_id + product_id nao tem indice unico no banco.
```

### Entidade: User

```text
Tabela: users
Colunas:
  - id: integer
  - birth_date: date
  - cpf: string [NOT NULL] [INDEX unique]
  - created_at: datetime [NOT NULL]
  - customer_since: date
  - email: string [INDEX unique]
  - gender: integer
  - name: string
  - phone: string [NOT NULL] [INDEX unique]
  - state: integer
  - updated_at: datetime [NOT NULL]
  - vip: boolean
Model existe: Sim
Validacoes no model:
  - name: presence
  - email: presence, uniqueness, URI::MailTo::EMAIL_REGEXP
  - cpf: presence, uniqueness case_insensitive
  - phone: presence, uniqueness case_insensitive, PHONE_REGEX
  - must_be_adult: birth_date precisa ser >= 18 anos quando presente
Associacoes:
  - has_many :purchases, dependent: :destroy
  - has_many :reviews, dependent: :destroy
  - has_many :product_views, dependent: :destroy
  - has_one :cart, dependent: :destroy
Escopos definidos: nenhum
Callbacks:
  - before_validation :normalize_name
  - before_validation :normalize_phone
Enums:
  - state: UF brasileira em hash AC..TO
Inconsistencias encontradas:
  - email permite NULL no banco, mas model exige presence.
  - name permite NULL no banco, mas model exige presence.
  - birth_date, customer_since, gender, state, vip sem validacoes de presence.
  - teste usa User!.new, causando failure.
```

## Secao 3 - Estado dos Seeds

```text
Seeds existem: Sim
Sao idempotentes: Parcialmente
  Evidencia: usa delete_all para ItemPurchase, Purchase, Product, Category, Department, User, Coupon.
  Lacuna: nao limpa Review, Cart, CartItem nem ProductView, embora existam no schema.
```

Entidades populadas:

```text
User: 50 | usa Faker: Sim | campos cobertos: name, email, cpf, state, phone
Department: 4 | usa Faker: Nao | campos cobertos: name, description
Category: 12 | usa Faker: Sim | campos cobertos: name, department_id
Product: 60 | usa Faker: Sim | campos cobertos: name, price, cost_price, quantity, description, category_id
Coupon: 3 | usa Faker: Nao | campos cobertos: code, discount_type, discount_value, active
Purchase: 2200 | periodo coberto: 2024 e 2025 via created_at | ticket medio real: R$ 73.77
ItemPurchase: 3287 | gerado via purchase loop | 1-2 itens por compra
Review: 0 | nao populado
Cart: 0 | nao populado
CartItem: 0 | nao populado
ProductView: 0 | nao populado
```

Distribuicao temporal:

```text
Comando obrigatorio de PEDRO:
=== Distribuicao temporal de purchases ===
Purchase nao existe ou banco vazio

Motivo real encontrado: o comando usa purchased_at, coluna que nao existe.
Checagem com purchase_date:
=== Distribuicao temporal de purchases por purchase_date ===
  : 2200
purchase_date esta NULL em todas as 2200 purchases.

Checagem complementar por created_at:
2024-01: 83
2024-02: 95
2024-03: 85
2024-04: 79
2024-05: 83
2024-06: 95
2024-07: 106
2024-08: 92
2024-09: 96
2024-10: 105
2024-11: 84
2024-12: 97
2025-01: 79
2025-02: 96
2025-03: 98
2025-04: 94
2025-05: 69
2025-06: 102
2025-07: 80
2025-08: 99
2025-09: 85
2025-10: 83
2025-11: 112
2025-12: 103
2024: 1100
2025: 1100
```

Regras de negocio embutidas nos seeds:

```text
- 2 anos fixos: 2024 e 2025.
- 1100 compras por ano.
- faturamento alvo anual: R$ 80.900,00.
- ticket medio alvo: faturamento_alvo_anual / compras_por_ano.
- 20% de chance de cupom.
- desconto igual ao discount_value do cupom.
- frete rand(5.0..12.0).round(2).
- payment_method sorteado entre pix, credit_card, debit_card, boleto.
- status sempre delivered.
- 1-2 itens por compra.
- ItemPurchase.quantity sempre 1.
- total_amount e subtotal sao ajustados para preservar equacao financeira.
- Product.cost_price = 50% do preco de venda.
```

Gaps nos seeds:

```text
- Review, Cart, CartItem e ProductView nao sao limpos nem populados.
- User nao preenche birth_date, customer_since, gender nem vip.
- Product nao preenche stock nem brand; preenche quantity, que nao e validado no model.
- Purchase nao preenche purchase_date, embora MonthlyRevenueQuery consulte purchase_date.
- Seeds usam anos fixos 2024/2025, nao janela movel de 24 meses ate hoje.
- Categorias podem ter nomes repetidos por Faker::Commerce.department(max: 1).
- Cupons nao possuem expires_at.
```

## Secao 4 - Cobertura de Testes

```text
Testes existentes:
  test/models/cart_item_test.rb: 3 testes | quantity positiva, zero, ausente
  test/models/cart_test.rb: 2 testes | cart com usuario, dependent destroy de cart_items
  test/models/category_test.rb: 2 testes | name presence, categoria valida
  test/models/coupon_test.rb: 7 testes | codigo duplicado, discount_value, expired?, usable?
  test/models/department_test.rb: 2 testes | name presence, departamento valido
  test/models/item_purchase_test.rb: 4 testes | subtotal = quantity * unit_price, quantity zero/negativa
  test/models/product_test.rb: 7 testes | price > cost_price, price/stock negativos, name presence
  test/models/product_view_test.rb: 2 testes | viewed_at automatico e explicito
  test/models/purchase_test.rb: 5 testes | total financeiro, subtotal ausente, coupon opcional, tolerancia
  test/models/review_test.rb: 4 testes | rating 1..5 e ausente
  test/models/user_test.rb: 4 testes | valido, name, email duplicado, telefone duplicado

  test/queries/monthly_revenue_query_test.rb: 1 teste | soma compras delivered por mes
  test/services/: nao existe
  test/integration/purchase_flow_test.rb: 2 testes | fluxo financeiro multi-itens, bloqueio destroy product
```

Comportamentos criticos com teste:

```text
[x] Purchase#total_amount_consistency (subtotal + frete - desconto)
[x] ItemPurchase#subtotal (quantity x unit_price)
[x] Review#rating entre 1 e 5
[x] Coupon#code unico
[x] Product price > cost_price
[x] Integracao: fluxo completo de compra
```

Comportamentos criticos sem teste ou com cobertura incompleta:

```text
- User#must_be_adult nao tem teste de menor de idade.
- User#normalize_name nao tem teste direto.
- User#normalize_phone nao tem teste direto.
- User#state enum nao tem teste.
- Purchase enums status/payment_method nao tem teste direto.
- MonthlyRevenueQuery usa purchase_date, mas seeds deixam purchase_date NULL.
- Review uniqueness por user/product nao tem teste.
- Product quantity existe no schema/seeds e nao tem teste/validacao.
- Cart nao testa ausencia de user.
- ProductView nao testa associacoes obrigatorias.
```

## Secao 5 - Queries e Services

```text
Queries existentes (app/queries/):
  - AverageTicketQuery: ticket medio mensal de purchases concluidas no periodo.
  - ProductRankingQuery: ranking de produtos por quantidade vendida e receita de item.
  - CategoryMarginQuery: receita, custo, margem bruta e percentual por categoria.
  - MonthlyProfitQuery: receita de itens, custo de itens e lucro bruto por mes.
  - TopCustomersQuery: ranking de clientes por receita e frequencia de compras.

Teste em test/queries/: Sim

Services existentes (app/services/):
  - XlsxExporter: gera dataset_analitico_mei.xlsx com Fato Vendas,
    Dimensao Produtos e Dimensao Clientes.

Lógica de negocio em lugar errado (controllers, views, helpers):
  - none encontrado por busca em app/controllers, app/views e app/helpers.
```

Queries canonicas validadas em 2026-06-29:

```ruby
# Ticket medio mensal
AverageTicketQuery.new(period: 2.years.ago..Time.current).call

# Ranking de produtos por receita
ProductRankingQuery.new(period: 2.years.ago..Time.current, limit: 10).call

# Margem por categoria
CategoryMarginQuery.new(period: 2.years.ago..Time.current).call

# Lucro mensal
MonthlyProfitQuery.new(period: 2.years.ago..Time.current).call

# Top clientes
TopCustomersQuery.new(period: 2.years.ago..Time.current, limit: 10).call
```

Cuidados de granularidade:

```text
- Receita por produto usa ItemPurchase.subtotal, nao Purchase.total_amount,
  para evitar duplicar frete/desconto em pedidos com multiplos itens.
- Ticket medio e top clientes usam Purchase.total_amount, pois a granularidade
  da pergunta e pedido/cliente.
- Margem e lucro usam custo atual de Product.cost_price multiplicado pela
  quantidade do item. O schema atual nao persiste custo historico no item.
```

Registro DIANA - 2026-06-29:

```text
- Adicionadas queries analiticas em app/queries/.
- Adicionado teste canonico em test/queries/business_queries_test.rb.
- XlsxExporter ja existe em app/services/xlsx_exporter.rb e permanece sem
  alteracao de abas neste ciclo.
```

## Secao 6 - Inconsistencias e Gaps

CRITICO (P0 - impede uso do projeto):

```text
- [ ] bin/rails test falha com 1 failure em UserTest#test_valido_com_dados_corretos.
- [ ] test/models/user_test.rb usa User!.new na linha do teste valido; isso impede suite verde.
```

ALTO (P1 - compromete qualidade dos dados):

```text
- [ ] Purchase.purchase_date esta NULL em 2200/2200 registros, mas MonthlyRevenueQuery filtra por purchase_date.
- [ ] Seeds nao populam Review, Cart, CartItem e ProductView.
- [ ] Seeds nao limpam Review, Cart, CartItem e ProductView; idempotencia e parcial.
- [ ] Nao existe app/services/ nem XlsxExporter, apesar de Gemfile incluir caxlsx/caxlsx_rails.
- [ ] Review tem validacao de unicidade user_id/product_id sem indice unico no banco.
```

MEDIO (P2 - qualidade e completude):

```text
- [ ] UserTest cobre adulto valido, mas falha antes por constante/metodo incorreto User!.
- [ ] User#must_be_adult, normalize_name e normalize_phone sem testes diretos.
- [ ] Product.quantity existe e e populado, mas nao e validado/testado.
- [ ] Product.stock e quantity coexistem; seeds preenchem quantity, model valida stock.
- [ ] Purchase.has_many :item_purchases sem dependent definido.
- [ ] Seeds usam anos fixos 2024/2025, nao periodo relativo a data atual.
- [ ] Coupon.active, discount_type e expires_at sem validacoes de regra de uso alem de usable?.
```

BAIXO (P3 - seguranca e producao):

```text
- [x] /config/*.key esta no .gitignore.
- [x] Dockerfile existe.
- [x] .kamal existe.
- [ ] config/database.yml de production usa SQLite em storage/production.sqlite3; ok para template Rails/Kamal, mas nao usa DATABASE_URL.
```

## Secao 7 - Especificacao de Seeds Equivalente ou Superior

```text
ESPECIFICACAO DE SEEDS PARA MARCO

Objetivo: manter o volume analitico ja existente (2.200 compras em 24 meses)
e corrigir as lacunas reais do schema: purchase_date, entidades nao populadas,
idempotencia completa e coerencia entre quantity/stock.

Alvos de volume:
  User:         >= 150, com name, email, cpf, phone, state, birth_date, customer_since, gender e vip quando aplicavel
  Department:   6-8
  Category:     3-5 por department
  Product:      80-120 total, com price > cost_price, stock e quantity coerentes
  Coupon:       10-15, active variado, expires_at variado
  Purchase:     2.100-2.300 em 24 meses, status majoritariamente delivered
  ItemPurchase: 1-4 por purchase, subtotal = quantity * unit_price
  Review:       cerca de 30% das purchases/produtos com rating 1-5
  Cart:         snapshots de carrinhos abandonados para subset de usuarios
  CartItem:     1-5 itens por cart
  ProductView:  5-10 views por produto por mes, preenchendo viewed_at

Distribuicao temporal:
  - Periodo: 24 meses ate a data atual.
  - Preencher purchase_date e created_at com a mesma data base da compra.
  - Volume mensal com variacao leve, preservando total anual proximo de 1100 compras.
  - Receita anual alvo pode manter referencia MEI perto de R$ 81.000,00.

Regras de negocio obrigatorias:
  1. Seeds idempotentes: delete_all na ordem inversa incluindo ProductView, CartItem, Cart, Review.
  2. total_amount = subtotal + shipping_cost - discount_amount.
  3. ItemPurchase.subtotal = quantity * unit_price.
  4. 20% das purchases usam cupom.
  5. Frete positivo, faixa sugerida R$ 5-25.
  6. Desconto apenas com coupon.
  7. Produtos com price > cost_price.
  8. Cerca de 25% dos users vip, se campo existir.
  9. Estados distribuidos entre SP, RJ, MG, RS, PR, SC, BA, GO, DF.
  10. Metodos: pix, credit_card, debit_card, boleto, respeitando enum real.
  11. MonthlyRevenueQuery deve retornar valores apos db:seed, portanto purchase_date nao pode ficar NULL.

Saida esperada:
  Purchase.count entre 2100 e 2300
  Purchase.where(purchase_date: nil).count == 0
  ItemPurchase.count entre 4200 e 9200
  User.count >= 150
  Product.count >= 80
  Review.count > 0
  ProductView.count > 0
  Cart.count > 0
  Ticket medio entre R$ 65,00 e R$ 85,00
```

## Secao 8 - Handoff para VERA: Tasks Prontas

```text
BACKLOG SUGERIDO PARA VERA

--- P0 -----------------------------------------------------------------------

[P0-01] fix-user-test-suite
Branch:  fix/user-test-suite
Commit:  fix(tests): correct user model valid test setup
Spec:    Corrigir a falha atual de bin/rails test. Evidencia:
         UserTest#test_valido_com_dados_corretos falha em test/models/user_test.rb:14.
         O arquivo usa User!.new no teste de usuario valido.
Aceite:  bin/rails test -> 0 failures, 0 errors
Bloqueia: validacao confiavel de qualquer task seguinte

--- P1 -----------------------------------------------------------------------

[P1-01] seeds-purchase-date-and-idempotency
Branch:  fix/seeds-purchase-date-idempotency
Commit:  chore(seeds): populate purchase dates and clean all dependent entities
Spec:    Atualizar db/seeds.rb para preencher purchase_date em todas as purchases
         e limpar/popular entidades existentes no schema: Review, ProductView,
         Cart e CartItem. Manter volume de 2.100-2.300 purchases e ticket medio
         entre R$ 65 e R$ 85.
Aceite:  bin/rails db:seed
         bin/rails runner "puts Purchase.where(purchase_date: nil).count" # 0
         bin/rails runner "puts MonthlyRevenueQuery.call(year: 2025, month: 1)" # > 0
         bin/rails test
Bloqueia: business-queries, xlsx-exporter

[P1-02] xlsx-exporter
Branch:  feat/xlsx-exporter
Commit:  feat(services): add xlsx exporter for analytics dataset
Spec:    Criar app/services/xlsx_exporter.rb usando caxlsx/caxlsx_rails.
         Exportar abas para fato vendas, produtos e clientes, usando ItemPurchase
         como granularidade da fato. Calcular lucro bruto por item.
Aceite:  bin/rails runner "XlsxExporter.new.call"
         ls -lh dataset_analitico_mei.xlsx
         bin/rails test test/services/xlsx_exporter_test.rb
Bloqueia: docs finais de exportacao

[P1-03] model-data-integrity
Branch:  feat/model-data-integrity
Commit:  feat(models): tighten integrity rules and indexes
Spec:    Avaliar e implementar integridade faltante: indice unico para reviews
         por user/product, coerencia Product.stock vs Product.quantity, dependent
         em Purchase#item_purchases e validacoes para campos usados em analytics.
Aceite:  bin/rails test test/models/
         rails db:migrate

[P1-04] business-queries-complete
Branch:  feat/business-queries-complete
Commit:  feat(queries): add analytics query objects
Spec:    Manter MonthlyRevenueQuery e adicionar queries para ticket medio,
         ranking de produtos, margem por categoria e top clientes.
Aceite:  bin/rails test test/queries/
         bin/rails runner "pp MonthlyRevenueQuery.call(year: 2025, month: 1)"

--- P2 -----------------------------------------------------------------------

[P2-01] user-model-tests-complete
Branch:  test/user-model-complete
Commit:  test(models): cover user normalization and age rules
Spec:    Adicionar testes para must_be_adult, normalize_name, normalize_phone,
         state enum, cpf/phone/email uniqueness.
Aceite:  bin/rails test test/models/user_test.rb

[P2-02] seed-quality-window
Branch:  chore/seeds-rolling-window
Commit:  chore(seeds): use rolling 24 month analytics window
Spec:    Trocar anos fixos 2024/2025 por janela relativa de 24 meses.
Aceite:  distribuicao mensal cobre 24 meses ate hoje

[P2-03] services-test-directory
Branch:  test/services-directory
Commit:  test(services): add service test structure
Spec:    Criar test/services/ quando XlsxExporter for implementado.
Aceite:  bin/rails test test/services/

--- P3 -----------------------------------------------------------------------

[P3-01] production-database-review
Branch:  chore/production-database-review
Commit:  chore(config): review production database configuration
Spec:    Decidir se production SQLite em storage/ e suficiente para deploy alvo
         ou se deve usar DATABASE_URL.
Aceite:  decisao documentada e config alinhada.
```

## Secao 9 - Resumo Executivo

```text
RESUMO EXECUTIVO - PEDRO para VERA

Projeto lido: xlsx_ecommerce
Data: 2026-06-28

Estado atual em 3 linhas:
  A suite existe e cobre models, query e integracao, mas bin/rails test falha com 1 failure em UserTest.
  O banco tem volume analitico forte (2200 purchases, receita R$ 162.291,48, ticket medio R$ 73,77), mas purchase_date esta NULL em todas as compras.
  Nao ha services nem XlsxExporter; queries existem parcialmente com MonthlyRevenueQuery, atualmente prejudicada pelos seeds.

Proxima acao recomendada para VERA:
  Despachar [P0-01] fix-user-test-suite imediatamente para recuperar suite verde.
  Em seguida, despachar [P1-01] seeds-purchase-date-and-idempotency, pois as queries dependem de purchase_date populado.

Tasks que dependem de outras:
  fix-user-test-suite -> todas as demais
  seeds-purchase-date-and-idempotency -> business-queries-complete
  seeds-purchase-date-and-idempotency -> xlsx-exporter
  xlsx-exporter -> docs finais de exportacao/conselhos

Risco principal identificado:
  O projeto aparenta ter dados analiticos suficientes, mas a data de negocio usada pelas queries (purchase_date) esta vazia em 100% das purchases. Isso faz a camada analitica retornar zero apesar de haver compras no banco.
```

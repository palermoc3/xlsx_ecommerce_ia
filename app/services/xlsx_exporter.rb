require "caxlsx"

class XlsxExporter
  OUTPUT_PATH = Rails.root.join("dataset_analitico_mei.xlsx")

  FATO_VENDAS_HEADER = [
    "ID Venda",
    "Data Compra",
    "Ano",
    "Mes",
    "Dia",
    "Hora",
    "ID Cliente",
    "Estado Cliente",
    "Metodo Pagamento",
    "Status Venda",
    "Cupom Utilizado",
    "Desconto Cupom (R$)",
    "Frete (R$)",
    "Total do Pedido (R$)",
    "Produto",
    "Categoria",
    "Departamento",
    "Preco Unitario Venda (R$)",
    "Preco Unitario Custo (R$)",
    "Quantidade Item",
    "Subtotal Item (R$)",
    "Lucro Bruto Item (R$)"
  ].freeze

  DIMENSAO_PRODUTOS_HEADER = [
    "ID Produto",
    "Produto",
    "Categoria",
    "Departamento",
    "Preco Venda (R$)",
    "Preco Custo (R$)",
    "Margem Bruta Unit (R$)",
    "Estoque",
    "Ativo"
  ].freeze

  DIMENSAO_CLIENTES_HEADER = [
    "ID Cliente",
    "Nome Cliente",
    "Email",
    "Estado",
    "Cidade",
    "Data Nascimento",
    "Idade",
    "Total Pedidos",
    "Receita Total (R$)"
  ].freeze

  def initialize(scope: Purchase.completed, output_path: OUTPUT_PATH)
    @scope = scope
    @output_path = Pathname(output_path)
  end

  def call
    package = Axlsx::Package.new
    workbook = package.workbook
    styles = workbook.styles
    header_style = styles.add_style(b: true, bg_color: "1F2937", fg_color: "FFFFFF")

    build_fato_vendas(workbook, header_style)
    build_dimensao_produtos(workbook, header_style)
    build_dimensao_clientes(workbook, header_style)

    FileUtils.mkdir_p(output_path.dirname)
    package.serialize(output_path.to_s)
    output_path
  end

  private
    attr_reader :scope, :output_path

    def build_fato_vendas(workbook, header_style)
      workbook.add_worksheet(name: "Fato Vendas") do |sheet|
        sheet.add_row FATO_VENDAS_HEADER, style: header_style
        item_purchases.find_each { |item_purchase| sheet.add_row fato_vendas_row(item_purchase) }
      end
    end

    def build_dimensao_produtos(workbook, header_style)
      workbook.add_worksheet(name: "Dimensão Produtos") do |sheet|
        sheet.add_row DIMENSAO_PRODUTOS_HEADER, style: header_style
        products.find_each { |product| sheet.add_row dimensao_produtos_row(product) }
      end
    end

    def build_dimensao_clientes(workbook, header_style)
      workbook.add_worksheet(name: "Dimensão Clientes") do |sheet|
        sheet.add_row DIMENSAO_CLIENTES_HEADER, style: header_style
        users.find_each { |user| sheet.add_row dimensao_clientes_row(user) }
      end
    end

    def item_purchases
      ItemPurchase
        .includes(:product, purchase: :user)
        .where(purchase_id: scope.select(:id))
        .order(:purchase_id, :id)
    end

    def products
      Product.where(id: item_purchases.select(:product_id)).order(:id)
    end

    def users
      User.where(id: scope.select(:user_id)).order(:id)
    end

    def fato_vendas_row(item_purchase)
      purchase = item_purchase.purchase
      product = item_purchase.product
      purchased_at = purchase.purchase_date

      [
        purchase.id,
        purchased_at.iso8601,
        purchased_at.year,
        purchased_at.month,
        purchased_at.day,
        purchased_at.hour,
        purchase.user_id,
        purchase.user.state,
        purchase.payment_method,
        purchase.status,
        "NENHUM",
        decimal(purchase.discount_amount),
        decimal(purchase.shipping_cost),
        decimal(purchase.total_amount),
        product.name,
        product.category,
        product.category,
        decimal(item_purchase.unit_price),
        decimal(product.cost_price),
        item_purchase.quantity,
        decimal(item_purchase.subtotal),
        gross_profit(item_purchase, product)
      ]
    end

    def dimensao_produtos_row(product)
      [
        product.id,
        product.name,
        product.category,
        product.category,
        decimal(product.price),
        decimal(product.cost_price),
        decimal(product.price - product.cost_price),
        product.stock,
        product.active? ? "Sim" : "Nao"
      ]
    end

    def dimensao_clientes_row(user)
      user_scope = scope.where(user_id: user.id)

      [
        user.id,
        user.name,
        user.email,
        user.state,
        user.city,
        user.birth_date.iso8601,
        age_for(user),
        user_scope.count,
        decimal(user_scope.sum(:total_amount))
      ]
    end

    def gross_profit(item_purchase, product)
      decimal((item_purchase.unit_price - product.cost_price) * item_purchase.quantity)
    end

    def decimal(value)
      BigDecimal(value.to_s).round(2).to_f
    end

    def age_for(user)
      today = Date.current
      age = today.year - user.birth_date.year
      birthday_passed = today.month > user.birth_date.month ||
        (today.month == user.birth_date.month && today.day >= user.birth_date.day)

      birthday_passed ? age : age - 1
    end
end

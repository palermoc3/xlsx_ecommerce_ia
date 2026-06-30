require "test_helper"
require "zip"

class XlsxExporterTest < ActiveSupport::TestCase
  test "generates workbook with expected sheets for completed purchases" do
    user = create_user!
    product = create_product!
    pending_product = create_product!(name: "Produto Pendente")
    completed_purchase = create_purchase!(user: user, status: :paid)
    pending_purchase = create_purchase!(user: user, status: :pending, purchase_date: 1.day.ago)
    review = Review.create!(user: user, product: product, rating: 5, comment: "Otimo produto")
    Coupon.create!(code: "TESTE10", discount_type: :fixed_amount, discount_value: 10)
    cart = Cart.create!(user: user, status: :open)

    create_item_purchase!(purchase: completed_purchase, product: product, quantity: 2)
    create_item_purchase!(purchase: pending_purchase, product: pending_product, quantity: 1)
    CartItem.create!(cart: cart, product: pending_product, quantity: 1, unit_price: pending_product.price, subtotal: pending_product.price)

    output_path = Rails.root.join("tmp", "xlsx_exporter_#{SecureRandom.hex(8)}.xlsx")

    result = XlsxExporter.new(output_path: output_path).call

    assert_equal output_path, result
    assert File.exist?(output_path)
    assert_operator File.size(output_path), :>, 0

    workbook_xml = read_xlsx_entry(output_path, "xl/workbook.xml")
    assert_includes workbook_xml, "Fato Vendas"
    assert_includes workbook_xml, "Dimensão Produtos"
    assert_includes workbook_xml, "Dimensão Clientes"
    assert_includes workbook_xml, "Users"
    assert_includes workbook_xml, "Products"
    assert_includes workbook_xml, "Purchases"
    assert_includes workbook_xml, "Item Purchases"
    assert_includes workbook_xml, "Reviews"
    assert_includes workbook_xml, "Coupons"
    assert_includes workbook_xml, "Carts"
    assert_includes workbook_xml, "Cart Items"

    fato_vendas_xml = read_xlsx_entry(output_path, "xl/worksheets/sheet1.xml")
    assert_includes fato_vendas_xml, "<v>#{completed_purchase.id}</v>"
    assert_not_includes fato_vendas_xml, "Produto Pendente"
    assert_not_includes fato_vendas_xml, "<t>pending</t>"
    assert_includes fato_vendas_xml, "<v>88.8</v>"

    purchases_xml = read_xlsx_entry(output_path, "xl/worksheets/sheet6.xml")
    reviews_xml = read_xlsx_entry(output_path, "xl/worksheets/sheet8.xml")
    assert_includes purchases_xml, "<v>#{pending_purchase.id}</v>"
    assert_includes reviews_xml, "<v>#{review.id}</v>"
  ensure
    FileUtils.rm_f(output_path) if output_path
  end

  private
    def create_purchase!(user:, status:, purchase_date: Time.current)
      Purchase.create!(
        user: user,
        status: status,
        payment_method: :pix,
        purchase_date: purchase_date,
        subtotal: 100,
        shipping_cost: 12,
        discount_amount: 8,
        total_amount: 104
      )
    end

    def create_item_purchase!(purchase:, product:, quantity:)
      ItemPurchase.create!(
        purchase: purchase,
        product: product,
        quantity: quantity,
        unit_price: product.price,
        subtotal: product.price * quantity
      )
    end

    def read_xlsx_entry(path, entry_name)
      Zip::File.open(path.to_s) do |zip_file|
        zip_file.find_entry(entry_name).get_input_stream.read.force_encoding("UTF-8")
      end
    end
end

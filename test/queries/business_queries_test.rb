require "test_helper"

class BusinessQueriesTest < ActiveSupport::TestCase
  setup do
    @period = Time.zone.local(2035, 1, 1)..Time.zone.local(2035, 1, 31, 23, 59, 59)
    @user = create_user!(email: "cliente-principal@example.com")
    @other_user = create_user!(email: "cliente-secundario@example.com")
    @shirt = create_product!(name: "Camiseta Analitica")
    @shoe = create_product!(name: "Tenis Analitico")

    create_purchase_with_item!(
      user: @user,
      product: @shirt,
      status: :paid,
      purchase_date: Time.zone.local(2035, 1, 5, 10),
      quantity: 2,
      unit_price: 80,
      cost_price: 35
    )

    create_purchase_with_item!(
      user: @user,
      product: @shoe,
      status: :shipped,
      purchase_date: Time.zone.local(2035, 1, 10, 12),
      quantity: 1,
      unit_price: 120,
      cost_price: 60
    )

    create_purchase_with_item!(
      user: @other_user,
      product: @shoe,
      status: :pending,
      purchase_date: Time.zone.local(2035, 1, 12, 12),
      quantity: 5,
      unit_price: 120,
      cost_price: 60
    )
  end

  test "average ticket returns monthly completed purchase metrics" do
    result = AverageTicketQuery.new(period: @period).call.first

    assert_equal "2035-01", result.month
    assert_equal 2, result.purchase_count
    assert_equal 280.to_d, result.revenue
    assert_equal 140.0, result.avg_ticket
  end

  test "product ranking orders completed sales by revenue and quantity" do
    result = ProductRankingQuery.new(period: @period, limit: 2).call.to_a

    assert_equal [ @shirt.id, @shoe.id ], result.map(&:product_id)
    assert_equal [ 2, 1 ], result.map(&:quantity_sold)
    assert_equal [ 160.to_d, 120.to_d ], result.map(&:revenue)
  end

  test "category margin returns revenue, cost and gross margin" do
    result = CategoryMarginQuery.new(period: @period).call.first

    assert_equal "vestuario", result.category
    assert_equal 280.to_d, result.revenue
    assert_equal 130.to_d, result.cost
    assert_equal 150.to_d, result.gross_margin
    assert_in_delta 53.57, result.margin_percent, 0.01
  end

  test "monthly profit groups completed item revenue and cost by month" do
    result = MonthlyProfitQuery.new(period: @period).call.first

    assert_equal "2035-01", result.month
    assert_equal 2, result.purchase_count
    assert_equal 280.to_d, result.item_revenue
    assert_equal 130.to_d, result.item_cost
    assert_equal 150.to_d, result.gross_profit
  end

  test "top customers ranks customers by completed purchase revenue" do
    result = TopCustomersQuery.new(period: @period, limit: 1).call.first

    assert_equal @user.id, result.user_id
    assert_equal @user.name, result.customer_name
    assert_equal 2, result.purchase_count
    assert_equal 280.to_d, result.revenue
  end

  private
    def create_purchase_with_item!(user:, product:, status:, purchase_date:, quantity:, unit_price:, cost_price:)
      product.update!(price: unit_price, cost_price: cost_price)
      subtotal = quantity * unit_price

      purchase = Purchase.create!(
        user: user,
        status: status,
        payment_method: :pix,
        purchase_date: purchase_date,
        subtotal: subtotal,
        shipping_cost: 0,
        discount_amount: 0,
        total_amount: subtotal
      )

      ItemPurchase.create!(
        purchase: purchase,
        product: product,
        quantity: quantity,
        unit_price: unit_price,
        subtotal: subtotal
      )
    end
end

require "test_helper"

class PurchaseFlowTest < ActiveSupport::TestCase
  test "creates complete purchase flow from user to item totals" do
    user = create_user!
    product = create_product!
    quantity = 2
    subtotal = product.price * quantity
    shipping_cost = 12.to_d
    discount_amount = 5.to_d

    purchase = Purchase.create!(
      user: user,
      status: :paid,
      payment_method: :credit_card,
      purchase_date: Time.current,
      subtotal: subtotal,
      shipping_cost: shipping_cost,
      discount_amount: discount_amount,
      total_amount: subtotal + shipping_cost - discount_amount
    )

    item = purchase.item_purchases.create!(
      product: product,
      quantity: quantity,
      unit_price: product.price,
      subtotal: subtotal
    )

    assert purchase.valid?
    assert item.valid?
    assert_equal [ item ], purchase.item_purchases.to_a
    assert_equal [ purchase ], user.purchases.to_a
    assert_equal subtotal, purchase.item_purchases.sum(:subtotal)
    assert_equal subtotal + shipping_cost - discount_amount, purchase.total_amount
  end
end

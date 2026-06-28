require "test_helper"

class CartItemTest < ActiveSupport::TestCase
  test "requires subtotal to match quantity times unit price" do
    item = CartItem.new(
      cart: Cart.new(user: build_user),
      product: build_product,
      quantity: 3,
      unit_price: 12,
      subtotal: 30
    )

    assert_not item.valid?
    assert_includes item.errors[:subtotal], "must equal quantity times unit price"
  end
end

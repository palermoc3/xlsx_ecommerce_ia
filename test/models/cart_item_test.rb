require "test_helper"

class CartItemTest < ActiveSupport::TestCase
  test "accepts valid cart item subtotal" do
    product = build_product
    item = CartItem.new(
      cart: Cart.new(user: build_user),
      product: product,
      quantity: 2,
      unit_price: product.price,
      subtotal: product.price * 2
    )

    assert item.valid?
  end

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

  test "requires positive quantity" do
    product = build_product
    item = CartItem.new(
      cart: Cart.new(user: build_user),
      product: product,
      quantity: 0,
      unit_price: product.price,
      subtotal: 0
    )

    assert_not item.valid?
    assert_includes item.errors[:quantity], "must be greater than 0"
  end
end

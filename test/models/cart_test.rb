require "test_helper"

class CartTest < ActiveSupport::TestCase
  test "defaults to open status" do
    cart = Cart.new(user: build_user)

    assert cart.open?
    assert cart.valid?
  end

  test "destroys cart items when cart is destroyed" do
    cart = Cart.create!(user: create_user!)
    product = create_product!
    cart.cart_items.create!(
      product: product,
      quantity: 2,
      unit_price: product.price,
      subtotal: product.price * 2
    )

    assert_difference "CartItem.count", -1 do
      cart.destroy!
    end
  end
end

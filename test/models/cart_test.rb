require "test_helper"

class CartTest < ActiveSupport::TestCase
  test "defaults to open status" do
    cart = Cart.new(user: build_user)

    assert cart.open?
    assert cart.valid?
  end
end

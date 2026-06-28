require "test_helper"

class ProductTest < ActiveSupport::TestCase
  test "requires price greater than cost price" do
    product = build_product
    product.price = product.cost_price

    assert_not product.valid?
    assert_includes product.errors[:price], "must be greater than cost price"
  end

  test "requires non-negative stock" do
    product = build_product
    product.stock = -1

    assert_not product.valid?
    assert_includes product.errors[:stock], "must be greater than or equal to 0"
  end
end

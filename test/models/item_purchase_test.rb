require "test_helper"

class ItemPurchaseTest < ActiveSupport::TestCase
  test "requires subtotal to match quantity times unit price" do
    item = ItemPurchase.new(
      purchase: build_purchase,
      product: build_product,
      quantity: 2,
      unit_price: 25,
      subtotal: 40
    )

    assert_not item.valid?
    assert_includes item.errors[:subtotal], "must equal quantity times unit price"
  end

  test "requires positive quantity" do
    item = ItemPurchase.new(purchase: build_purchase, product: build_product, quantity: 0, unit_price: 25, subtotal: 0)

    assert_not item.valid?
    assert_includes item.errors[:quantity], "must be greater than 0"
  end
end

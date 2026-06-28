require "test_helper"

class PurchaseTest < ActiveSupport::TestCase
  test "accepts valid purchase totals" do
    purchase = build_purchase

    assert purchase.valid?
  end

  test "requires total amount to match subtotal plus shipping minus discount" do
    purchase = build_purchase
    purchase.total_amount = 90

    assert_not purchase.valid?
    assert_includes purchase.errors[:total_amount], "must equal subtotal plus shipping cost minus discount amount"
  end

  test "requires known status and payment method" do
    purchase = build_purchase
    purchase.status = nil
    purchase.payment_method = nil

    assert_not purchase.valid?
    assert_includes purchase.errors[:status], "can't be blank"
    assert_includes purchase.errors[:payment_method], "can't be blank"
  end
end

require "test_helper"

class CouponTest < ActiveSupport::TestCase
  test "requires unique code" do
    Coupon.create!(code: "BOASVINDAS", discount_type: :fixed_amount, discount_value: 10)
    coupon = Coupon.new(code: "BOASVINDAS", discount_type: :percentage, discount_value: 5)

    assert_not coupon.valid?
    assert_includes coupon.errors[:code], "has already been taken"
  end

  test "usable only when active and not expired" do
    active_coupon = Coupon.new(code: "ATIVO", discount_type: :fixed_amount, discount_value: 10, expires_at: 1.day.from_now)
    expired_coupon = Coupon.new(code: "EXPIRADO", discount_type: :fixed_amount, discount_value: 10, expires_at: 1.day.ago)
    inactive_coupon = Coupon.new(code: "INATIVO", discount_type: :fixed_amount, discount_value: 10, active: false)

    assert active_coupon.usable?
    assert_not expired_coupon.usable?
    assert_not inactive_coupon.usable?
  end
end

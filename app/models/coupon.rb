class Coupon < ApplicationRecord
  DISCOUNT_TYPES = {
    percentage: "percentage",
    fixed_amount: "fixed_amount"
  }.freeze

  enum :discount_type, DISCOUNT_TYPES

  validates :code, :discount_type, :discount_value, presence: true
  validates :code, uniqueness: { case_sensitive: false }
  validates :discount_value, numericality: { greater_than: 0 }

  def usable?(at: Time.current)
    active? && (expires_at.blank? || expires_at >= at)
  end
end

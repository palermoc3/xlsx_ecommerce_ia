class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }
  validates :subtotal, numericality: { greater_than_or_equal_to: 0 }
  validate :subtotal_matches_quantity_and_unit_price

  private

  def subtotal_matches_quantity_and_unit_price
    return if quantity.blank? || unit_price.blank? || subtotal.blank?

    expected = quantity * unit_price
    return if (subtotal - expected).abs <= 0.01.to_d

    errors.add(:subtotal, "must equal quantity times unit price")
  end
end

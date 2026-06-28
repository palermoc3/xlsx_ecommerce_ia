class Product < ApplicationRecord
  has_many :item_purchases, dependent: :restrict_with_error
  has_many :reviews, dependent: :destroy
  has_many :cart_items, dependent: :restrict_with_error

  validates :name, :category, :price, :cost_price, presence: true
  validates :stock, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :price, :cost_price, numericality: { greater_than_or_equal_to: 0 }
  validate :price_must_exceed_cost_price

  private

  def price_must_exceed_cost_price
    return if price.blank? || cost_price.blank?

    errors.add(:price, "must be greater than cost price") if price <= cost_price
  end
end

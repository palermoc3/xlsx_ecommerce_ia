class Purchase < ApplicationRecord
  STATUSES = {
    pending: "pending",
    paid: "paid",
    shipped: "shipped",
    canceled: "canceled"
  }.freeze

  PAYMENT_METHODS = {
    pix: "pix",
    credit_card: "credit_card",
    debit_card: "debit_card"
  }.freeze

  belongs_to :user
  has_many :item_purchases, dependent: :destroy
  has_many :products, through: :item_purchases

  enum :status, STATUSES, default: :pending
  enum :payment_method, PAYMENT_METHODS

  validates :status, :payment_method, :purchase_date, presence: true
  validates :subtotal, :shipping_cost, :discount_amount, :total_amount,
    numericality: { greater_than_or_equal_to: 0 }
  validate :total_amount_matches_components

  private

  def total_amount_matches_components
    return if subtotal.blank? || shipping_cost.blank? || discount_amount.blank? || total_amount.blank?

    expected = subtotal + shipping_cost - discount_amount
    return if (total_amount - expected).abs <= 0.01.to_d

    errors.add(:total_amount, "must equal subtotal plus shipping cost minus discount amount")
  end
end

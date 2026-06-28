class Cart < ApplicationRecord
  STATUSES = {
    open: "open",
    checked_out: "checked_out",
    abandoned: "abandoned"
  }.freeze

  belongs_to :user
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  enum :status, STATUSES, default: :open

  validates :status, presence: true
end

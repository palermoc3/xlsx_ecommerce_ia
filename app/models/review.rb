class Review < ApplicationRecord
  belongs_to :user
  belongs_to :product

  validates :rating, numericality: { only_integer: true, in: 1..5 }
  validates :user_id, uniqueness: { scope: :product_id }
end

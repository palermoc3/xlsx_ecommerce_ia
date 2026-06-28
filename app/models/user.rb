class User < ApplicationRecord
  has_many :purchases, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_one :cart, dependent: :destroy

  validates :name, :email, :birth_date, :state, presence: true
  validates :email, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :birth_date_must_be_adult

  private

  def birth_date_must_be_adult
    return if birth_date.blank?

    eighteenth_birthday = birth_date + 18.years
    errors.add(:birth_date, "must be at least 18 years old") if eighteenth_birthday > Date.current
  end
end

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    def build_user(email: "ana@example.com")
      User.new(
        name: "Ana Silva",
        email: email,
        birth_date: 25.years.ago.to_date,
        state: "SP",
        city: "Sao Paulo"
      )
    end

    def create_user!(email: "ana#{SecureRandom.hex(4)}@example.com")
      build_user(email: email).tap(&:save!)
    end

    def build_product(name: "Camiseta Basica")
      Product.new(
        name: name,
        category: "vestuario",
        price: 79.90,
        cost_price: 35.50,
        stock: 10
      )
    end

    def create_product!(name: "Camiseta #{SecureRandom.hex(4)}")
      build_product(name: name).tap(&:save!)
    end

    def build_purchase(user: build_user)
      Purchase.new(
        user: user,
        status: :paid,
        payment_method: :pix,
        purchase_date: Time.current,
        subtotal: 100,
        shipping_cost: 15,
        discount_amount: 10,
        total_amount: 105
      )
    end
  end
end

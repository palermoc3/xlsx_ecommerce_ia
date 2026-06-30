require "test_helper"

class ReviewTest < ActiveSupport::TestCase
  test "requires rating between one and five" do
    review = Review.new(user: build_user, product: build_product, rating: 6)

    assert_not review.valid?
    assert_includes review.errors[:rating], "must be in 1..5"
  end

  test "allows only one review per user and product" do
    user = create_user!
    product = create_product!
    Review.create!(user: user, product: product, rating: 5)

    duplicate = Review.new(user: user, product: product, rating: 4)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "has already been taken"
  end
end

require "test_helper"

class ReviewTest < ActiveSupport::TestCase
  test "requires rating between one and five" do
    review = Review.new(user: build_user, product: build_product, rating: 6)

    assert_not review.valid?
    assert_includes review.errors[:rating], "must be in 1..5"
  end
end

require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "requires core identity fields" do
    user = User.new

    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
    assert_includes user.errors[:email], "can't be blank"
    assert_includes user.errors[:birth_date], "can't be blank"
    assert_includes user.errors[:state], "can't be blank"
  end

  test "requires unique email" do
    create_user!(email: "ana@example.com")
    duplicate = build_user(email: "ana@example.com")

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "has already been taken"
  end

  test "requires adult user" do
    user = build_user
    user.birth_date = 17.years.ago.to_date

    assert_not user.valid?
    assert_includes user.errors[:birth_date], "must be at least 18 years old"
  end
end

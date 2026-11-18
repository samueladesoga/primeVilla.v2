require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "cannot be deleted while it has tenancies" do
    assert_not users(:one).destroy
    assert users(:three).destroy
  end

  test "account setup token finds the user until the password changes" do
    user = users(:three)
    token = user.generate_token_for(:account_setup)
    assert_equal user, User.find_by_password_token(token)

    user.update!(password: "newpassword")
    assert_nil User.find_by_password_token(token)
  end

  test "name falls back to email" do
    assert_equal "x@example.com", User.new(email_address: "x@example.com").name
  end
end

require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  test "welcome link lets a new tenant set their password and signs them in" do
    user = users(:three)
    token = user.generate_token_for(:account_setup)
    get edit_password_url(token)
    assert_response :success

    put password_url(token), params: { password: "brandnew", password_confirmation: "brandnew" }
    assert_redirected_to root_url
    assert user.reload.authenticate("brandnew")
  end

  test "invalid token redirects with a message" do
    get edit_password_url("nope")
    assert_redirected_to new_password_url
  end
end

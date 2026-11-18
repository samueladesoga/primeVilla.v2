require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:admin) }

  test "index lists tenants only and supports search" do
    get users_url
    assert_response :success
    assert_select "td", text: "Tolu One"
    assert_select "td", text: "Ada Admin", count: 0

    get users_url(q: "bisi")
    assert_select "td", text: "Bisi Two"
    assert_select "td", text: "Tolu One", count: 0
  end

  test "show renders the tenant profile" do
    get user_url(users(:one))
    assert_response :success
    assert_select "body", text: /08000000001/
  end

  test "deleting a tenant with history shows a message instead of crashing" do
    assert_no_difference("User.count") { delete user_url(users(:one)) }
    assert_redirected_to user_url(users(:one))
  end

  test "invalid update re-renders the form" do
    patch user_url(users(:one)), params: { user: { email_address: "not-an-email" } }
    assert_response :unprocessable_entity
  end
end

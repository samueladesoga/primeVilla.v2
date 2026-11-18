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

  test "index lists tenants in room order, with unassigned tenants last" do
    room_ten = Room.create!(name: "Room 10")
    Tenancy.create!(user: users(:three), room: room_ten, start_date: Date.current, end_date: Date.current + 365, is_active: true)
    User.create!(email_address: "zero@example.com", password: "password", first_name: "Ade", last_name: "Zero")

    get users_url
    names = css_select("tbody tr td:first-child").map { |cell| cell.text.strip }
    assert_equal [ "Tolu One", "Bisi Two", "Chidi Three", "Ade Zero" ], names
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

require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "admin creates a tenant and is taken to assign a room" do
    sign_in_as users(:admin)
    assert_difference("User.count") do
      assert_enqueued_emails 1 do
        post registrations_url, params: { user: { email_address: "new@example.com", first_name: "New", last_name: "Tenant", phone_number: "0801" } }
      end
    end
    user = User.find_by!(email_address: "new@example.com")
    assert_equal "0801", user.phone_number
    assert_redirected_to new_tenancy_url(user_id: user.id)
  end

  test "tenants cannot create users" do
    sign_in_as users(:one)
    get new_registrations_url
    assert_redirected_to root_url
  end
end

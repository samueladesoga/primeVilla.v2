require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "tenant updates their phone number without changing password" do
    patch profile_url, params: { user: { phone_number: "0809", password: "", password_confirmation: "", password_challenge: "" } }
    assert_redirected_to root_url
    assert_equal "0809", users(:one).reload.phone_number
  end

  test "changing password requires the current password" do
    patch profile_url, params: { user: { password: "newpass1", password_confirmation: "newpass1", password_challenge: "wrong" } }
    assert_response :unprocessable_entity

    patch profile_url, params: { user: { password: "newpass1", password_confirmation: "newpass1", password_challenge: "password" } }
    assert_redirected_to root_url
    assert users(:one).reload.authenticate("newpass1")
  end
end

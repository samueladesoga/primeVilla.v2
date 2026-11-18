require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "admin dashboard lists overdue, expiring and vacant" do
    sign_in_as users(:admin)
    get root_url
    assert_response :success
    assert_select "#overdue", text: /Bisi Two/
    assert_select "#expiring", text: /Tolu One/
    assert_select "#vacant", text: /Room 3/
  end

  test "admin dashboard shows empty states" do
    Tenancy.update_all(is_active: false)
    sign_in_as users(:admin)
    get root_url
    assert_select "#overdue", text: /No tenancies are overdue/
  end

  test "tenant sees their tenancy and payment details" do
    sign_in_as users(:one)
    get root_url
    assert_response :success
    assert_select "body", text: /Room 1/
    assert_select "body", text: /#{Rails.application.config.x.hostel.bank_account_number}/
  end
end

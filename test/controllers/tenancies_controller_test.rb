require "test_helper"

class TenanciesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:admin)
    @tenancy = tenancies(:one)
  end

  test "index, new, show and renew render" do
    get tenancies_url
    assert_response :success
    get new_tenancy_url(user_id: users(:three).id, room_id: rooms(:three).id)
    assert_response :success
    assert_select "select#tenancy_user_id option[selected]", text: "Chidi Three"
    get tenancy_url(@tenancy)
    assert_response :success
    assert_select "body", text: /Room 1/
    get renew_tenancy_url(@tenancy)
    assert_response :success
  end

  test "index shows the parent / next of kin number" do
    get tenancies_url
    assert_select "#tenancy_row_room_#{rooms(:one).id} a[href='tel:08100000001']", minimum: 1
    assert_select "#tenancy_row_room_#{rooms(:one).id}", text: /Mrs One/
  end

  test "downloads the tenancy report as a PDF" do
    tenancies(:one).update!(comments: "Paid ₦450,000")
    users(:one).update!(last_name: "Adébáyọ̀")
    get tenancies_url(format: :pdf)
    assert_response :success
    assert_equal "application/pdf", response.media_type
    assert_match "attachment", response.headers["Content-Disposition"]
    assert response.body.start_with?("%PDF")
  end

  test "edit keeps the current tenant and room selected" do
    get edit_tenancy_url(@tenancy)
    assert_response :success
    assert_select "select#tenancy_user_id option[selected]", text: "Tolu One"
    assert_select "select#tenancy_room_id option[selected]", text: "Room 1"
  end

  test "creates a tenancy" do
    assert_difference("Tenancy.count") do
      post tenancies_url, params: { tenancy: { user_id: users(:three).id, room_id: rooms(:three).id,
                                               start_date: Date.current, end_date: Date.current + 365 } }
    end
    assert_redirected_to tenancy_url(Tenancy.last)
    assert Tenancy.last.is_active?
  end

  test "renewing ends the previous tenancy and starts a new one" do
    assert_difference("Tenancy.count") do
      post tenancies_url, params: { previous_tenancy_id: @tenancy.id,
                                    tenancy: { user_id: @tenancy.user_id, room_id: @tenancy.room_id,
                                               start_date: @tenancy.end_date, end_date: @tenancy.end_date + 365 } }
    end
    assert_not @tenancy.reload.is_active?
    assert_equal @tenancy.end_date + 365, users(:one).active_tenancy.end_date
  end

  test "a failed renewal leaves the previous tenancy active" do
    assert_no_difference("Tenancy.count") do
      post tenancies_url, params: { previous_tenancy_id: @tenancy.id,
                                    tenancy: { user_id: @tenancy.user_id, room_id: @tenancy.room_id,
                                               start_date: @tenancy.end_date, end_date: @tenancy.end_date - 1 } }
    end
    assert_response :unprocessable_entity
    assert @tenancy.reload.is_active?
  end

  test "updates a tenancy" do
    patch tenancy_url(@tenancy), params: { tenancy: { comments: "Updated" } }
    assert_redirected_to tenancy_url(@tenancy)
    assert_equal "Updated", @tenancy.reload.comments
  end

  test "invalid update re-renders the form" do
    patch tenancy_url(@tenancy), params: { tenancy: { end_date: @tenancy.start_date - 1 } }
    assert_response :unprocessable_entity
    assert_select "[role=alert]", text: /End date must be after the start date/
  end

  test "ending a tenancy from the index updates the row" do
    delete tenancy_url(@tenancy), as: :turbo_stream
    assert_response :success
    assert_not @tenancy.reload.is_active?
    assert_match "Assign tenant", response.body
  end

  test "ending a tenancy from the show page redirects back" do
    delete tenancy_url(@tenancy), params: { return_to: "show" }
    assert_redirected_to tenancy_url(@tenancy)
  end
end

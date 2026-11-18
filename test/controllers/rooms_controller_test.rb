require "test_helper"

class RoomsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:admin) }

  test "index, show, new and edit render" do
    get rooms_url
    assert_response :success
    get room_url(rooms(:one))
    assert_response :success
    get new_room_url
    assert_response :success
    get edit_room_url(rooms(:one))
    assert_response :success
  end

  test "creates a room" do
    assert_difference("Room.count") { post rooms_url, params: { room: { name: "Room 4" } } }
    assert_redirected_to rooms_url
  end

  test "rejects a duplicate room name" do
    assert_no_difference("Room.count") { post rooms_url, params: { room: { name: "Room 1" } } }
    assert_response :unprocessable_entity
  end

  test "deleting a room with history shows a message instead of crashing" do
    assert_no_difference("Room.count") { delete room_url(rooms(:one)) }
    assert_redirected_to room_url(rooms(:one))
    assert_match "tenancy history", flash[:alert]
  end

  test "deletes an unused room" do
    assert_difference("Room.count", -1) { delete room_url(rooms(:three)) }
  end

  test "tenants cannot see room history" do
    delete session_url
    sign_in_as users(:two)
    get room_url(rooms(:one))
    assert_redirected_to root_url
  end
end

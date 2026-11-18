require "test_helper"

class RoomTest < ActiveSupport::TestCase
  test "name must be present and unique" do
    assert_not Room.new(name: " ").valid?
    assert_not Room.new(name: "room 1").valid?
    assert Room.new(name: "Room 9").valid?
  end

  test "cannot be deleted while it has tenancies" do
    room = rooms(:one)
    assert_not room.destroy
    assert Room.exists?(room.id)
  end

  test "vacant scope" do
    assert_equal [ rooms(:three) ], Room.vacant.to_a
  end
end

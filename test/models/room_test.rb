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

  test "in_room_order sorts room numbers by value, not alphabetically" do
    names = [ "Room 10", "Room 2", "room 21", "Room 1", "Room 3" ]
    sorted = Room.in_room_order(names.map { |name| Room.new(name: name) }).map(&:name)
    assert_equal [ "Room 1", "Room 2", "Room 3", "Room 10", "room 21" ], sorted
  end

  test "in_room_order handles names without numbers" do
    sorted = Room.in_room_order([ Room.new(name: "Studio"), Room.new(name: "Room 2"), Room.new(name: "Annex") ]).map(&:name)
    assert_equal [ "Annex", "Room 2", "Studio" ], sorted
  end

  test "vacant scope" do
    assert_equal [ rooms(:three) ], Room.vacant.to_a
  end
end

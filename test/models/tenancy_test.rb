require "test_helper"

class TenancyTest < ActiveSupport::TestCase
  test "end date must be after start date" do
    tenancy = Tenancy.new(user: users(:three), room: rooms(:three), start_date: Date.current, end_date: Date.current - 1)
    assert_not tenancy.valid?
    assert_includes tenancy.errors[:end_date], "must be after the start date"
  end

  test "rejects overlapping tenancies in the same room" do
    tenancy = Tenancy.new(user: users(:three), room: rooms(:one), start_date: Date.current - 20, end_date: Date.current + 100)
    assert_not tenancy.valid?
    assert_match "already booked", tenancy.errors[:base].first
  end

  test "rejects a second active tenancy for a room or user" do
    tenancy = Tenancy.new(user: users(:one), room: rooms(:three), start_date: Date.current + 400, end_date: Date.current + 700, is_active: true)
    assert_not tenancy.valid?
    assert tenancy.errors[:user].any?
  end

  test "end! brings the end date forward when the tenant moves out early" do
    tenancy = tenancies(:one) # ends in 10 days
    tenancy.end!
    assert_not tenancy.is_active?
    assert_equal Date.current, tenancy.end_date
  end

  test "end! keeps the end date when the tenancy has already run out" do
    tenancy = tenancies(:two) # ended 5 days ago
    assert_no_changes -> { tenancy.reload.end_date } do
      tenancy.end!
    end
    assert_not tenancy.is_active?
  end

  test "the database allows only one active tenancy per room" do
    duplicate = Tenancy.new(user: users(:three), room: rooms(:one), start_date: Date.current + 400, end_date: Date.current + 700, is_active: true)
    assert_raises(ActiveRecord::RecordNotUnique) { duplicate.save!(validate: false) }
  end

  test "status" do
    assert_equal :expiring_soon, tenancies(:one).status
    assert_equal :overdue, tenancies(:two).status
    assert_equal :ended, tenancies(:old).status
    assert_equal 5, tenancies(:two).days_overdue
  end

  test "renewal attributes start when the tenancy ends and keep its length" do
    tenancy = tenancies(:one)
    attrs = tenancy.renewal_attributes
    assert_equal tenancy.end_date, attrs[:start_date]
    assert_equal tenancy.end_date + 365, attrs[:end_date]
  end
end

class Tenancy < ApplicationRecord
  belongs_to :user
  belongs_to :room
 
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :no_overlap_for_room, on: :create
  validate :no_overlap_for_user, on: :create

  
  def expires_within_a_month?
    (end_date >= Date.today) && (end_date <= Date.today + 30.days)
  end

  def expired?
    end_date < Date.today
  end

  def overlapping_tenancies
    Tenancy.where.not(id: id)
           .where("(start_date <= ?) AND (end_date >= ?)", end_date, start_date)
  end

  def no_overlap_for_room
    if overlapping_tenancies.where(room_id: room_id).exists? && !room.is_empty
      errors.add(:room_id, "is already occupied during this period")
    end
  end

  def no_overlap_for_user
    if overlapping_tenancies.where(user_id: user_id).exists? && !room.is_empty
      errors.add(:user_id, "already has a room during this period")
    end
  end

  def current?
    Date.today <= end_date
  end
end

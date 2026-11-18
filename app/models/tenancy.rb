class Tenancy < ApplicationRecord
  EXPIRING_SOON_WINDOW = 30.days

  belongs_to :user
  belongs_to :room

  scope :active, -> { where(is_active: true) }

  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_after_start_date
  validate :no_overlapping_tenancy_in_room
  validate :room_has_no_other_active_tenancy, if: :is_active?
  validate :user_has_no_other_active_tenancy, if: :is_active?

  def expires_within_a_month?
    (end_date >= Date.current) && (end_date <= Date.current + EXPIRING_SOON_WINDOW)
  end

  def expired?
    end_date < Date.current
  end

  def current?
    Date.current <= end_date
  end

  def days_remaining
    (end_date - Date.current).to_i
  end

  def days_overdue
    (Date.current - end_date).to_i
  end

  # :ended, :overdue, :expiring_soon or :active
  def status
    return :ended unless is_active?
    return :overdue if expired?
    return :expiring_soon if expires_within_a_month?
    :active
  end

  # Ends the tenancy now. If the tenant moves out before the end date, the end
  # date is brought forward to today so the room's history shows when it really
  # became free, and the next tenancy in that room doesn't overlap this one.
  def end!
    attributes = { is_active: false }
    attributes[:end_date] = [ Date.current, start_date + 1.day ].max if end_date > Date.current
    update!(attributes)
  end

  # Defaults for the tenancy that follows this one: same tenant and room,
  # starting when this one ends and lasting just as long.
  def renewal_attributes
    length = (end_date - start_date).to_i
    { user_id: user_id, room_id: room_id, start_date: end_date, end_date: end_date + length.days }
  end

  private
    def end_date_after_start_date
      return if start_date.blank? || end_date.blank?
      errors.add(:end_date, "must be after the start date") if end_date <= start_date
    end

    def no_overlapping_tenancy_in_room
      return if start_date.blank? || end_date.blank? || room_id.blank?
      overlapping = Tenancy.where(room_id: room_id)
                           .where.not(id: id)
                           .where("start_date < ? AND end_date > ?", end_date, start_date)
                           .includes(:user).first
      if overlapping
        errors.add(:base, "#{room&.name || 'This room'} is already booked by #{overlapping.user.name} " \
                          "from #{I18n.l(overlapping.start_date)} to #{I18n.l(overlapping.end_date)}")
      end
    end

    def room_has_no_other_active_tenancy
      return if room_id.blank?
      if Tenancy.active.where(room_id: room_id).where.not(id: id).exists?
        errors.add(:room, "already has an active tenancy. End or renew that tenancy first")
      end
    end

    def user_has_no_other_active_tenancy
      return if user_id.blank?
      if Tenancy.active.where(user_id: user_id).where.not(id: id).exists?
        errors.add(:user, "already has an active tenancy in another room")
      end
    end
end

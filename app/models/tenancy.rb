class Tenancy < ApplicationRecord
  belongs_to :user
  belongs_to :room
 
  validates :start_date, presence: true
  validates :end_date, presence: true
  
  def expires_within_a_month?
    (end_date >= Date.today) && (end_date <= Date.today + 30.days)
  end

  def expired?
    end_date < Date.today
  end

  def current?
    Date.today <= end_date
  end
end

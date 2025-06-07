class Tenancy < ApplicationRecord
  belongs_to :user
  belongs_to :room
 
  validates :start_date, presence: true
  validates :end_date, presence: true

  def current?
    Date.today <= end_date
  end
end

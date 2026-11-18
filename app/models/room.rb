class Room < ApplicationRecord
  has_many :tenancies, dependent: :restrict_with_error
  has_many :users, through: :tenancies
  has_one :active_tenancy, -> { where(is_active: true) }, class_name: "Tenancy"

  scope :vacant, -> { where.not(id: Tenancy.active.select(:room_id)) }

  normalizes :name, with: ->(name) { name.strip }
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def occupied?
    active_tenancy.present?
  end
end

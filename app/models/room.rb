class Room < ApplicationRecord
  has_many :tenancies
  has_many :users, through: :tenancies
  has_one :active_tenancy, -> { where(is_active: true) }, class_name: 'Tenancy'
end

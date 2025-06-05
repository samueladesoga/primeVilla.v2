class Room < ApplicationRecord
  has_many :tenancies
  has_many :users, through: :tenancies
end

class Room < ApplicationRecord
  has_many :tenancies, dependent: :restrict_with_error
  has_many :users, through: :tenancies
  has_one :active_tenancy, -> { where(is_active: true) }, class_name: "Tenancy"

  scope :vacant, -> { where.not(id: Tenancy.active.select(:room_id)) }

  normalizes :name, with: ->(name) { name.strip }
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  # Rooms in number order: "Room 2" before "Room 10" (a plain name sort puts
  # "Room 10" first). Room lists are small, so sorting happens in Ruby.
  def self.in_room_order(rooms)
    rooms.sort_by(&:sort_key)
  end

  def occupied?
    active_tenancy.present?
  end

  # Splits the name into text and number parts so numbers compare by value:
  # "Room 10" → ["room ", 10]. Text and numbers always alternate, starting with
  # text, so two keys never compare a number against a string.
  def sort_key
    name.to_s.downcase.split(/(\d+)/).map { |part| part.match?(/\A\d+\z/) ? part.to_i : part }
  end
end

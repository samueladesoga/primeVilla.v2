class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }
  validates :password, presence: true, on: :create
  validates :password, length: { minimum: 6 }, allow_blank: true, on: :update

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def admin?
    self.admin
  end
end

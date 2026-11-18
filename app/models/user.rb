class User < ApplicationRecord
  ACCOUNT_SETUP_LINK_VALIDITY = 7.days

  has_secure_password
  has_many :tenancies, dependent: :restrict_with_error
  has_many :sessions, dependent: :destroy
  has_many :rooms, through: :tenancies
  has_one :active_tenancy, -> { where(is_active: true) }, class_name: "Tenancy"

  scope :tenants, -> { where(admin: false) }
  scope :without_active_tenancy, -> { where.not(id: Tenancy.active.select(:user_id)) }

  # Longer-lived than the 15-minute password reset token so new tenants have time
  # to act on their welcome email. Invalidated as soon as the password changes.
  generates_token_for :account_setup, expires_in: ACCOUNT_SETUP_LINK_VALIDITY do
    password_salt.last(10)
  end

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }
  validates :password, presence: true, on: :create
  validates :password, length: { minimum: 6 }, allow_blank: true, on: :update

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def self.find_by_password_token(token)
    find_by_password_reset_token(token) || find_by_token_for(:account_setup, token)
  end

  def admin?
    admin
  end

  def name
    full_name = "#{first_name} #{last_name}".strip
    full_name.presence || email_address
  end
end

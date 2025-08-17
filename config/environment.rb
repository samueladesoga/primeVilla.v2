# Load the Rails application.
require_relative "application"

# Initialize the Rails application.
Rails.application.initialize!

ActionMailer::Base.smtp_settings = {
  :user_name => "MS_yqIoRk@theprimevilla.com",
  :password =>   Rails.application.credentials.dig(:mailersend_api_key),
  :domain => ENV["ROOT_URL"],
  :address => 'smtp.mailersend.net',
  :port => 587,
  :starttls => true
}

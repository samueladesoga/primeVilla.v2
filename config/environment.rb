# Load the Rails application.
require_relative "application"

# Initialize the Rails application.
Rails.application.initialize!

ActionMailer::Base.smtp_settings = {
  :user_name => "94f4c7001@smtp-brevo.com",
  :password =>   Rails.application.credentials.dig(:brevo_api_key),
  :domain => ENV["ROOT_URL"],
  :address => 'smtp-relay.brevo.com',
  :port => 587,
  :starttls => true
}

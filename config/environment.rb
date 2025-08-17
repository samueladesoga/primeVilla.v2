# Load the Rails application.
require_relative "application"

# Initialize the Rails application.
Rails.application.initialize!

ActionMailer::Base.smtp_settings = {
  :user_name => "AKIAYF4JFVMXOL2ZSGWE",
  :password =>   Rails.application.credentials.dig(:ses_api_key),
  :domain => ENV["ROOT_URL"],
  :address => 'email-smtp.us-east-1.amazonaws.com',
  :port => 587,
  :authentication => :plain,
  :enable_starttls_auto => true
}

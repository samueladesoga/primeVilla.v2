# Hostel-wide settings. Override any of these with environment variables
# (e.g. in .env locally or the `env:` section of config/deploy.yml).
Rails.application.config.x.hostel = ActiveSupport::OrderedOptions.new.merge!(
  name: ENV.fetch("HOSTEL_NAME", "SS Hall (The Prime Villa)"),
  website: ENV.fetch("HOSTEL_WEBSITE", "www.theprimevilla.com"),
  admin_email: ENV.fetch("ADMIN_EMAIL", "samueladesoga@gmail.com"),
  bank_account_name: ENV.fetch("BANK_ACCOUNT_NAME", "Samuel Adesoga"),
  bank_name: ENV.fetch("BANK_NAME", "Zenith Bank"),
  bank_account_number: ENV.fetch("BANK_ACCOUNT_NUMBER", "2283023374")
)

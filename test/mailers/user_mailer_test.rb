require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "welcome email contains a set-password link, not a password" do
    mail = UserMailer.with(user: users(:three)).welcome_email
    assert_equal [ "three@example.com" ], mail.to
    assert_match "/passwords/", mail.body.encoded
    assert_no_match(/Password:/, mail.body.encoded)
  end

  test "rent reminders include payment details" do
    tenancy = tenancies(:two)
    mail = UserMailer.with(user_id: tenancy.user_id, tenancy_end_date: tenancy.end_date, elapsed_days: 5).rent_over_due
    assert_match Rails.application.config.x.hostel.bank_account_number, mail.text_part.body.to_s
    assert_match "5 days ago", mail.html_part.body.to_s
  end
end

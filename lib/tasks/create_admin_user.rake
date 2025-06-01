namespace :user do
  desc "Create an admin user"
  task create_admin: :environment do
    require "io/console"

    print "Enter admin email: "
    email = STDIN.gets.chomp

    print "Enter password: "
    password = STDIN.noecho(&:gets).chomp
    puts

    print "Confirm password: "
    password_confirmation = STDIN.noecho(&:gets).chomp
    puts

    if password != password_confirmation
      puts "❌ Passwords do not match."
      exit 1
    end

    admin = User.find_or_initialize_by(email_address: email)
    admin.password = password
    admin.password_confirmation = password_confirmation
    admin.admin = true

    if admin.save
      puts "✅ Admin user created or updated: #{admin.email_address}"
    else
      puts "❌ Failed to create admin user:"
      admin.errors.full_messages.each { |msg| puts " - #{msg}" }
    end
  end
end
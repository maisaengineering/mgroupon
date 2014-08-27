namespace :db do
  desc "Setup form demo"

  task demo_setup: :environment do
    raise "INFO: this task should not be run in production" if Rails.env.production?
    puts 'EMPTY THE MONGODB DATABASE...'
    Mongoid::Sessions.default.collections.reject { |c| c.name =~ /^system/}.each(&:drop)

    Rake::Task["db:create_admin"].invoke
  end


  desc "create Admin"
  task create_admin: :environment do
    Admin.create!({fname: 'MGroupon',lname: 'Admin',email: "admin@mgroupon.com", password: "12345678", password_confirmation: "12345678" })
  end

end


namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    make_test_user
  end
end

def make_test_user
  test_user = User.new(email:"kevinflo@gmail.com", password:"foobarbar", confirmed_at:Time.now)
  test_user.save!
end 
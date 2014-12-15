namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    make_test_user
    make_test_user_2
  end
end

def make_test_user
  test_user = User.new(email:"kevinflo@gmail.com", password:"foobarbar", confirmed_at:Time.now)
  test_user.save!
end

def make_test_user_2
  test_user_2 = User.new(email:"supartest@gmail.com", password:"foobarbar", confirmed_at:Time.now)
  test_user_2.save!
end
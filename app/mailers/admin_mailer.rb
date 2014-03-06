class AdminMailer < ActionMailer::Base
  default to: 'showboardersite@gmail.com',
          from: 'showboardersite@gmail.com'
 
  def beta_application(user)
    @user = user
    mail(subject: "New beta Signup: #{@user.email}")
  end
end
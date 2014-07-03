class AdminMailer < ActionMailer::Base
  default to: 'admin@showboarder.com',
          from: 'admin@showboarder.com'
 
  def beta_application(user)
    @user = user
    mail(subject: "New beta Signup: #{@user.email}")
  end

  def dispute
  end
end
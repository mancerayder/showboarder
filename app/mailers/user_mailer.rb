class UserMailer < ActionMailer::Base
  default from: "showboardersite@gmail.com"

  def beta_welcome_email(user)
    @user = user
    @url  = 'http://www.showboarder.com'
    @twitter = 'http://www.twitter.com/showboarder'
    mail(to: @user.email, subject: 'Thank you for applying to be part of the Showboarder beta')
  end
end

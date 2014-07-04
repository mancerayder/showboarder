class ReceiptMailer < ActionMailer::Base
  default from: 'admin@showboarder.com'
 
  def zoop(user)
    @user = user
    mail(subject: "New beta Signup: #{@user.email}")
  end

  def dispute
  end
end
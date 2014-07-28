class AdminMailer < ActionMailer::Base
  default to: 'admin@showboarder.com',
          from: 'admin@showboarder.com'
 
  def beta_application(user)
    @user = user
    mail(subject: "New beta Signup: #{@user.email}")
  end

  def dispute(charge_id)
    @charge = Charge.find_by_id(charge_id)
    @sale = charge.sale
    mail(subject: "ALERT: Charge Disputed!")
  end

 
  def zoop(user)
    @user = user
    mail(subject: "New beta Signup: #{@user.email}")
  end  
end
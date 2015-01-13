class UserMailer < ActionMailer::Base
  default from: "admin@showboarder.com"

  def beta_welcome(user)
    @user = user
    @url  = 'http://www.showboarder.com'
    @twitter = 'http://www.twitter.com/showboarder'
    mail(to: @user.email, subject: 'Thank you for applying to be part of the Showboarder beta')
  end


  def dispute(charge_id)
    @charge = Charge.find_by_id(charge_id)
  end

  def receipt(guid)
    @sale = Sale.find_by(guid: guid)
    @tickets = @sale.actionee.tickets
    @show = @sale.actionee.tickets.first.show

    if @sale
      mail(to: @sale.actioner.email, subject: "Tickets Purchased")
    end
  end

  def cancellation(subscription_id) 
  end

  def past_due(subscription_id)
  end  
end

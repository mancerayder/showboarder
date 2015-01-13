class StripeEventsController < ApplicationController
  skip_before_action :authenticate_user!
  protect_from_forgery :except => :create
  before_action :parse_and_validate_event

  def create
    if self.class.private_method_defined? event_method
      self.send(event_method, @event.event_object)
    end
    render nothing: true
  end

  private

  def event_method
    "stripe_#{@event.stripe_type.gsub('.', '_')}".to_sym
  end

  def parse_and_validate_event
    if Rails.env.production? && params[:livemode] == false
      render nothing: true # test event sent to livemode
    else
      @event = StripeEvent.new(stripe_id: params[:id], stripe_type: params[:type])

      unless @event.save
        if @event.valid?
          render nothing: true, status: 400 # valid event, try again later
        else
          render nothing: true # invalid event, move along
        end
      end
    end
  end

  def stripe_charge_dispute_created(charge)
    charge = Charge.find_by(stripe_id: charge.id)
    return unless charge
    AdminMailer.delay.dispute(charge.id)
  end

  def stripe_charge_refunded(charge)
    charge = Sale.find_by(stripe_id: charge.id)
    return unless charge
    charge.refund!
  end

  def stripe_charge_succeeded(charge)
    sale = Sale.find_by!(stripe_id: charge.id)
    AdminMailer.delay.receipt(sale.id)
    UserMailer.delay.receipt(sale.id)
  end  
end
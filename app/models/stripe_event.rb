class StripeEvent < ActiveRecord::Base
  validates_uniqueness_of :stripe_id

  def event_object
    Stripe::Event.retrieve(stripe_id)
    event.data.object
  end
end
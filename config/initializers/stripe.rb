require 'uri'

if Rails.env.development?
  Rails.configuration.stripe = {
    :publishable_key => ENV['STRIPE_TEST_KEY_PUBLISHABLE'],
    :secret_key      => ENV['STRIPE_TEST_KEY']
  }
end

if Rails.env.production?
  Rails.configuration.stripe = {
    :publishable_key => ENV['STRIPE_LIVE_KEY_PUBLISHABLE'],
    :secret_key      => ENV['STRIPE_LIVE_KEY']
  }
end

Stripe.api_key = Rails.configuration.stripe[:secret_key]

# StripeEvent.configure do |events|
#   events.subscribe 'charge.failed' do |event|
#     # Define subscriber behavior based on the event object
#     # event.class       #=> Stripe::Event
#     # event.type        #=> "charge.failed"
#     # event.data.object #=> #<Stripe::Charge:0x3fcb34c115f8>
#     # user = User.find_by_stripe_id(event.data.object.customer)
#     # user.expire
#   end

#   events.subscribe 'customer.subscription.trial_will_end' do |event|
#     # Occurs three days before the trial period of a subscription is scheduled to end.
#   end

#   events.subscribe 'customer.subscription.deleted' do |event|
#     # Occurs whenever a customer ends their subscription.
#   end

#   events.all do |event|
#     # Handle all event types - logging, etc.
#   end
# end
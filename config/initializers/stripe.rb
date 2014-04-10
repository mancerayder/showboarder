Rails.configuration.stripe = {
  :publishable_key => ENV['STRIPE_TEST_KEY_PUBLISHABLE'],
  :secret_key      => ENV['STRIPE_TEST_KEY']
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]
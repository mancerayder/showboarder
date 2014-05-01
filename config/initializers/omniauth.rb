Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env.development?
    provider :stripe_connect, ENV['STRIPE_CONNECT_CLIENT_ID_DEV'], ENV['STRIPE_TEST_KEY']
  end
  if Rails.env.production?
    provider :stripe_connect, ENV['STRIPE_CONNECT_CLIENT_ID'], ENV['STRIPE_LIVE_KEY']
  end
end
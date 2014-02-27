module Showboarder
  class Application < Rails::Application
    config.after_initialize do
      MusicBrainz.configure do |c|
        # Application identity (required)
        c.app_name = "Showboarder"
        c.app_version = "0.1"
        c.contact = "showboardersite@gmail.com"

        # # Cache config (optional)
        # c.cache_path = "/tmp/musicbrainz-cache"
        # c.perform_caching = true

        # Querying config (optional)
        # c.query_interval = 1.2 # seconds
        # c.tries_limit = 2
      end
    end
  end
end
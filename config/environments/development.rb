Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # fuck yarn -- this CRASHES the app?!
  config.webpacker.check_yarn_integrity = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true # set to true while debugging

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Don't care if the mailer can't send.
  # config.action_mailer.raise_delivery_errors = false
  # config.action_mailer.perform_caching = false

  # default_url_options[:host]
  #config.action_mailer.default_url_options = { :host => "app.voicebuddy.nl" }

  #config.action_mailer.delivery_method = :smtp
  #config.action_mailer.smtp_settings = {
    # :address                => "smtp.quickhost.nl",
  #  :domain                 => "app.voicebuddy.nl"
  # }
  config.action_mailer.default_url_options = { :host => "app.voicebuddy.nl" }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true

  config.action_mailer.smtp_settings = {
    address: "localhost", # Send to the local machine
    port: 25,             # Default SMTP port. Change if your local server uses a different one (e.g., 1025 for Mailcatcher)
    domain: "app.voicebuddy.nl", # Optional: Usually not needed for localhost, but keep if required by your local setup
    openssl_verify_mode: 'none'
    # You might need authentication settings here if your local SMTP server requires them:
    # user_name:            'your_username',
    # password:             'your_password',
    # authentication:       'plain', # or 'login', 'cram_md5'
    # enable_starttls_auto: true    # Use true if your server uses STARTTLS (common on port 587)
  }

  # config.action_mailer.default_url_options = { :host => "localhost:80" }
  # config.action_mailer.delivery_method = :smtp
  # config.action_mailer.perform_deliveries = true
  # config.action_mailer.raise_delivery_errors = true
  # config.action_mailer.perform_deliveries = true
  # config.action_mailer.default_url_options = { host: 'http://develop.sense-studios.com', port: 3737 }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = false

  # Raises error for missing translations.
  # config.action_view.raise_on_missing_translations = true
  # config.assets.compress = false
  # config.assets.debug = false
  # config.assets.compile = false

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker
  config.web_console.permissions = '83.87.66.134'
  config.hosts << "voicebuddy.sense-studios.com"
  config.hosts << "voicebuddy-dev4.sense-studios.com"
  config.hosts << "app.voicebuddy.nl"
  config.hosts << "dev.voicebuddy.nl"
end


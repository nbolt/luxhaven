Luxhaven::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  config.stripe.publishable_key = 'pk_test_8RTCDG9oe65V4VpMm5vC0mCO'

  config.assets.precompile += %w( css_imports.css fotorama.css fotorama.js )

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  config.assets.debug = true

  STDOUT.sync = true

  logger = Logger.new(STDOUT)
  logger.level = 0 # Must be numeric here - 0 :debug, 1 :info, 2 :warn, 3 :error, and 4 :fatal
  # NOTE:   with 0 you're going to get all DB calls, etc.

  Rails.logger = Rails.application.config.logger = logger
end

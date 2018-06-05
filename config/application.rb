require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'dotenv'
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

Dotenv.load(File.expand_path('../.env',  __FILE__))

# Show program output without delay (disable output buffering).
STDOUT.sync = true

producer = ENV['PRICEWARS_PRODUCER_URL'] || 'vm-mpws2016hp1-03.eaalab.hpi.uni-potsdam.de'
marketplace = ENV['PRICEWARS_MARKETPLACE_URL'] || 'vm-mpws2016hp1-04.eaalab.hpi.uni-potsdam.de:8080/marketplace'

producer = 'http://' + producer unless producer.starts_with?('http')
marketplace = 'http://' + marketplace unless marketplace.starts_with?('http')

$producer_url = producer
$marketplace_url = marketplace

module Parser
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    config.middleware.insert_before 0, 'Rack::Cors' do
      allow do
        origins '*'
        resource '*', headers: :any, methods: [:get, :post, :delete, :put, :patch, :options, :head]
      end
    end
  end
end

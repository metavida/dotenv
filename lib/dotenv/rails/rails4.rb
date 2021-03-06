# Almost identical to v2.0.1 dotenv/rails.rb
# https://github.com/bkeepers/dotenv/blob/v2.0.1/lib/dotenv/rails.rb

require "dotenv"

Dotenv.instrumenter = ActiveSupport::Notifications

# Watch all loaded env files with Spring
begin
  require "spring/watcher"
  ActiveSupport::Notifications.subscribe(/^dotenv/) do |*args|
    event = ActiveSupport::Notifications::Event.new(*args)
    Spring.watch event.payload[:env].filename if Rails.application
  end
rescue LoadError
  # Spring is not available
end

module Dotenv
  # Dotenv Railtie for using Dotenv to load environment from a file into
  # Rails applications
  class Railtie < Rails::Railtie
    config.before_configuration { load }

    # Public: Load dotenv
    #
    # This will get called during the `before_configuration` callback, but you
    # can manually call `Dotenv::Railtie.load` if you needed it sooner.
    def load
      Dotenv.load(*to_load)
    end

    # Internal: `Rails.root` is nil in Rails 4.1 before the application is
    # initialized, so this falls back to the `RAILS_ROOT` environment variable,
    # or the current working directory.
    def root
      Rails.root || Pathname.new(ENV["RAILS_ROOT"] || Dir.pwd)
    end

    def to_load
      Dotenv::ToLoad.new(:app_root => root)
    end

    # Rails uses `#method_missing` to delegate all class methods to the
    # instance, which means `Kernel#load` gets called here. We don't want that.
    def self.load
      instance.load
    end
  end
end

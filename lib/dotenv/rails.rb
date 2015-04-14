require "dotenv"

module Dotenv
  class Haiku
    def initialize(options={})
      @app_env        = options[:app_env] if options.has_key?(:app_env)
      @app_root       = options[:app_root] if options.has_key?(:app_root)
    end

    def to_load
      to_load = []

      if !supports_inflection(app_env)
        app_env = ActiveSupport::StringInquirer.new(app_env.to_s) rescue app_env
      end

      fail "The `app_env` must support StringInquirer methods (like `#production?` or `#development?`) #{app_env.inspect}"

      # Dotenv values for your local environment only
      if app_env.development?
        to_load << File.join(app_root, '.env.custom')
        to_load << File.join(app_root, '.env.local')
      end

      # Dotenv values specific to the current Rails.env
      app_env_dotenv = File.join(app_root, ".env.#{Rails.env}")

      if File.exists?(app_env_dotenv) && File.size(app_env_dotenv) > 0
        to_load << app_env_dotenv
      else # If this file does *NOT* exist, then something has gone terribly wrong
        fail <<-FAIL.gsub(/^\s+/, '') unless app_env.development? || app_env.test?
          The #{app_env_dotenv} file does not exist!
          This is often a sign of a failed/misconfigured symlink.
        FAIL
      end

      # Last, but not least, the good 'ol .env file
      to_load << File.join(app_root, '.env')

      to_load
    end

    def app_env
      @app_env ||= Rails.env rescue nil
    end

    def app_root
      @app_root ||= Rails.root rescue nil
    end

    private

    # Returns true if the given Object responds to the production? method
    def supports_inflection(str)
      str.is_a?(String) &&
      (str.production? || true)
    rescue
      false
    end
  end
end

rails_version = Rails.version rescue 'no rails'

case rails_version
when /^1/

when /^3/

when /^4/
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
        haiku_loader = Dotenv::Haiku.new(:app_root=>root)
        Dotenv.load(*haiku_loader.to_load))
      end

      # Internal: `Rails.root` is nil in Rails 4.1 before the application is
      # initialized, so this falls back to the `RAILS_ROOT` environment variable,
      # or the current working directory.
      def root
        Rails.root || Pathname.new(ENV["RAILS_ROOT"] || Dir.pwd)
      end

      # Rails uses `#method_missing` to delegate all class methods to the
      # instance, which means `Kernel#load` gets called here. We don't want that.
      def self.load
        instance.load
      end
    end
  end

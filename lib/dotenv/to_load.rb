module Dotenv
  # Determines the list of .env* files that are appropriate
  # for the current/given app_env and app_root
  class ToLoad
    class InvalidAppEnv < ArgumentError; end
    class MissingDotenv < ArgumentError; end

    def initialize(options = {})
      @app_env        = options[:app_env] if options.key?(:app_env)
      @app_root       = options[:app_root] if options.key?(:app_root)
    end

    def to_a
      to_load = []

      validate_app_env

      # Dotenv values for your local development environment only
      to_load << File.join(app_root, ".env.custom") if app_env.development?

      # Dotenv values for the local computer
      to_load << File.join(app_root, ".env.local")

      # Dotenv values specific to the current Rails.env
      app_env_dotenv = File.join(app_root, ".env.#{Rails.env}")
      protect_against_missing_app_env_dotenv(app_env_dotenv)
      to_load << app_env_dotenv

      # Last, but not least, the good 'ol .env file
      to_load << File.join(app_root, ".env")

      to_load
    end

    def app_env
      @app_env ||= Rails.env
    rescue
      nil
    end

    def app_root
      @app_root ||= Rails.root
    rescue
      nil
    end

    private

    def validate_app_env
      return true if supports_inflection(app_env)

      fail InvalidAppEnv, <<-FAIL.gsub(/^\s+|\n/, "")
        The `app_env` must support StringInquirer methods
        (like `#production?` or `#development?`) #{app_env.inspect}"
      FAIL
    end

    def protect_against_missing_app_env_dotenv(path)
      return true if File.exist?(path) && File.size(path) > 0
      return true if app_env.development? || app_env.test?

      # If this file does *NOT* exist, then something has gone terribly wrong
      fail MissingDotenv, <<-FAIL.gsub(/^\s+/, "")
        The #{path} file does not exist!
        This is often a sign of a failed/misconfigured symlink.
      FAIL
    end

    # Returns true if the given Object responds to the production? method
    def supports_inflection(str)
      str.is_a?(String) &&
        (str.production? || true)
    rescue
      false
    end
  end
end

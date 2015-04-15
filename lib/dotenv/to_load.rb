module Dotenv
  class ToLoad
    class InvalidAppEnv < ArgumentError; end
    class MissingDotenv < ArgumentError; end

    def initialize(options={})
      @app_env        = options[:app_env] if options.has_key?(:app_env)
      @app_root       = options[:app_root] if options.has_key?(:app_root)
    end

    def to_a
      to_load = []

      fail InvalidAppEnv, "The `app_env` must support StringInquirer methods (like `#production?` or `#development?`) #{app_env.inspect}" unless supports_inflection(app_env)

      # Dotenv values for your local development environment only
      if app_env.development?
        to_load << File.join(app_root, '.env.custom')
      end
      # Dotenv values for the local computer
      to_load << File.join(app_root, '.env.local')

      # Dotenv values specific to the current Rails.env
      app_env_dotenv = File.join(app_root, ".env.#{Rails.env}")

      if File.exist?(app_env_dotenv) && File.size(app_env_dotenv) > 0
        to_load << app_env_dotenv
      else # If this file does *NOT* exist, then something has gone terribly wrong
        fail MissingDotenv, <<-FAIL.gsub(/^\s+/, '') unless app_env.development? || app_env.test?
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
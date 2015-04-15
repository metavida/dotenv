require "dotenv"

module Dotenv
  # Dotenv Railtie for using Dotenv to load environment from a file into
  # Rails application
  class Railtie
    # Public: Load dotenv
    #
    # Manually add `Dotenv::Railtie.load` in your app's config/environment.rb
    # inside the `Rails::Initializer.run do |config|` block
    def load
      Dotenv.load(*to_load)
    end

    def to_load
      Dotenv::ToLoad.new(:app_env => RAILS_ENV, :app_root => RAILS_ROOT)
    end
  end
end

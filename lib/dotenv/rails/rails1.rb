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

    # Rails uses `#method_missing` to delegate all class methods to the
    # instance, which means `Kernel#load` gets called here. We don't want that.
    def self.load
      new.load
    end
  end
end

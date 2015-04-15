require "dotenv"

module Dotenv
  # Dotenv Railtie for using Dotenv to load environment from a file into
  # Ruby applications
  class Railtie
    # Public: Load dotenv
    #
    # Manually call `Dotenv::Railtie.load` in your app's config
    def load
      Dotenv.load(*to_load)
    end

    def to_load
      Dotenv::ToLoad.new
    end
  end
end
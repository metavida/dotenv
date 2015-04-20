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
      Dotenv::ToLoad.new(
        :app_env => StringInquirerBackport.new(RAILS_ENV),
        :app_root => RAILS_ROOT
      )
    end

    # Rails uses `#method_missing` to delegate all class methods to the
    # instance, which means `Kernel#load` gets called here. We don't want that.
    def self.load
      new.load
    end
  end

  # Backporting ActiveSupprt::StringInquirer from Rails 3.2.21
  # See https://github.com/rails/rails/blob/v3.2.21/activesupport/lib/active_support/string_inquirer.rb
  class StringInquirerBackport < String
    def method_missing(method_name, *arguments)
      if method_name.to_s[-1, 1] == "?"
        self == method_name.to_s[0..-2]
      else
        super
      end
    end
  end
end

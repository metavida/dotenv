# dotenv-haiku [![Build Status](https://secure.travis-ci.org/metavida/dotenv.png?branch=haiku)](https://travis-ci.org/metavida/dotenv)

A fork of [the bkeepers/dotenv project](https://github.com/bkeepers/dotenv/).

## Purpose

This fork exists to fulfill a few specific purposes for us

* Enforce a few specific load rules
  * Load the `.env.custom` file on development environments.
  * Load the `".env.#{Rails.env}"` file and **fail hard** if the file does not exist on production.
* Better support for older Rails versions and non-Rails apps.

## Installation

Add this line to the top of your application's Gemfile:

```ruby
gem 'dotenv-haiku', require: 'dotenv/rails', git: 'git@github.com:metavida/dotenv.git', branch: 'haiku'
```

And then execute:

```shell
$ bundle
```

### Rails 4

#### Note on load order

dotenv is initialized in your Rails app during the `before_configuration` callback, which is fired when the `Application` constant is defined in `config/application.rb` with `class Application < Rails::Application`. If you need it to be initialized sooner, you can manually call `Dotenv::Railtie.load`.

```ruby
# config/application.rb
Bundler.require(*Rails.groups)

Dotenv::Railtie.load

HOSTNAME = ENV['HOSTNAME']
```

If you use gems that require environment variables to be set before they are loaded, then list `dotenv-rails` in the `Gemfile` before those other gems and require `dotenv/rails-now`.

```ruby
gem 'dotenv-haiku', require: 'dotenv/rails-now', git: 'git@github.com:metavida/dotenv.git', branch: 'haiku'
gem 'gem-that-requires-env-variables'
```

### Rails 3

As early as possible in your application bootstrap process, load `.env`:

```ruby
# config/application.rb
require 'dotenv/rails-now'
```

### Rails 1

```ruby
# config/environment.rb
# in the `Rails::Initializer.run do |config|` block
require 'dotenv/rails-now'
```

### non-Rails

Currently, the gem depends on ActiveSupport::StringInquirer behavior, so you have 2 options

#### Include the ActiveSupport gem

```ruby
gem 'active_support', git: 'git@github.com:metavida/dotenv.git', branch: 'haiku'
```

And then execute:

```shell
$ bundle
```

As early as possible in your application bootstrap process, load `.env`:

```ruby
require 'active_support/string_inquirer'
require 'dotenv/rails'
Dotenv::Railtie.load(:app_env => ActiveSupport::StringInquirer.new(ENV["RACK_ENV"]))
# Yup, that's right. These references to "rails"
# should work, even for non-Rails apps
```

#### Emulate StringInquirer behavior

As early as possible in your application bootstrap process, load `.env`:

```ruby
class MyStringInquirer < String
  def method_missing(method_name, *arguments)
    if method_name.to_s[-1,1] == "?"
      self == method_name.to_s[0..-2]
    else
      super
    end
  end
end

require 'dotenv/rails'
Dotenv::Railtie.load(:app_env => MyStringInquirer.new(ENV["RACK_ENV"]))
```

## Contributing

If you want a better idea of how dotenv works, check out the [Ruby Rogues Code Reading of dotenv](https://www.youtube.com/watch?v=lKmY_0uY86s).

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

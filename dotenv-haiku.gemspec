require File.expand_path("../lib/dotenv/version", __FILE__)
require "English"

Gem::Specification.new "dotenv-haiku", "0.1.0" do |gem|
  gem.authors       = ["Marcos Wright-Kuhns", "Brandon Keepers"]
  gem.email         = ["webmaster@wrightkuhns.com"]
  gem.description   = gem.summary = "Autoload dotenv with Haiku Learning-specific tweaks."
  gem.homepage      = "https://github.com/metavida/dotenv"
  gem.license       = "MIT"
  gem.files         = `git ls-files lib | grep rails`\
    .split($OUTPUT_RECORD_SEPARATOR) + ["README.md", "LICENSE"]

  gem.add_dependency "dotenv"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "rubocop"
  gem.add_development_dependency "spring"
  gem.add_development_dependency "railties", "~>4.0"
end

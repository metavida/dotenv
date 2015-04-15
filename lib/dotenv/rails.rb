require "dotenv"
require "dotenv/to_load"

rails_version = nil
begin
  rails_version = Rails.version
rescue
  rails_version = "no rails"
end

case rails_version
when /^1/
  require "dotenv/rails/rails1"
when /^2/
  fail "Sorry, Rails 2 is not yet supported"
when /^3/
  require "dotenv/rails/rails3"
when /^4/
  require "dotenv/rails/rails4"
else
  require "dotenv/rails/non_rails"
end

require "dotenv"
require "dotenv/to_load"

# For debugging of rspec tests
#def say(msg)
#  `echo '#{msg.gsub(/['\n]/,'~')}' >> /tmp/rspec.log`
#end

rails_version = Rails.version rescue 'no rails'

case rails_version
when /^1/

when /^3/

when /^4/
  require "dotenv/rails/rails4"
else
  haiku_loader = Dotenv::Haiku.new
  Dotenv.load(*haiku_loader.to_load)
end

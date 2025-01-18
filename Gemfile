source "https://rubygems.org"

RAILS_VERSION = ENV.fetch("RAILS_VERSION", "7.0")

gem "rails", "#{RAILS_VERSION}"

if RAILS_VERSION.to_f <= 5.0
  gem "sqlite3", "~> 1.3"
elsif RAILS_VERSION.to_f <= 7.1
  gem "sqlite3", "~> 1.5"
else
  gem "sqlite3", "~> 2.0"
end

gemspec

# Ruby minimum 2.8

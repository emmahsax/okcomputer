source "https://rubygems.org"

RAILS_VERSION = ENV.fetch("RAILS_VERSION", "7.0")
rails_version_float = RAILS_VERSION.to_f

gem "rails", "#{RAILS_VERSION}"

if rails_version_float <= 7.0
  gem "concurrent-ruby", "1.3.4"
end

if rails_version_float < 7.0
  gem "sqlite3", "~> 1.3.6"
elsif rails_version_float <= 7.1
  gem "sqlite3", "~> 1.5"
else
  gem "sqlite3", "~> 2.0"
end

gem "rspec-rails", "~> 7.1"
gem "sequel", "~> 5.88"
gem "sprockets", "~> 4.2"

gemspec

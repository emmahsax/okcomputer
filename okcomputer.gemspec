source "https://rubygems.org"

RAILS_VERSION = ENV.fetch("RAILS_VERSION", "7.0")

gem "rails", "~> #{RAILS_VERSION}"

if RAILS_VERSION.start_with?("7")
  gem "sqlite3", "~> 1.6"
else
  gem "sqlite3", "~> 1.3.6"
end

gem "test-unit", "~> 3.0" if RUBY_VERSION >= "2.2" && RAILS_VERSION == "3.2"

gem 'sprockets', '~>3.0'

gemspec

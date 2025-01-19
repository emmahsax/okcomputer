source "https://rubygems.org"

RAILS_VERSION = ENV.fetch("RAILS_VERSION", "7.2.2.1")
rails_version_float = RAILS_VERSION.to_f
ruby_version_float = RUBY_VERSION.to_f

gem "rails", "~> #{RAILS_VERSION}"
gem "sequel", "~> 5.88"

# Gems based on Rails version
case rails_version_float
when 0..5.0 # 0 <= Rails < 5.1
  gem "bigdecimal", "~> 1.3.0"
  gem "concurrent-ruby", "<= 1.1.10"
  gem "rspec-rails", rails_version_float == 5.0 ? "~> 4.1" : "~> 3.0"
  gem "sprockets", "~> 3.0"
  gem "sqlite3", "~> 1.3.6"
when 5.1...7.0 # 5.1 <= Rails < 7.0
  gem "concurrent-ruby", "1.3.4"
  gem "rspec-rails", "~> 4.1"
  gem "sprockets", "~> 3.0"
  gem "sqlite3", ruby_version_float <= 2.4 ? "~> 1.3.6" : "~> 1.4"
when 7.0..7.1 # 7.0 <= Rails <= 7.1
  gem "concurrent-ruby", "1.3.4"
  gem "rspec-rails", "~> 7.1"
  gem "sprockets", "~> 4.2"
  gem "sqlite3", "~> 1.5"
else
  gem "concurrent-ruby", "~> 1.3.4"
  gem "rspec-rails", "~> 7.1"
  gem "sprockets", "~> 4.2"
  gem "sqlite3", "~> 2.0"
end

# Gems based on Ruby version
if ruby_version_float >= 2.5
  gem "mutex_m", "~> 0.3" if rails_version_float < 7.1
end

if ruby_version_float > 2.6
  gem "drb", "~> 2.0"
  gem "loofah", "~> 2.24"
else
  gem "loofah", "< 2.20"
end

gemspec

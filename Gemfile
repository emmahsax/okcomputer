source "https://rubygems.org"

RAILS_VERSION = ENV.fetch("RAILS_VERSION", "7.2.2.1")

rails_version_float = RAILS_VERSION.to_f
ruby_version_float = RUBY_VERSION.to_f

if rails_version_float < 7.1
  gem "concurrent-ruby", "1.3.4"
  gem "mutex_m", "~> 0.3"
end

if ruby_version_float > 2.6
  gem "drb", "~> 2.0"
end

gem "rails", "~> #{RAILS_VERSION}"
gem "sequel", "~> 5.88"

if rails_version_float < 7.0
  if rails_version_float <= 5.0
    gem "rspec-rails", "~> 4.1"
    gem "sprockets", "~> 3.0"
    gem "sqlite3", "~> 1.3.6"
  else
    gem "rspec-rails", "~> 4.1"
    gem "sprockets", "~> 3.0"
    gem "sqlite3", "~> 1.4"
  end
else
  if rails_version_float <= 7.1
    gem "sqlite3", "~> 1.5"
  else
    gem "sqlite3", "~> 2.0"
  end

  gem "rspec-rails", "~> 7.1"
  gem "sprockets", "~> 4.2"
end

gemspec

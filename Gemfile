source "https://rubygems.org"

# RAILS_VERSION = ENV.fetch("RAILS_VERSION", "7.2.2.1")

# rails_version_float = RAILS_VERSION.to_f
# ruby_version_float = RUBY_VERSION.to_f

# if rails_version_float < 5.0
#   gem "concurrent-ruby", "<= 1.1.10"
# elsif rails_version_float < 7.1
#   gem "concurrent-ruby", "1.3.4"
# else
#   gem "concurrent-ruby", "~> 1.3.4"
# end

# if rails_version_float < 7.1 && ruby_version_float >= 2.5
#   gem "mutex_m", "~> 0.3"
# end

# if ruby_version_float > 2.6
#   gem "drb", "~> 2.0"
#   gem "loofah", "~> 2.24"
# else
#   gem "loofah", "< 2.20"
# end

# gem "rails", "~> #{RAILS_VERSION}"
# gem "sequel", "~> 5.88"

# if rails_version_float < 5.0
#   gem "bigdecimal", "~> 1.3.0"
# end

# if rails_version_float < 7.0
#   if rails_version_float <= 5.0 || (rails_version_float <= 5.2 && ruby_version_float <= 2.4)
#     gem "sqlite3", "~> 1.3.6"
#   else
#     gem "sqlite3", "~> 1.4"
#   end

#   if rails_version_float <= 4.2
#     gem "rspec-rails", "~> 3.0"
#   else
#     gem "rspec-rails", "~> 4.1"
#   end

#   gem "sprockets", "~> 3.0"
# else
#   if rails_version_float <= 7.1
#     gem "sqlite3", "~> 1.5"
#   else
#     gem "sqlite3", "~> 2.0"
#   end

#   gem "rspec-rails", "~> 7.1"
#   gem "sprockets", "~> 4.2"
# end

# gemspec

# ----------------------------------------------------

# RAILS_VERSION = ENV.fetch("RAILS_VERSION", "7.2.2.1")
# rails_version_float = RAILS_VERSION.to_f
# ruby_version_float = RUBY_VERSION.to_f

# gem "rails", "~> #{RAILS_VERSION}"
# gem "sequel", "~> 5.88"

# # Concurrent Ruby
# gem "concurrent-ruby", if rails_version_float < 5.0
#                           "<= 1.1.10"
#                         elsif rails_version_float < 7.1
#                           "1.3.4"
#                         else
#                           "~> 1.3.4"
#                         end

# # Mutex M (needed for Rails < 7.1 with Ruby >= 2.5)
# gem "mutex_m", "~> 0.3" if rails_version_float < 7.1 && ruby_version_float >= 2.5

# # DRb and Loofah
# if ruby_version_float > 2.6
#   gem "drb", "~> 2.0"
#   gem "loofah", "~> 2.24"
# else
#   gem "loofah", "< 2.20"
# end

# # BigDecimal (Rails < 5.0)
# gem "bigdecimal", "~> 1.3.0" if rails_version_float < 5.0

# # SQLite3 and RSpec-Rails
# if rails_version_float < 7.0
#   # SQLite3 for Rails < 7.0
#   gem "sqlite3", if rails_version_float <= 5.0 || (rails_version_float <= 5.2 && ruby_version_float <= 2.4)
#                    "~> 1.3.6"
#                  else
#                    "~> 1.4"
#                  end

#   # RSpec-Rails for Rails < 7.0
#   gem "rspec-rails", rails_version_float <= 4.2 ? "~> 3.0" : "~> 4.1"

#   # Sprockets for Rails < 7.0
#   gem "sprockets", "~> 3.0"
# else
#   # SQLite3 for Rails >= 7.0
#   gem "sqlite3", rails_version_float <= 7.1 ? "~> 1.5" : "~> 2.0"

#   # RSpec-Rails for Rails >= 7.0
#   gem "rspec-rails", "~> 7.1"

#   # Sprockets for Rails >= 7.0
#   gem "sprockets", "~> 4.2"
# end

# ----------------------------------------------------

RAILS_VERSION = ENV.fetch("RAILS_VERSION", "7.2.2.1")
rails_version_float = RAILS_VERSION.to_f
ruby_version_float = RUBY_VERSION.to_f

gem "rails", "~> #{RAILS_VERSION}"
gem "sequel", "~> 5.88"

# Gems based on Rails version
case rails_version_float
when 0...5.0
  gem "concurrent-ruby", "<= 1.1.10"
  gem "bigdecimal", "~> 1.3.0"
  gem "sqlite3", "~> 1.3.6"
  gem "rspec-rails", "~> 3.0"
  gem "sprockets", "~> 3.0"
when 5.0...7.0
  gem "concurrent-ruby", "1.3.4"
  gem "sqlite3", ruby_version_float <= 2.4 ? "~> 1.3.6" : "~> 1.4"
  gem "rspec-rails", "~> 4.1"
  gem "sprockets", "~> 3.0"
when 7.0...7.1
  gem "concurrent-ruby", "1.3.4"
  gem "sqlite3", "~> 1.5"
  gem "rspec-rails", "~> 7.1"
  gem "sprockets", "~> 4.2"
else
  gem "concurrent-ruby", "~> 1.3.4"
  gem "sqlite3", "~> 2.0"
  gem "rspec-rails", "~> 7.1"
  gem "sprockets", "~> 4.2"
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

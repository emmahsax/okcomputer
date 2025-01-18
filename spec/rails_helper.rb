# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require "spec_helper"
require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rspec/rails"

Rails.backtrace_cleaner.remove_silencers!

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
end

current_rails_version = Gem::Version.new(ActiveRecord::VERSION::STRING)

puts "Current rails version: #{current_rails_version}"

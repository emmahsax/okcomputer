$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ok_computer/version"

authors = {
  "Patrick Byrne" => "code@patrickbyrne.net",
  "Andy Fleener"  => "anfleene@gmail.com",
  "Chris Arcand"  => "chris@chrisarcand.com",
  "Emma Sax"      => "sax.emma.h@gmail.com",
  "Ryan McGeary"  => "ryan@mcgeary.org",
}

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  username      = "emmahsax"
  s.name        = "okcomputer"
  s.version     = OkComputer::VERSION
  s.authors     = authors.keys
  s.email       = authors.values
  s.license     = "MIT"
  s.homepage    = "https://github.com/#{username}/#{s.name}"
  s.summary     = "A simple, extensible health-check monitor"
  s.description = <<-EOL.strip
    Inspired by the simplicity of Fitter Happier, but frustrated by its lack of flexibility, we built OkComputer. Create and register your own custom health checks, or choose from the built-in library of checks to ensure your app is working as intended.
  EOL
  s.required_ruby_version = '>= 2.1'

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.markdown"]
  s.test_files = Dir["test/**/*"]

  s.metadata = {
    "bug_tracker_uri"   => "#{s.homepage}/issues",
    "changelog_uri"     => "#{s.homepage}/blob/main/CHANGELOG.markdown",
    "source_code_uri"   => s.homepage,
  }
end

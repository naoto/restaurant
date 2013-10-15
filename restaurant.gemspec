lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "restaurant/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |gem|
  gem.name        = "restaurant"
  gem.version     = Restaurant::VERSION
  gem.authors     = ["Ryo Nakamura"]
  gem.email       = ["r7kamura@gmail.com"]
  gem.homepage    = "https://github.com/r7kamura/restaurant"
  gem.summary     = "A rails plugin to auto-define RESTful API"
  gem.description = "Restraunt serves your data via auto-defined RESTful API on your rails application."

  gem.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]

  gem.add_dependency "bson"
  gem.add_dependency "bson_ext"
  gem.add_dependency "mongoid"
  gem.add_dependency "protected_attributes"
  gem.add_dependency 'rails-observers'
  gem.add_dependency 'actionpack-page_caching'
  gem.add_dependency 'actionpack-action_caching'
  gem.add_development_dependency "doorkeeper"
  gem.add_development_dependency "rails", ">= 4.0.0"
  gem.add_development_dependency "sqlite3"
  gem.add_development_dependency "rspec-rails", ">= 2.13.0"
  gem.add_development_dependency "rspec-json_matcher"
  gem.add_development_dependency "pry-rails"
  gem.add_development_dependency "simplecov"
end

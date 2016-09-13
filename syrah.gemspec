$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "syrah/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "syrah"
  s.version     = Syrah::VERSION
  s.authors     = ["Carsten Zimmermann"]
  s.email       = ["cz@aegisnet.de"]
  s.homepage    = "https://github.com/carpodaster/syrah"
  s.summary     = "A very, very lightweight RESTful controller abstraction"
  s.description = "A very, very lightweight RESTful controller abstraction, like a minified version of inherited_resources"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", ">= 4.1.5", "< 5.0"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
end

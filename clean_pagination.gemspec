$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "clean_pagination/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "clean_pagination"
  s.version     = CleanPagination::VERSION
  s.authors     = ["Joe Nelson"]
  s.email       = ["cred+github@begriffs.com"]
  s.description = "API pagination the way RFC2616 intended it"
  s.summary     = "Mix into controllers to get pagination helpers"
  s.homepage    = "https://github.com/begriffs/clean_pagination"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_development_dependency "rails", ">= 3.2"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "pry"
  s.add_development_dependency "mocha"
end

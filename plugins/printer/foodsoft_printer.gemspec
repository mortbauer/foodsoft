$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "foodsoft_printer/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "foodsoft_printer"
  s.version     = FoodsoftPrinter::VERSION
  s.authors     = ["paroga"]
  s.email       = ["paroga@paroga.com"]
  s.homepage    = "https://github.com/foodcoops/foodsoft"
  s.summary     = "Printer plugin for foodsoft."
  s.description = "Add a printer queue to foodsoft."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["Rakefile", "README.md"]

  s.add_dependency "rails"
  s.add_dependency "deface", "~> 1.0"
end

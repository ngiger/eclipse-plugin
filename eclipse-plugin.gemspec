# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'eclipse/plugin/version'

Gem::Specification.new do |spec|
  spec.name          = "eclipse-plugin"
  spec.version       = Eclipse::Plugin::VERSION
  spec.authors       = ["Niklaus Giger"]
  spec.email         = ["niklaus.giger@member.fsf.org"]
  spec.summary       = "Extract information about views, properties and perspectives from an eclipse plugin"
  spec.description   = "Extracts localized info out of an Eclipse plugin jar"
  spec.homepage      = ""
  spec.license       = "GPLv3"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.add_dependency 'rubyzip', '~> 1.2.1'
  spec.add_dependency 'nokogiri'
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov"
end

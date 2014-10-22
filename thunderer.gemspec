# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'thunderer/version'

Gem::Specification.new do |spec|
  spec.name          = "thunderer"
  spec.version       = Thunderer::VERSION
  spec.authors       = ["Nick Chubarov"]
  spec.email         = ["nick.chubarov@gmail.com"]
  spec.summary       = 'pub/sub messaging in Rails application'
  spec.description   = 'pub/sub messaging in Rails application thought Faye.'
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.add_dependency 'faye'

  spec.add_runtime_dependency 'activesupport'
  spec.add_development_dependency 'rails'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'jasmine'
  spec.add_development_dependency 'sqlite3'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end

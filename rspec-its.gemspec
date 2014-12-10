# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec/its/version'

Gem::Specification.new do |spec|
  spec.name          = "rspec-its"
  spec.version       = RSpec::Its::VERSION
  spec.authors       = ["Peter Alfvin"]
  spec.email         = ["palfvin@gmail.com"]
  spec.description   = %q{RSpec extension gem for attribute matching}
  spec.summary       = %q{Provides "its" method formerly part of rspec-core}
  spec.homepage      = "https://github.com/rspec/rspec-its"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'rspec-core', '>= 3.0.0'
  spec.add_runtime_dependency 'rspec-expectations', '>= 3.0.0'
  spec.add_development_dependency 'bundler',  '~> 1.3'
  spec.add_development_dependency 'rake',     '~> 10.1.0'
  spec.add_development_dependency 'cucumber', '~> 1.3.8'
  spec.add_development_dependency 'aruba',    '~> 0.5'

end

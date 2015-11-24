# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'revamp/version'

Gem::Specification.new do |spec|
  spec.name          = Revamp::PACKAGE
  spec.version       = Revamp::VERSION
  spec.authors       = [
    'Centralny Ośrodek Informatyki',
    'Suszyński Krzysztof'
  ]
  spec.email         = ['krzysztof.suszynski@coi.gov.pl']
  spec.summary       = Revamp::SUMMARY
  spec.description   = Revamp::DESCRIPTION
  spec.homepage      = Revamp::HOMEPAGE
  spec.license       = Revamp::LICENSE

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_runtime_dependency 'micro-optparse', '~> 1.2.0'

  spec.required_ruby_version = '>= 1.9'
end

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'keoken/version'

Gem::Specification.new do |s|
  s.name          = 'keoken'
  s.version       = Keoken::VERSION
  s.date          = '2019-01-24'
  s.summary       = 'Keoken protocol implemented in Ruby'
  s.description   = 'Provides an interface to Keoken protocol'
  s.authors       = ['Bitex']
  s.email         = 'developers@bitex.la'
  s.files         = `git ls-files`.split("\n")
  s.require_paths = ['lib']
  s.homepage      = 'http://rubygems.org/gems/keoken'
  s.license       = 'MIT'

  s.add_dependency 'bitcoin-ruby', '~> 0.0.18'

  s.add_development_dependency "bundler", "~> 1.11"
  s.add_development_dependency "rake", "~> 12"
  s.add_development_dependency "rspec", "~> 3"
  s.add_development_dependency "webmock", "~> 2.3"
  s.add_development_dependency "byebug", "~> 10"
  s.add_development_dependency "ffi", "~> 1.9"
end

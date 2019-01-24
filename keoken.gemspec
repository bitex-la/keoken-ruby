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
end

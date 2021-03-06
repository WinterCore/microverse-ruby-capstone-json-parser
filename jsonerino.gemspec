lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jsonerino/version'

Gem::Specification.new do |spec|
  spec.name = 'jsonerino'
  spec.version = Jsonerino::VERSION
  spec.authors = ['WinterCore']
  spec.email = ['hogobbl@gmail.com']
  spec.summary = 'JSON parser'
  spec.description = 'JSON parser'
  spec.homepage = 'https://github.com/WinterCore/microverse-ruby-capstone-json-parser'
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\x0")
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop', '~> 0.81.0'
end

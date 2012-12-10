# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'tairu/version'

Gem::Specification.new do |gem|
  gem.name = 'tairu'
  gem.version = Tairu::VERSION
  gem.platform = Gem::Platform::RUBY
  #gem.extensions = Dir['ext/**/*']
  gem.description = 'Simple Tile Server for Ruby'
  gem.summary = 'Simple Tile Server for Ruby'
  gem.licenses = ['MIT']

  gem.authors = ['Scooter Wadsworth']
  gem.email = ['scooterwadsworth@gmail.com']
  gem.homepage = 'https://github.com/scooterw/tairu'

  gem.required_ruby_version = '>= 1.9.2'
  gem.required_rubygems_version = '>= 1.3.6'

  gem.files = Dir['README.md', 'bin/**/*', 'lib/**/*']
  gem.require_paths = ['lib']
  gem.bindir = 'bin'
  gem.executables = ['tairu']

  gem.add_runtime_dependency 'sequel'
  gem.add_runtime_dependency 'sinatra'
  gem.add_runtime_dependency 'puma'

  gem.add_development_dependency 'rake'
end
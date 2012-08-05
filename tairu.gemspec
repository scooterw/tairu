# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'tairu/version'

Gem::Specification.new do |gem|
  gem.name = 'tairu'
  gem.version = Tairu::VERSION
  gem.description = ''
  gem.summary = ''
  gem.licenses = ['MIT']

  gem.authors = ['Scooter Wadsworth']
  gem.email = ['scooterwadsworth@gmail.com']
  gem.homepage = 'https://github.com/scooterw/tairu'

  gem.files = Dir['README.md', 'bin/**/*', 'lib/**/*']
  gem.require_paths = ['lib']
  gem.bindir = 'bin'
  gem.executables = ['tairu']
end
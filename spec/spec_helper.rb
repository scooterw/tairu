require 'rubygems'
require 'bundler/setup'
require 'tairu'
require 'tairu/rspec'

logfile = File.open(File.expand_path('../../log/test.log', __FILE__), 'a')
Tairu.logger = Logger.new(logfile)

Dir['./spec/support/*.rb'].map {|f| require f}

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end
#!/usr/bin/env ruby

require 'optparse'
require 'rack'
require 'puma'
require 'puma/server'

opts = {}

OptionParser.new do |o|
  o.banner = 'Usage: demo.rb [options]'

  o.on('-c', '--config CONFIG', '') do |config|
    opts[:config] = File.expand_path(config)
  end

  o.on('-p', '--port PORT', '') do |port|
    opts[:port] = port
  end

  o.on('-h', '--host HOST', '') do |host|
    opts[:host] = host
  end
end.parse!

if opts[:config]
  unless defined?(Tairu)
    require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'lib', 'tairu')
  end

  Tairu.config_from_file(opts[:config])
else
  puts "No valid config file specified. Use -c / --config option."
  exit(1)
end

app, options = Rack::Builder.parse_file File.join(File.expand_path(File.dirname(__FILE__)), '..', 'config.ru')

server = ::Puma::Server.new(app)
host = opts[:host] || '0.0.0.0'
port = opts[:port] || 8080
server.add_tcp_listener host, port
min_threads, max_threads = 4, 16
server.min_threads = min_threads
server.max_threads = max_threads

puts "Starting server on http://#{host}:#{port}"
puts "Min Threads: #{min_threads} / Max Threads: #{max_threads}"

begin
  server.run.join
rescue Interrupt
  server.stop(true)
end
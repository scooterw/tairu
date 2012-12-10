require 'rubygems'
require 'rubygems/command.rb'
require 'rubygems/dependency_installer.rb'

begin
  Gem::Command.build_args = ARGV
rescue NoMethodError
end

inst = Gem::DependencyInstaller.new

begin
  if defined?(JRUBY_VERSION)
    inst.install 'jdbc-sqlite3'
  else
    inst.install 'sqlite3'
  end
rescue
  exit(1)
end

p File.expand_path(__FILE__)

f = File.open(File.join(File.expand_path(File.dirname(__FILE__)), 'Rakefile'), 'w')
f.write("task :default\n")
f.close
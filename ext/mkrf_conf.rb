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
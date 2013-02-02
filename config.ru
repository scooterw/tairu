$:.push File.expand_path(File.join(File.dirname(__FILE__), 'lib'))
require 'tairu/server'
run Tairu::Server.new
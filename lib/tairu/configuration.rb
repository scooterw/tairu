require 'yaml'

module Tairu
  class Configuration
    attr_accessor :config

    def initialize(config = '../config/tairu.yaml')
      @config = YAML.load_file(File.join(File.expand_path(File.dirname(__FILE__)), config))
    end
  end
end
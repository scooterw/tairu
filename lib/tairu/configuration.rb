require 'yaml'

module Tairu
  class Configuration
    attr_accessor :data, :cache

    def initialize(config = nil)
      raise "No config file specified." unless config
      @data = YAML.load_file(config)
      @cache = start_cache
    end

    def start_cache
      cache_type = @data['cache']['type']
      cache_options = @data['cache']['options']

      if cache_type
        cache = Tairu::Cache::TYPES[cache_type].new(cache_options)
      else
        cache = Tairu::Cache::Memory.new
      end

      cache
    end
  end
end
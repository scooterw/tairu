require 'yaml'

module Tairu
  class Configuration
    attr_accessor :layers, :cache, :name

    def initialize(layers, cache, name = nil)
      @layers = layers
      @cache = cache
      @name = name
    end

    def self.config_from_file(file)
      file = File.expand_path(file)

      if File.exists?(file)
        data = YAML.load_file(file)
      else
        raise 'Configuration file not found at specified location.'
      end

      name = data['name'] if data['name']

      if data['layers']
        layers = data['layers']
      else
        raise 'Layers must be specified.'
      end

      if data['cache'] && data['cache']['type']
        cache_type = data['cache']['type']
        options = data['cache']['options'] ? data['cache']['options'] : {}

        cache = start_cache(cache_type, options)
      end

      cache = Tairu::Cache::Memory.new if cache.nil?

      config = Configuration.new(layers, cache, name)

      config
    end

    def self.start_cache(cache_type = nil, options = nil)
      if cache_type
        cache = Tairu::Cache::TYPES[cache_type].new(options)
      else
        cache = Tairu::Cache::Memory.new
      end

      cache
    end
  end
end
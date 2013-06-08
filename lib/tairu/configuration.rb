require 'yaml'

module Tairu
  module Configuration
    attr_accessor :layers, :cache, :name, :tilesets

    def configure
      yield self
      configure_layers
      configure_cache
      configure_tilesets
    end

    def configure_cache
      if self.cache
        unless self.cache.instance_of? Tairu::Cache
          if self.cache.instance_of? Hash
            if self.cache['type']
              options = self.cache['options'] || nil
              self.cache = start_cache(self.cache['type'], options)
            else
              raise RuntimeError.new('No cache type sepecified')
            end
          end
        end
      else
        self.cache = start_cache
      end
    end

    def add_layers(layers={})
      raise RuntimeError.new('No layers specified') if layers.empty?
      
      layers.each do |k,v|
        unless self.layers.include?(k)
          self.layers[k] = v
          self.tilesets[k] = Tairu::Store::TYPES[v['provider'].downcase].new(k)
        end
      end
    end

    def configure_layers
      raise RuntimeError.new('At least one layer must be specified') unless self.layers
    end

    def configure_tilesets
      self.tilesets = {}

      self.layers.each do |k,v|
        self.tilesets[k] = Tairu::Store::TYPES[v['provider'].downcase].new(k)
      end
    end

    def config_from_file(file)
      file = File.expand_path(file)

      if File.exists?(file)
        data = YAML.load_file(file)
      else
        raise 'Configuration file not found at specified location.'
      end

      raise RuntimeError.new('At least one layer must be specified') unless data['layers']

      configure do |config|
        config.name = data['name']
        config.layers = data['layers']
        config.cache = data['cache']
      end
    end

    def start_cache(cache_type=nil, options=nil)
      if cache_type
        Tairu::Cache::TYPES[cache_type].new(options)
      else
        Tairu::Cache::Memory.new
      end
    end
  end
end

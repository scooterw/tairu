$:.push File.expand_path(File.join(File.dirname(__FILE__), 'tairu'))

require 'rubygems'
require 'sequel'
require 'cache'
require 'store'
require 'coordinate'
require 'tile'
require 'configuration'
require 'version'

module Tairu
  extend self

  TILE_404 = Tairu::Tile.new('', 'image/png')

  class << self
    attr_accessor :logger
    attr_accessor :config
    attr_accessor :cache
    attr_accessor :tilesets

    def config_from_file(file)
      self.config = Tairu::Configuration.config_from_file(file)

      self.tilesets = {}

      self.config.layers.each do |k,v|
        self.tilesets[k] = Tairu::Store::TYPES[v['provider'].downcase].new(k)
      end
    end

    def get_tile(name, coord, format=nil)
      tileset = Tairu.tilesets[name]

      return TILE_404 if tileset.nil?

      tile = Tairu.cache.get(name, coord)

      if tile.nil?
        tile = tileset.get(coord, Tairu.config.layers[name]['format'])
        unless tile.nil?
          Tairu.cache.add(name, coord, tile)
        else
          tile = TILE_404
        end
      end

      tile
    end
  end
end

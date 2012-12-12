$:.push File.expand_path(File.join(File.dirname(__FILE__), 'tairu'))

require 'sequel'
require 'cache'
require 'store'
require 'coordinate'
require 'tile'
require 'configuration'

module Tairu
  extend self

  TILE_404 = Tairu::Tile.new('', 'image/png')

  class << self
    attr_accessor :logger
    attr_accessor :config
    attr_accessor :cache

    def get_tile(name, coord, format = nil)
      tileset = Tairu.config.layers[name]

      unless tileset.nil?
        tile = Tairu.cache.get(tileset, coord)

        if tile.nil?
          provider = Tairu::Store::TYPES[tileset['provider']]
          provider_tile = provider.get(name, tileset['tileset'], coord, tileset['format'])

          unless provider_tile.nil?
            tile = provider_tile
            Tairu.cache.add(tileset, coord, tile)
          else
            tile = TILE_404
          end
        end
      else
        tile = TILE_404
      end

      tile
    end
  end
end
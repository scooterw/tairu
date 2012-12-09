$:.push File.expand_path(File.join(File.dirname(__FILE__), 'tairu'))

require 'sequel'
require 'cache'
require 'store'
require 'coordinate'
require 'tile'
require 'configuration'

module Tairu
  TILE_404 = Tairu::Tile.new(File.read(File.join(File.expand_path(File.dirname(__FILE__)), 'tairu', 'images', '404.png')), 'image/png')

  def self.get_tile(name, coord, format = nil)
    tileset = Tairu::CONFIG.data['cache']['layers'][name]

    unless tileset.nil?
      tile = Tairu::CACHE.get(tileset, coord)

      if tile.nil?
        provider = Tairu::Store::TYPES[tileset['provider']]
        provider_tile = provider.get(name, tileset['tileset'], coord)

        unless provider_tile.nil?
          tile = provider_tile
          Tairu::CACHE.add(tileset, coord, tile)
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
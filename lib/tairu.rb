$:.push File.expand_path(File.join(File.dirname(__FILE__), 'tairu'))

require 'sequel'
require 'cache'
require 'store'
require 'coordinate'
require 'tile'
require 'configuration'

module Tairu
  CONFIG = Tairu::Configuration.new

  PROVIDERS = {
    'mbtiles' => Tairu::Store::MBTiles,
    'esri' => Tairu::Store::Esri
  }

  TILE_404 = Tairu::Tile.new(File.read(File.join(File.expand_path(File.dirname(__FILE__)), 'tairu', 'images', '404.png')), 'image/png')

  def self.get_tile(name, coord)
    tileset = Tairu::CONFIG.config['cache']['layers'][name]

    unless tileset.nil?
      tile = Tairu::Cache.get_recent_tile(tileset, coord)

      if tile.nil?
        provider = Tairu::PROVIDERS[tileset['provider']]
        provider_tile = provider.get(tileset['tileset'], coord)

        unless provider_tile.nil?
          tile = provider_tile
          Tairu::Cache.add_recent_tile(tileset, coord, tile)
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
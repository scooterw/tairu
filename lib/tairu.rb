$:.push File.expand_path(File.join(File.dirname(__FILE__), 'tairu'))

require 'sequel'
require 'cache'
require 'store'
require 'coordinate'
require 'tile'
require 'configuration'

module Tairu
  PROVIDERS = {
    'mbtiles' => Tairu::Store::MBTiles,
    'esri' => Tairu::Store::Esri
  }

  RECENT_TILES = {}

  def self.add_recent_tile(layer, coord, format, body, age = 300)
    key = [layer, coord, format]
    expire = Time.now + age
    RECENT_TILES[key] = {body: body, expire: expire}
    :purge_expired_tiles
  end

  def self.get_recent_tile(layer, coord, format)
    key = [layer, coord, format]
    tile = RECENT_TILES[key]
    nil if tile.nil?
    if tile[:expire] < Time.now
      tile[:body]
    else
      RECENT_TILES.delete(key)
    end
  end

  def self.purge_expired_tiles
    RECENT_TILES.delete_if {|k,v| v[:expire] > Time.now}
  end
end
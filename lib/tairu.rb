$:.push File.expand_path(File.join(File.dirname(__FILE__), 'tairu'))

require 'sequel'
require 'cache'
require 'store'

module Tairu
  recent_tiles = {}

  def add_tile(layer, coord, format, body, age = 300)
    key = [layer, coord, format]
    expire = Time.now + age
    recent_tiles[key] = {body: body, expire: expire}
    :purge_tiles
  end

  def get_tile(layer, coord, format)
    key = [layer, coord, format]
    tile = recent_tiles[key]
    nil if tile.nil?
    if tile[:expire] < Time.now
      tile[:body]
    else
      recent_tiles.delete([key])
    end
  end

  def purge_tiles
    recent_tiles.delete_if {|k,v| v[:expire] > Time.now}
  end
end
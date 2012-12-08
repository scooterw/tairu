module Tairu
  class Cache
    RECENT_TILES = {}

    Key = Struct.new(:layer, :coord, :format)

    def self.add_recent_tile(layer, coord, tile, age = 300) # format?
      key = Tairu::Cache::Key.new(layer, coord)
      expire = Time.now + age
      RECENT_TILES[key] = {tile: tile, expire: expire}
      :purge_expired_tiles

    end

    def self.get_recent_tile(layer, coord) # format?
      key = Tairu::Cache::Key.new(layer, coord)
      tile = RECENT_TILES[key]

      return nil if tile.nil?

      if tile[:expire] < Time.now
        tile[:tile]
      else
        RECENT_TILES.delete(key)
        return nil
      end
    end

    def self.purge_expired_tiles
      RECENT_TILES.delete_if {|k,v| v[:expire] > Time.now}
    end
  end
end
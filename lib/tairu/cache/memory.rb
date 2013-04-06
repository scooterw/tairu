module Tairu
  module Cache
    class Memory
      def initialize(options=nil)
        @tiles = {}
      end

      def add(name, coord, tile, age=300)
        key = Tairu::Cache::Key.new(name, coord)
        expire = Time.now + age
        @tiles[key] = {tile: tile, expire: expire}
        purge_expired
      end

      def get(name, coord)
        key = Tairu::Cache::Key.new(name, coord)
        tile = @tiles[key]

        return nil if tile.nil?

        if tile[:expire] < Time.now
          tile[:tile]
        else
          @tiles.delete(key)
          return nil
        end
      end

      def purge_expired
        @tiles.delete_if {|k,v| v[:expire] > Time.now}
      end
    end
  end
end

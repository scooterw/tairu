require 'connection_pool'
require 'redis'
require 'base64'
require 'multi_json'

module Tairu
  module Cache
    class RedisCache
      def initialize(options={'host' => 'localhost', 'port' => 6379, 'db' => 0})
        if options['url']
          redis_url = options['url']
        else
          db = options['db'] || 0
          redis_url = "redis://#{options['host']}:#{options['port']}/#{db}"
        end

        @pool = ConnectionPool::Wrapper.new(timeout: 1, size: 4) do
          Redis.connect(url: redis_url, driver: 'ruby')
        end
      end

      def add(name, coord, tile, age=300)
        key = "#{name}_#{coord.zoom}_#{coord.column}_#{coord.row}"
        expire = Time.now.to_i + age
        tile = Base64.encode64(tile.data)
        @pool.set(key, MultiJson.dump({tile: tile, format: Tairu.config.layers[name]['format']}))
        @pool.expire(key, expire)
      end

      def get(name, coord)
        key = "#{name}_#{coord.zoom}_#{coord.column}_#{coord.row}"
        value = @pool.get(key)

        if value.nil?
          return nil
        else
          tile_hash = MultiJson.load(value)
          Tairu::Tile.new(Base64.decode64(tile_hash['tile']), tile_hash['format'])
        end
      end
    end
  end
end


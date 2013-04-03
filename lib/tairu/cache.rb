require 'cache/memory'
require 'cache/disk'
require 'cache/redis_cache'

module Tairu
  module Cache
    TYPES = {
      'memory' => Tairu::Cache::Memory,
      'disk' => Tairu::Cache::Disk,
      'redis' => Tairu::Cache::RedisCache
    }

    Key = Struct.new(:layer, :coord, :format)
  end
end

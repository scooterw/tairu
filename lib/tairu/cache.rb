require 'cache/memory'
require 'cache/disk'

module Tairu
  module Cache
    TYPES = {
      'memory' => Tairu::Cache::Memory,
      'disk' => Tairu::Cache::Disk
    }

    Key = Struct.new(:layer, :coord, :format)
  end
end
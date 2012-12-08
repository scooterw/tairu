module Tairu
  class Tile
    attr_accessor :data, :mime_type

    def initialize(data, mime_type)
      @data = data
      @mime_type = mime_type
    end
  end
end
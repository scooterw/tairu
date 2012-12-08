module Tairu
  class Tile
    attr_accessor :tile, :mime_type

    def initialize(tile, mime_type)
      @tile = tile
      @mime_type = mime_type
    end
  end
end
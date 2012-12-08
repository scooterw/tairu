module Tairu
  class Coordinate
    attr_accessor :row, :column, :zoom

    def initialize(row, column, zoom)
      @row = Integer(row)
      @column = Integer(column)
      @zoom = Integer(zoom)
    end
  end
end
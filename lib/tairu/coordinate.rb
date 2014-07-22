module Tairu
  class Coordinate
    attr_accessor :row, :column, :zoom

    def initialize(row, column, zoom)
      @row = Integer(row)
      @column = Integer(column)
      @zoom = Integer(zoom)
    end

    def x
      @column
    end

    def y
      @row
    end

    def z
      @zoom
    end

    def nw
      to_lat_lng(@column, @row, @zoom)
    end

    def ne
      to_lat_lng(@column + 1, @row, @zoom)
    end

    def se
      to_lat_lng(@column + 1, @row + 1, @zoom)
    end

    def sw
      to_lat_lng(@column, @row + 1, @zoom)
    end

    def bounds
      ul = nw
      lr = se
      {x_min: ul[:lng], x_max: lr[:lng], y_min: lr[:lat], y_max: ul[:lat]}
    end

    def center
      to_lat_lng(@column + 0.5, @row + 0.5, @zoom)
    end

    def to_lat_lng(x, y, z)
      n = 2.0 ** z
      lng = x / n * 360.0 - 180.0
      lat_rad = Math::atan(Math::sinh(Math::PI * (1 - 2 * y / n)))
      lat = 180.0 * (lat_rad / Math::PI)
      {lat: lat, lng: lng}
    end
  end
end

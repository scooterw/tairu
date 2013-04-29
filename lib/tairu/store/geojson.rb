module Tairu
  module Store
    class GeoJSON
      def initialize(layer)
        @tileset = File.join(File.expand_path(Tairu.layers[layer]['location']), Tairu.layers[layer]['tileset'])
        @flip = Tairu.layers[layer]['flip_y_coordinate']
      end

      def flip_y(z, y)
        (2 ** z - 1) - y
      end

      def get(coord)
        y = @flip ? flip_y(coord.zoom, coord.row) : coord.row

        path = File.join(@tileset, coord.zoom, coord.column, "#{y}.json")

        return nil unless File.exists?(path)

        data = File.open(path, 'r') do |f|
          begin
            f.flock(File::LOCK_SH)
            f.read
          ensure
            f.flock(File::LOCK_UN)
          end
        end

        mime_type = 'application/json'
        tile = data.nil? nil : Tairu::Tile.new(data, mime_type)
        tile
      end
    end
  end
end

module Tairu
  module Store
    class TMS
      def initialize(layer)
        @tileset = File.join(File.expand_path(Tairu.config.layers[layer]['location']), Tairu.config.layers[layer]['tileset'])
      end

      def flip_y(z, y)
        (2 ** z - 1) - y
      end

      def get(coord, format='png')
        z = "#{coord.zoom}"
        x = "#{coord.column}"
        y = flip_y(coord.zoom, coord.row)

        path = File.join(@tileset, z, x, "#{y}.#{format}")

        return nil unless File.exists?(path)

        data = File.open(path, 'r') do |f|
          begin
            f.flock(File::LOCK_SH)
            f.read
          ensure
            f.flock(File::LOCK_UN)
          end
        end

        mime_type = "image/#{format}"
        tile = data.nil? ? nil : Tairu::Tile.new(data, mime_type)
        tile
      end
    end
  end
end

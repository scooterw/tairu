module Tairu
  module Store
    class Esri
      def initialize(layer)
        @tileset = File.join(File.expand_path(Tairu.config.layers[layer]['location']), Tairu.config.layers[layer]['tileset'])
      end

      def get(coord, format='png')
        path = File.join(@tileset, 'Layers', '_alllayers', "L#{'%02i' % coord.zoom}", "R#{encode_hex(coord.row)}", "C#{encode_hex(coord.column)}.#{format}")

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

      def decode_hex(hex_value)
        Integer("0x#{hex_value}")
      end

      def encode_hex(int_value, length=8)
        length = "%02i" % length
        "%#{length}x" % int_value
      end
    end
  end
end
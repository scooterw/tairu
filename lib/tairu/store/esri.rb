module Tairu
  module Store
    class Esri
      def self.decode_hex(hex_value)
        Integer("0x#{hex_value}")
      end

      def self.encode_hex(int_value, length = 8)
        length = "%02i" % length
        "%#{length}x" % int_value
      end

      def self.lock(path, &block)
        if File.exists?(path)
          File.open(path, 'r+') do |f|
            begin
              f.flock(File::LOCK_SH) #File::LOCK_EX
              yield
            ensure
              f.flock(File::LOCK_UN)
            end
          end
        else
          yield
        end
      end

      def self.get(layer, tileset, coord, format = 'png')
        loc = File.expand_path(Tairu::CONFIG.layers[layer]['location'])
        path = File.join(loc, tileset, 'Layers', '_alllayers', "L#{'%02i' % coord.zoom}", "R#{encode_hex(coord.row)}", "C#{encode_hex(coord.column)}.#{format}")

        return nil unless File.exists?(path)

        data = lock(path) do
          File.read(path)
        end

        mime_type = "image/#{format}"
        Tairu::Tile.new(data, mime_type)
      end
    end
  end
end
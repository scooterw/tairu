# Integer("0x0000000a") => 10
# 10.to_s(16) => "a"
# "%x" % 10 => "a"
# "%08x" % 10 => "0000000a"
# "#%02x%02x%02x" % [255, 0, 10] => #ff000a
# /Layers/_alllayers/Lxx/Rhex/Chex.fmt => L15/R0000000a/C0000000a.jpg
# http://services.arcgisonline.com/cache_im/l3_imagery_Prime_world_2D/Layers/_alllayers/L15/R000027f9/C00002d2c.jpg
# http://proceedings.esri.com/library/userconf/devsummit07/papers/building_and_using_arcgis_server_map_caches-best_practices.pdf

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

      def self.get(layer, tileset, coord, format = 'png')
        loc = File.expand_path(Tairu::CONFIG.data['cache']['layers'][layer]['location'])
        path = File.join(loc, tileset, 'Layers', '_alllayers', "L#{'%02i' % coord.zoom}", "R#{encode_hex(coord.row)}", "C#{encode_hex(coord.column)}.#{format}")

        return nil unless File.exists?(path)

        data = File.read(path)
        mime_type = "image/#{format}"
        Tairu::Tile.new(data, mime_type)
      end
    end
  end
end
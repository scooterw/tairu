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
      def self.get_tile(tileset, coord, format = 'jpg')
        # *.size != 8?
        row = coord[:row].kind_of?(String) && coord[:row].size == 8 ? coord[:row] : "%08x" % coord[:row]
        col = coord[:col].kind_of?(String) && coord[:col].size == 8 ? coord[:col] : "%08x" % coord[:col]
        tile = File.join(tileset, "L#{coord[:zoom]}", "R#{row}", "C#{col}.#{format}")
        mime_type = "image/#{format}"
      end
    end
  end
end
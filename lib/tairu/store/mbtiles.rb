require 'json'
require 'zlib'

module Tairu
  module Store
    class MBTiles
      def initialize(layer)
        tileset = File.join(File.expand_path(Tairu.config.layers[layer]['location']), Tairu.config.layers[layer]['tileset'])
        conn = defined?(JRUBY_VERSION) ? "jdbc:sqlite:#{tileset}" : "sqlite://#{tileset}"
        @db = Sequel.connect(conn, max_connections: 1)
      end

      def get(coord, format=nil)
        formats = {
          'png' => 'image/png',
          'jpg' => 'image/jpg'
        }

        format = @db[:metadata].select(:value).where(name: 'format').first
        mime_type = format.nil? ? formats['png'] : formats[format[:value]]
        
        tile_row = (2 ** coord.zoom - 1) - coord.row
        tile = @db[:tiles].where(zoom_level: coord.zoom, tile_column: coord.column, tile_row: tile_row)
        
        tile_data = tile.first.nil? ? nil : Tairu::Tile.new(tile.first[:tile_data], mime_type)
        tile_data
      end

      def get_grid(coord)
        tile_row = (2 ** coord.zoom - 1) - coord.row
        grid = @db[:grids].where(zoom_level: coord.zoom, tile_column: coord.column, tile_row: tile_row)

        grid_buf = inflate(grid.first[:grid])

        utf_grid = JSON.parse(grid_buf)
        utf_grid[:data] = {}

        grid_data = @db[:grid_data].where(zoom_level: coord.zoom, tile_column: coord.column, tile_row: tile_row)
        
        grid_data.each do |gd|
          utf_grid[:data][gd[:key_name]] = JSON.parse(gd[:key_json])
        end

        utf_grid
      end

      def get_legend
        @db[:metadata].where(name: 'legend').first
      end

      def info
        info = {}

        %w{name type version description format bounds attribution minzoom maxzoom template legend}.each do |key|
          value = @db[:metadata].where(name: key).first
          info[key] = value[:value] unless value.nil?
        end

        info
      end

      def inflate(str)
        zstream = Zlib::Inflate.new
        buf = zstream.inflate(str)
        zstream.finish
        zstream.close
        buf
      end
    end
  end
end
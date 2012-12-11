require 'json'
require 'zlib'

module Tairu
  module Store
    class MBTiles
      def initialize;end

      def self.inflate(str)
        zstream = Zlib::Inflate.new
        buf = zstream.inflate(str)
        zstream.finish
        zstream.close
        buf
      end

      def self.connection_string(layer)
        loc = File.expand_path(Tairu::CONFIG.layers[layer]['location'])
        conn = defined?(JRUBY_VERSION) ? "jdbc:sqlite:#{loc}" : "sqlite://#{loc}"
        conn
      end

      def self.create(layer, file, name, type, version, description, format, bounds = nil)
        unless %w{png jpg}.index format
          raise "Format {#{format}} not supported. Must be 'png' or 'jpg' per MBTiles 1.1 spec."
        end

        conn = connection_string(layer)
        db = Sequel.connect(File.join(conn, file))

        unless db.table_exists?(:metadata)
          db.create_table :metadata do
            primary_key :name
            String :name
            String :value
          end

          db.add_index :metadata, :name, unique: true
        end

        unless db.table_exists?(:tiles)
          db.create_table :tiles do
            Integer :zoom_level
            Integer :tile_column
            Integer :tile_row
            Blob :tile_data
          end

          db.add_index :tiles, [:zoom_level, :tile_column, :tile_row], unique: true
        end

        md = db[:metadata]

        md.insert(name: 'name', value: name)
        md.insert(name: 'type', value: type)
        md.insert(name: 'version', value: version)
        md.insert(name: 'description', value: description)
        md.insert(name: 'format', value: format)
        md.insert(name: 'bounds', value: bounds) unless bounds.nil?

        db.disconnect
      end

      def self.exists?(layer, file)
        conn = connection_string(layer)
        db = Sequel.connect(File.join(conn, file))

        tv = db.tables + db.views

        [:metadata, :tiles].each {|s| return false unless tv.index(s)}

        exists = db[:metadata].first.nil? && db[:tiles].first.nil?

        db.disconnect

        exists
      end

      def self.info(layer, file)
        file_loc = File.join(File.expand_path(Tairu::CONFIG.layers[layer]['location']), file)
        raise "Tileset does not exist." unless exists? file_loc

        conn = connection_string(layer)
        db = Sequel.connect(File.join(conn, file))

        info = {}

        %w{name type version description format bounds}.each do |key|
          value = db[:metadata].where(name: key).first
          info[key] = value[:value] unless value.nil?
        end

        db.disconnect

        info
      end

      def self.list(layer, file)
        conn = connection_string(layer)
        db = Sequel.connect(File.join(conn, file))

        tiles = db[:tiles]

        list = []

        tiles.each do |tile|
          list << [((2 ** tile[:zoom_level] - 1) - tile[:tile_row]), tile[:tile_column], tile[:zoom_level]]
        end

        db.disconnect

        list
      end

      def self.get(layer, file, coord, format = nil)
        conn = connection_string(layer)
        db = Sequel.connect(File.join(conn, file))

        formats = {
          'png' => 'image/png',
          'jpg' => 'image/jpg'
        }

        format = db[:metadata].select(:value).where(name: 'format').first
        mime_type = format.nil? ? formats['png'] : formats[format[:value]]

        tile_row = (2 ** coord.zoom - 1) - coord.row
        tile = db[:tiles].where(zoom_level: coord.zoom, tile_column: coord.column, tile_row: tile_row)

        tile_data = tile.first.nil? ? nil : Tairu::Tile.new(tile.first[:tile_data], mime_type)

        db.disconnect

        tile_data
      end

      def self.get_grid(layer, file, coord)
        conn = connection_string(layer)
        db = Sequel.connect(File.join(conn, file))

        tile_row = (2 ** coord.zoom - 1) - coord.row
        grid = db[:grids].where(zoom_level: coord.zoom, tile_column: coord.column, tile_row: tile_row)

        grid_buf = inflate(grid.first[:grid])

        utf_grid = JSON.parse(grid_buf)
        utf_grid[:data] = {}

        grid_data = db[:grid_data].where(zoom_level: coord.zoom, tile_column: coord.column, tile_row: tile_row)
        
        grid_data.each do |gd|
          utf_grid[:data][gd[:key_name]] = JSON.parse(gd[:key_json])
        end

        db.disconnect

        utf_grid
      end

      def self.remove(layer, file, coord)
        conn = connection_string(layer)
        db = Sequel.connect(File.join(conn, file))
        db.disconnect
      end

      def self.add(layer, file, coord, tile_data)
        conn = connection_string(layer)
        db = Sequel.connect(File.join(conn, file))
        db.disconnect
      end
    end
  end
end
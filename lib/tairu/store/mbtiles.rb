# see https://github.com/migurski/TileStache/blob/master/TileStache/MBTiles.py for original

module Tairu
  module Store
    class MBTiles
      TILESETS_DIR = File.join(File.dirname(__FILE__), '..', '..', 'tilesets')

      CONNECTION_STRING = defined?(JRUBY_VERSION) ? "jdbc:sqlite:#{TILESETS_DIR}/" : "sqlite://#{TILESETS_DIR}/"

      def initialize
        @connection_string = defined?(JRUBY_VERSION) ? "jdbc:sqlite:#{TILESETS_DIR}/" : "sqlite://#{TILESETS_DIR}/"
      end

      def self.create_tileset(file, name, type, version, description, format, bounds = nil)
        unless %w{png jpg}.index format
          raise "Format (#{format}) not supported. Must be 'png' or 'jpg' per MBTiles 1.1 spec."
        end

        tile_db = Sequel.connect(CONNECTION_STRING + file)

        tile_db.create_table :metadata do
          column :name, :text
          column :value, :text
        end

        tile_db.alter_table :metadata do
          add_primary_key :name
        end

        tile_db.create_table :tiles do
          column :zoom_level, :integer
          column :tile_column, :integer
          column :tile_row, :integer
          column :tile_data, :blob
        end

        tile_db.alter_table :tiles do
          add_index :zoom_level
          add_index :tile_column
          add_index :tile_row
        end

        #tile_db.run "CREATE TABLE metadata (name TEXT, value TEXT, PRIMARY KEY (name))"
        #tile_db.run "CREATE TABLE tiles (zoom_level INTEGER, tile_column INTEGER, tile_row INTEGER, tile_data BLOB)"
        #tile_db.run "CREATE UNIQUE INDEX coord ON tiles (zoom_level, tile_column, tile_row)"

        #tile_db["INSERT INTO metadata VALUES (?, ?)", 'name', name].insert
        #tile_db["INSERT INTO metadata VALUES (?, ?)", 'type', type].insert
        #tile_db["INSERT INTO metadata VALUES (?, ?)", 'version', version].insert
        #tile_db["INSERT INTO metadata VALUES (?, ?)", 'description', description].insert
        #tile_db["INSERT INTO metadata VALUES (?, ?)", 'format', format].insert

        #unless bounds.nil?
        #  tile_db["INSERT INTO metadata VALUES (?, ?)", 'bounds', bounds].insert
        #end
      end

      def self.tileset_exists?(file)
        tile_db = Sequel.connect(CONNECTION_STRING + file)
        metadata = tile_db["SELECT name, value FROM metadata LIMIT 1"]
        tiles = tile_db["SELECT zoom_level, tile_column, tile_row, tile_data FROM tiles LIMIT 1"]
        !! metadata.first.nil? && tiles.first.nil?
      end

      def self.tileset_info(file)
        unless tileset_exists? file
          nil
        end

        tile_db = Sequel.connect(CONNECTION_STRING + file)

        tile_info = {}

        %w{name type version description format bounds}.each do |key|
          value = tile_db["SELECT value FROM metadata WHERE name = ?", key].first
          tile_info[key] = value if value
        end

        tile_info
      end

      def self.list_tiles(file)
        file = file.end_with?('mbtiles') ? file : "#{file}.mbtiles"
        tile_db = Sequel.connect(CONNECTION_STRING + file)

        db_tiles = tile_db["SELECT tile_row, tile_column, zoom_level FROM tiles"]

        tiles = []

        db_tiles.each do |tile|
          tiles.push([((2 ** tile[:zoom_level] - 1) - tile[:tile_row]), tile[:tile_column], tile[:zoom_level]])
        end

        tiles
      end

      def self.get_tile(file, coord)
        file = file.end_with?('mbtiles') ? file : "#{file}.mbtiles"
        tile_db = Sequel.connect(CONNECTION_STRING + file)

        formats = {
          'png' => 'image/png',
          'jpg' => 'image/jpg'
        }

        format = tile_db["SELECT value FROM metadata WHERE name='format'"]
        mime_type = format.first.nil? ? formats['png'] : formats[format.first[:value]]

        tile_row = (2 ** coord[:zoom] - 1) - coord[:row]
        query = "SELECT tile_data FROM tiles WHERE zoom_level=? AND tile_column=? AND tile_row=?"
        tile = tile_db[query, coord[:zoom], coord[:col], coord[:row]]

        tile_data = tile.first.nil? ? nil : tile.first[:tile_data]

        {mime_type: mime_type, tile: tile_data}
      end

      def self.delete_tile(file, coord)
        tile_db = Sequel.connect(CONNECTION_STRING + file)

        tile_row = (2 ** coord[:zoom] - 1) - coord[:row]
        query = "DELETE FROM tiles WHERE zoom_level=? AND tile_column=? AND tile_row=?"
        tile_db[query, coord[:zoom], coord[:col], coord[:row]].delete
      end

      def self.put_tile(file, coord, tile_data)
        tile_db = Sequel.connect(CONNECTION_STRING + file)

        tile_row = (2 ** coord[:zoom] - 1) - coord[:row]
        query = "UPDATE tiles SET zoom_level = ?, tile_column = ?, tile_row = ?, tile_data = ?"
        tile_db[query, coord[:zoom], coord[:col], coord[:row], tile_data.to_sequel_blob].update
      end
    end
  end
end
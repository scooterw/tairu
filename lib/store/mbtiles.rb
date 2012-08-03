module Tairu
  module Store
    class MBTiles
      CONNECTION_STRING = defined? JRUBY_VERSION ? 'jdbc:sqlite://' : 'sqlite://'

      def create_tileset(filename, name, type, version, description, format, bounds = nil)
        unless ['png', 'jpg'].index format
          raise "Format (#{format}) must be png or jpg accoring to MBTiles 1.1 spec."
        end

        DB = Sequel.connect(CONNECTION_STRING + filename)

        DB.run "CREATE TABLE metadata (name TEXT, value TEXT, PRIMARY KEY (name))"
        DB.run "CREATE TABLE tiles (zoom_level INTEGER, tile_column INTEGER, tile_row INTEGER, tile_data BLOB)"
        DB.run "CREATE UNIQUE INDEX coord ON tiles (zoom_level, tile_column, tile_row)"

        DB["INSERT INTO metadata VALUES (?, ?)", 'name', name].insert
        DB["INSERT INTO metadata VALUES (?, ?)", 'type', type].insert
        DB["INSERT INTO metadata VALUES (?, ?)", 'version', version].insert
        DB["INSERT INTO metadata VALUES (?, ?)", 'description', description].insert
        DB["INSERT INTO metadata VALUES (?, ?)", 'format', format].insert

        unless bounds.nil?
          DB["INSERT INTO metadata VALUES (?, ?)", 'bounds', bounds].insert
        end
      end

      def tileset_exists(filename);end

      def tileset_info(filename);end

      def list_tiles(filename);end

      def get_tile(filename, coord);end

      def delete_tile(filename, coord);end

      def put_tile(filename, coord, content);end
    end
  end
end
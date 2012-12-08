module Tairu
  module Store
    class MBTiles
      TILESETS_DIR = File.join(File.dirname(__FILE__), '..', '..', 'tilesets')
      CONN = defined?(JRUBY_VERSION) ? "jdbc:sqlite:#{TILESETS_DIR}/" : "sqlite://#{TILESETS_DIR}/"

      def initialize;end

      def self.create(file, name, type, version, description, format, bounds = nil)
        unless %w{png jpg}.index format
          raise "Format {#{format}} not supported. Must be 'png' or 'jpg' per MBTiles 1.1 spec."
        end

        db = Sequel.connect(CONN + file)

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
      end

      def self.exists?(file)
        db = Sequel.connect(CONN + file)

        tv = db.tables + db.views

        [:metadata, :tiles].each {|s| return false unless tv.index(s)}

        db[:metadata].first.nil? && db[:tiles].first.nil?
      end

      def self.info(file)
        raise "Tileset does not exist." unless exists? file

        db = Sequel.connect(CONN + file)

        info = {}

        %w{name type version description format bounds}.each do |key|
          value = db[:metadata].where(name: key).first
          info[key] = value[:value] unless value.nil?
        end

        info
      end

      def self.list(file)
        db = Sequel.connect(CONN + file)

        tiles = db[:tiles]

        list = []

        tiles.each do |tile|
          list << [((2 ** tile[:zoom_level] - 1) - tile[:tile_row]), tile[:tile_column], tile[:zoom_level]]
        end

        list
      end

      def self.get(file, coord)
        db = Sequel.connect(CONN + file)

        formats = {
          'png' => 'image/png',
          'jpg' => 'image/jpg'
        }

        format = db[:metadata].select(:value).where(name: 'format').first
        mime_type = format.nil? ? formats['png'] : formats[format[:value]]

        tile_row = (2 ** coord.zoom - 1) - coord.row
        tile = db[:tiles].where(zoom_level: coord.zoom, tile_column: coord.column, tile_row: tile_row)

        tile_data = tile.first.nil? ? nil : Tairu::Tile.new(tile.first[:tile_data], mime_type)

        tile_data
      end

      def self.remove(file, coord);end

      def self.add(file, coord, tile_data);end
    end
  end
end
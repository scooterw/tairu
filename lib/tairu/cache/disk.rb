require 'zlib'

module Tairu
  module Cache
    class Disk
      def initialize(path, umask = 0022, dirs = 'safe', gzip = %w{txt text json xml})
        @path = path
        @umask = umask
        @dirs = dirs
        @gzip = gzip
      end

      def is_compressed?(format)
        @gzip.index(format.downcase)
      end

      def path(layer, coord, format)
        f = [format.downcase]
        f << 'gz' if self.is_compressed?(f)

        if @dirs == 'safe'
          x = '%06d' % coord[:col]
          y = '%06d' % coord[:row]

          tile_path = File.join(layer[:name], coord[:zoom], x[0..2], x[3..5], y[0..2], y[3..5], '.', f.join('.'))
        elsif @dirs == 'portable'
          x = '%d' % coord[:col]
          y = '%d' % coord[:row]

          tile_path = File.join(layer[:name], coord[:zoom], x, y, '.', f.join('.'))
        else
          raise "dirs must be 'safe' or 'portable'"
        end

        File.join(@path, tile_path)
      end

      def lock(layer, coord, format)
      end

      def unlock(layer, coord, format)
      end

      def remove(layer, coord, format)
      end

      def read(layer, coord, format)
      end

      def save(body, layer, coord, format)
      end
    end
  end
end
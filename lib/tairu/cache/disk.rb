require 'fileutils'

module Tairu
  module Cache
    class Disk
      def initialize(options={})
        raise "No path specified." unless options['path']
        @path = options['path']
        @expire = options['expire'] || 300
      end

      def lock_write(path, data)
        File.open(path, 'wb') do |f|
          begin
            f.flock(File::LOCK_EX)
            f.write(data)
          ensure
            f.flock(File::LOCK_UN)
          end
        end
      end

      def lock_read(path)
        if File.exists?(path)
          if File.mtime(path) > (Time.now - @expire)
            data = File.open(path, 'rb') do |f|
              begin
                f.flock(File::LOCK_SH)
                f.read
              ensure
                f.flock(File::LOCK_UN)
              end
            end
          else
            FileUtils.rm(path)
          end
        end

        data
      end

      def add(name, coord, tile)
        expire = Time.now + @expire
        base_path = File.join(File.expand_path(@path), name, "#{coord.zoom}", "#{coord.column}")
        FileUtils.mkdir_p(base_path)
        path = File.join(base_path, "#{coord.row}.#{Tairu.config.layers[name]['format']}")
        lock_write(path, tile.data)
        purge_expired(name)
      end

      def get(name, coord)
        layer = Tairu.config.layers[name]
        path = File.join(File.expand_path(@path), name, "#{coord.zoom}", "#{coord.column}", "#{coord.row}.#{layer['format']}")
        data = lock_read(path)
        
        return nil if data.nil?

        Tairu::Tile.new(data, layer['format'])
      end

      def purge_expired(name)
        Dir.glob(File.join(File.expand_path(@path), "**/*.#{Tairu.config.layers[name]['format']}")).each do |f|
          FileUtils.rm(f) if File.mtime(f) < (Time.now - @expire)
        end
        Dir[File.join(File.expand_path(@path), '**/*')].select {|d| File.directory?(d)}.select {|d| (Dir.entries(d) - %w[. ..]).empty?}.each {|d| Dir.rmdir(d)}
      end
    end
  end
end
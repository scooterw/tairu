require 'sinatra/base'
require File.join(File.dirname(__FILE__), '..', 'tairu')

module Tairu
  class Server < Sinatra::Base
    get '/:tileset/info' do
      tileset = Tairu.tilesets[params[:tileset]]

      status 404 if tileset.nil?

      content_type :json
      tileset.info.to_json
    end

    get '/:tileset/:zoom/:col/:row.grid.json' do
      status 404 unless Tairu.config.layers[params[:tileset]]['provider'] == 'mbtiles'

      tileset = Tairu.tilesets[params[:tileset]]
      status 404 if tileset.nil?
      
      coord = Tairu::Coordinate.new(Integer(params[:row]), Integer(params[:col]), Integer(params[:zoom]))
      tile = tileset.get_grid(coord)

      callback = params.delete('callback')

      if callback
        content_type :js
        "#{callback}(#{tile.to_json})"
      else
        content_type :json
        tile.to_json
      end
    end

    get '/:tileset/:zoom/:col/:row' do
      coord = Tairu::Coordinate.new(Integer(params[:row]), Integer(params[:col]), Integer(params[:zoom]))
      tile = Tairu.get_tile(params[:tileset], coord)

      response.headers['Content-Type'] = tile.mime_type
      response.headers['Content-Disposition'] = 'inline'
      tile.data
    end
  end
end
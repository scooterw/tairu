require 'sinatra/base'
require File.join(File.dirname(__FILE__), '..', 'tairu')

module Tairu
  class Server < Sinatra::Base
    get '/:tileset/:zoom/:col/:row.grid.json' do
      tileset = Tairu.config.layers[params[:tileset]]
      
      status 404 if tileset.nil?
      
      if tileset['provider'] == 'mbtiles'
        coord = Tairu::Coordinate.new(Integer(params[:row]), Integer(params[:col]), Integer(params[:zoom]))
        tile = Tairu::Store::MBTiles.get_grid(params[:tileset], tileset['tileset'], coord)

        callback = params.delete('callback')

        if callback
          content_type :js
          "#{callback}(#{tile.to_json})"
        else
          content_type :json
          tile.to_json
        end
      else
        status 404
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
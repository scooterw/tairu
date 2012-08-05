require 'sinatra/base'

module Tairu
  class Server < Sinatra::base
    def '/:tileset/:zoom/:row/:col.?:format?' do
      tile = Tairu::Store::MBTiles.get_tile(params[:tileset], {zoom: params[:zoom], row: params[:row], col: params[:col]})
      response.headers['Content-Type'] = tile.first
      response.headers['Content-Disposition'] = 'inline'
      tile.last
    end
  end
end
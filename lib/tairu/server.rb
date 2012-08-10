require 'sinatra/base'
require File.join(File.dirname(__FILE__), '..', 'tairu')

module Tairu
  class Server < Sinatra::Base
    get '/:tileset/:zoom/:row/:col' do
      tile = Tairu::Store::MBTiles.get_tile(params[:tileset], {zoom: Integer(params[:zoom]), row: Integer(params[:row]), col: Integer(params[:col])})
      response.headers['Content-Type'] = tile.first
      response.headers['Content-Disposition'] = 'inline'
      tile.last
    end
  end
end
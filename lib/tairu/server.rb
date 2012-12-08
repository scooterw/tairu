require 'sinatra/base'
require File.join(File.dirname(__FILE__), '..', 'tairu')

module Tairu
  class Server < Sinatra::Base
    get '/:tileset/:zoom/:row/:col' do
      coord = Tairu::Coordinate.new(Integer(params[:row]), Integer(params[:col]), Integer(params[:zoom]))
      tile = Tairu.get_tile(params[:tileset], coord)

      response.headers['Content-Type'] = tile.mime_type
      response.headers['Content-Disposition'] = 'inline'
      tile.data
    end
  end
end
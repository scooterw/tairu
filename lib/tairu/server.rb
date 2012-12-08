require 'sinatra/base'
require File.join(File.dirname(__FILE__), '..', 'tairu')

module Tairu
  class Server < Sinatra::Base
    TILE_404 = Tairu::Tile.new(File.read(File.join(File.expand_path(File.dirname(__FILE__)), 'images', '404.png')), 'image/png')
    config = Tairu::Configuration.new

    get '/:tileset/:zoom/:row/:col' do
      tileset = config.config['cache']['layers'][params[:tileset]]
      
      if tileset
        provider = Tairu::PROVIDERS[tileset['provider']]
        coord = Tairu::Coordinate.new(Integer(params[:row]), Integer(params[:col]), Integer(params[:zoom]))
        tile = provider.get(tileset['tileset'], coord)
        tile = TILE_404 if tile.nil?
      else
        tile = TILE_404
      end

      response.headers['Content-Type'] = tile.mime_type
      response.headers['Content-Disposition'] = 'inline'
      tile.tile
    end
  end
end
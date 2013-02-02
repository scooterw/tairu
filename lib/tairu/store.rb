require 'store/mbtiles'
require 'store/esri'

module Tairu
  module Store
    TYPES = {
      'mbtiles' => Tairu::Store::MBTiles,
      'esri' => Tairu::Store::Esri
    }
  end
end
require 'store/mbtiles'
require 'store/esri'
require 'store/tms'

module Tairu
  module Store
    TYPES = {
      'mbtiles' => Tairu::Store::MBTiles,
      'esri' => Tairu::Store::Esri,
      'tms' => Tairu::Store::TMS
    }
  end
end
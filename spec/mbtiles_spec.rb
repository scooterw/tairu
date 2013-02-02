require File.expand_path('./lib/tairu')

describe Tairu::Store::MBTiles do
  before do
    Tairu.config = Tairu::Configuration.config_from_file('./spec/data/mbtiles.yaml')
  end

  it "should return valid tile for coordinate" do
    coord = Tairu::Coordinate.new(0, 0, 0)
    tile = Tairu::Store::MBTiles.get('geo', 'geography-class.mbtiles', coord)
    tile.instance_of?(Tairu::Tile).should eq(true)
    tile.mime_type.should eq('image/png')
    img = File.read(File.expand_path('./spec/data/geo_0_0_0.png')).force_encoding('UTF-8')
    tile.data.force_encoding('UTF-8').should eq(img)
  end

  it "should return nil if not found" do
    coord = Tairu::Coordinate.new(1, 1, 1)
    tile = Tairu::Store::MBTiles.get('geo', 'geography-class.mbtiles', coord)
    tile.should eq(nil)
  end
end
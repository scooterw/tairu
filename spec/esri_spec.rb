require File.expand_path('./lib/tairu')

describe Tairu::Store::Esri do
  before do
    Tairu.config = Tairu::Configuration.config_from_file('./spec/data/esri.yaml')
  end

  it "should encode integer to hex" do
    hex = Tairu::Store::Esri.encode_hex(10)
    hex.should eq('0000000a')
  end

  it "should decode hex to integer" do
    int = Tairu::Store::Esri.decode_hex('0000000a')
    int.should eq(10)
  end

  it "should return valid tile" do
    coord = Tairu::Coordinate.new(25064, 13674, 16) # row, col, zoom
    tile = Tairu::Store::Esri.get('waldo', 'waldo_canyon', coord)
    tile.instance_of?(Tairu::Tile).should eq(true)
    tile.mime_type.should eq('image/png')
    tile.data.should eq(File.read(File.expand_path('./spec/data/tilesets/waldo_canyon/Layers/_alllayers/L16/R000061e8/C0000356a.png')))
  end

  it "should return nil if not found" do
    coord = Tairu::Coordinate.new(0, 0, 0)
    tile = Tairu::Store::Esri.get('waldo', 'waldo_canyon', coord)
    tile.should eq(nil)
  end
end
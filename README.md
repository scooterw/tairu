tairu ... simple map tile server

In development mode (irb): `rake console`

To run: `tairu -c /path/to/config/file`

Example config file:

```ruby

cache:
  name: tairu_config_example
  type: memory
  layers:
    geo:
      provider: mbtiles
      tileset: geography-class.mbtiles
      location: ~/.tairu/tilesets
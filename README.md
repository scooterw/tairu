tairu ... simple map tile server

In development mode (irb): `rake console`

To run: `tairu -c /path/to/config/file`

Example config file:

```ruby

name: tairu_config_example
cache:
  type: memory
layers:
  geo:
    provider: mbtiles
    tileset: geography-class.mbtiles
    location: ~/.tairu/tilesets
    format: png

```

Tairu relies on a valid configuration object assigned to `Tairu.config`

This may be read from a yaml file (see example above) using `Tairu.config_from_file(file_name)`

or by assigning default values for layers, cache, and name (optional):

```ruby

layers = {
  'geo' => {
    'provider' => 'mbtiles',
    'tileset' => 'geography-class.mbtiles',
    'location' => '~/.tairu/tilesets',
    'format' => 'png'
  }
}

cache = Tairu::Configuration.start_cache('memory', {})

name = 'tairu_config_example'

Tairu.config = Tairu::Configuration.new(layers, cache, name)

Tairu.cache = Tairu.config.cache

```
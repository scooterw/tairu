[![Build Status](https://travis-ci.org/scooterw/tairu.png?branch=master)](https://travis-ci.org/scooterw/tairu)

tairu ... simple map tile server

In development mode (irb): `rake console`

To run from bin: `tairu --config /path/to/config/file`

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

Configuration may be read from a yaml file (see example above) using `Tairu.config_from_file(file_name)`
or by passing values for layers, cache, and name (optional) into a configuration block:

```ruby
layers = {
  'geo' => {
    'provider' => 'mbtiles',
    'tileset' => 'geography-class.mbtiles',
    'location' => '~/.tairu/tilesets',
    'format' => 'png'
  }
}

cache = {
  'type' => 'redis',
  'options' => {
    'host' => 'localhost',
    'port' => '6379',
    'db' => 0
  }
}

Tairu.configure do |config|
  config.name = 'tairu_config_example'
  config.layers = layers
  config.cache = cache
end
```

NOTE: If no cache is passed in, it will default to the memory cache

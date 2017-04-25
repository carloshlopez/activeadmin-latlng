# ActiveadminLatlng

Active Admin latitude and longitude plugin

![alt tag](https://raw.githubusercontent.com/forsaken1/activeadmin-latlng/master/aa_latlng.png)



## Getting started

```ruby
gem 'activeadmin_latlng'
```

```ruby
form do |f|
  f.inputs do
    f.input :lat
    f.input :lng
    f.latlng # add this
  end
  f.actions
end
```



## Settings

* `lang` - language, `en` by default.

* `map` - map provider, `google` by default. Available: `google`, `yandex`.

* `id_lat` and `id_lng` - identificator of latitude and longitude inputs. `<model_name>_lat` and `<model_name>_lng` by default.

* `height` - map height in pixels, `400` by default.

* `loading_map` - loading map library. `true` by default. Set to `false`, if map loaded in other place.

* `use_geolocation` - Use current location to load map. `true` by default. Set to `false`, if you want to use default_lat and default_lng

* `default_lat` - Latitude to load map at start. `55.7522200` by default

* `default_lng` - Longitude to load map at start. `37.6155600` by default


### Example

```ruby
form do |f|
  f.inputs do
    f.input :lat
    f.input :lng
    f.latlng lang: :ru, map: :yandex, height: 500, loading_map: false
  end
  f.actions
end
```



## Contributors

Alexey Krylov

## License

MIT License. Copyright 2016 Alexey Krylov

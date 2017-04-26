module ActiveAdmin
  module Views
    class ActiveAdminForm
      def latlng **args
        class_name = form_builder.object.class.model_name.element
        lang   = args[:lang]   || 'en'
        map    = args[:map]    || :google
        id_lat = args[:id_lat] || "#{class_name}_lat"
        id_lng = args[:id_lng] || "#{class_name}_lng"
        height = args[:height] || 400
        default_lat = args[:default_lat] || 55.7522200
        default_lng = args[:default_lng] || 37.6155600
        loading_map = args[:loading_map].nil? ? true : args[:loading_map]
        use_geolocation = args[:use_geolocation].nil? ? true : args[:use_geolocation]

        case map
        when :yandex
          insert_tag(YandexMapProxy, form_builder, lang, id_lat, id_lng, height, loading_map)
        when :google
          insert_tag(GoogleMapProxy, form_builder, lang, id_lat, id_lng, height, loading_map, default_lat, default_lng, use_geolocation)
        else
          insert_tag(GoogleMapProxy, form_builder, lang, id_lat, id_lng, height, loading_map, default_lat, default_lng, use_geolocation)
        end
      end
    end

    class LatlngProxy < FormtasticProxy
      def build(form_builder, *args, &block)
        @lang, @id_lat, @id_lng, @height, @loading_map, @default_lat, @default_lng, @use_geolocation = *args
      end
    end

    class GoogleMapProxy < LatlngProxy
      def to_s
        loading_map_code = @loading_map ? "<script src=\"https://maps.googleapis.com/maps/api/js?language=#{@lang}&callback=googleMapObject.init\" async defer></script>" : ''
        "<li>" \
        "#{loading_map_code}" \
        "<div id=\"google_map\" style=\"height: #{@height}px\"></div>" \
        "<script>
          var googleMapObject = {
            coords: null,
            map: null,
            marker: null,
            
            recenterMap: function(){
              if(#{@use_geolocation}){
                console.log('Recentering map');    
                
                if (navigator.geolocation) {
                    navigator.geolocation.getCurrentPosition(function(position) {
                      var pos = {
                        googleMapObject.coords = { lat: position.coords.latitude, lng: position.coords.longitude };
                        googleMapObject.saveCoordinates();
                      };
          
                    }, function() {
                      console.log('No geologation available');
                    });
                  } else {
                    // Browser doesn't support Geolocation
                    console.log('No geologation available');
                  }
                
                
            },

            getCoordinates: function() {
                return {
                  lat: parseFloat($(\"##{@id_lat}\").val()) || #{@default_lat},
                  lng: parseFloat($(\"##{@id_lng}\").val()) || #{@default_lng},
                };
            },
            

            saveCoordinates: function() {
              console.log('Saving coordinates');
              $(\"##{@id_lat}\").val( googleMapObject.coords.lat.toFixed(10) );
              $(\"##{@id_lng}\").val( googleMapObject.coords.lng.toFixed(10) );
            },

            init: function() {
              googleMapObject.coords = googleMapObject.getCoordinates();
              googleMapObject.saveCoordinates();

              googleMapObject.map = new google.maps.Map(document.getElementById('google_map'), {
                center: googleMapObject.coords,
                zoom: 12
              });
              
              var latLngCoord = new google.maps.LatLng(googleMapObject.coords.lat, googleMapObject.coords.lng);
              googleMapObject.marker = new google.maps.Marker({
                position: latLngCoord,
                map: googleMapObject.map,
                draggable: true
              });
              googleMapObject.map.addListener('click', function(e) {
                googleMapObject.coords = { lat: e.latLng.lat(), lng: e.latLng.lng() };
                googleMapObject.saveCoordinates();
                googleMapObject.marker.setPosition(googleMapObject.coords);
              });
              googleMapObject.marker.addListener('drag', function(e) {
                googleMapObject.coords = { lat: e.latLng.lat(), lng: e.latLng.lng() };
                googleMapObject.saveCoordinates();
              });
              
              googleMapObject.recenterMap();
              
            }
          }
        </script>" \
        "</li>"
      end
    end

    class YandexMapProxy < LatlngProxy
      def to_s
        loading_map_code = @loading_map ? "<script src=\"https://api-maps.yandex.ru/2.1/?lang=#{@lang}&load=Map,Placemark\" type=\"text/javascript\"></script>" : ''
        "<li>" \
        "#{loading_map_code}" \
        "<div id=\"yandex_map\" style=\"height: #{@height}px\"></div>" \
        "<script type=\"text/javascript\">
          var yandexMapObject = {
            coords: null,
            map: null,
            placemark: null,

            getCoordinates: function() {
              return [
                parseFloat($(\"##{@id_lat}\").val()) || 55.7522200,
                parseFloat($(\"##{@id_lng}\").val()) || 37.6155600,
              ];
            },

            saveCoordinates: function() {
              $(\"##{@id_lat}\").val( yandexMapObject.coords[0].toFixed(10) );
              $(\"##{@id_lng}\").val( yandexMapObject.coords[1].toFixed(10) );
            },

            init: function() {
              yandexMapObject.coords = yandexMapObject.getCoordinates();
              yandexMapObject.saveCoordinates();

              yandexMapObject.map = new ymaps.Map(\"yandex_map\", {
                  center: yandexMapObject.coords,
                  zoom: 12
              });

              yandexMapObject.placemark = new ymaps.Placemark( yandexMapObject.coords, {}, { preset: \"twirl#redIcon\", draggable: true } );
              yandexMapObject.map.geoObjects.add(yandexMapObject.placemark);

              yandexMapObject.placemark.events.add(\"dragend\", function (e) {      
                yandexMapObject.coords = this.geometry.getCoordinates();
                yandexMapObject.saveCoordinates();
              }, yandexMapObject.placemark);

              yandexMapObject.map.events.add(\"click\", function (e) {        
                yandexMapObject.coords = e.get(\"coords\");
                yandexMapObject.saveCoordinates();
                yandexMapObject.placemark.geometry.setCoordinates(yandexMapObject.coords);
              });
            }
          }

          ymaps.ready(yandexMapObject.init);
        </script>" \
        "</li>"
      end
    end
  end
end
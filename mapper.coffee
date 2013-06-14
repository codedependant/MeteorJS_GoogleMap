Positions = new Meteor.Collection("positions")
map = {}

if Meteor.isClient
  
  Template.list.positions = ()->
    Positions.find({}, {sort: {created_at: -1}})

  Template.list.events
    "click #marker_add" : (event)->
      markerText = $("#marker_text").val()
      $("#marker_text").val("")
      radius = 0.001
      navigator.geolocation.getCurrentPosition (location)=>
        coords = location.coords
        Positions.insert
          created_at: new Date().getTime()
          text: markerText
          lat:  coords.latitude + (Math.random() * radius - radius/2)
          lng:  coords.longitude + (Math.random() * radius - radius/2)

        latlong = new google.maps.LatLng(coords.latitude, coords.longitude)
        map.setCenter(latlong)


  Meteor.startup ->
    $.getScript "http://www.google.com/jsapi", ()->
        google.load 'maps', '3',
          other_params: 'sensor=false'
          callback: ()->
            mapOptions =
              zoom: 8
              center: new google.maps.LatLng(-26.021865244363543, 28.017207142805116 )
              mapTypeId: google.maps.MapTypeId.ROADMAP
            map = new google.maps.Map(document.getElementById("map_canvas"), mapOptions)

            Positions.find().observe
              added : (position)->
                latlong = new google.maps.LatLng(position.lat,position.lng)
                marker = new google.maps.Marker({position: latlong, map: map})
                infowindow = new google.maps.InfoWindow
                  content: position.text or "no comment"
                google.maps.event.addListener marker, "click", ()=>
                  infowindow.open(map, marker)

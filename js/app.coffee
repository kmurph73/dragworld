_ = @_
window.data = data = {
  open_countries: []
  loaded_countries: []
}
loadedCountries = data.loaded_countries
openCountries = data.open_countries

getLoadedCountry = (name) ->
  _.find loadedCountries, (loadedCountry) -> loadedCountry.name == name

loadCountry = (c) ->
  country = getLoadedCountry(c.name)
  if not country
    loadedCountries.push c
    renderCountries()

renderCountries = ->
  oDiv = $('#open_countries').empty()

  for c in loadedCountries
    html = "<span id='#{c.abbrev}'>#{c.name}</span>"
    oDiv.append "<div>" + html + " <a href='#' class='remove'>remove</a>
      <a href='#' class='refresh'>refresh</a></div>"

initialize = ->
  mapOptions =
    zoom: 3
    center: new google.maps.LatLng(24.4441, 121.19313333333334)
    mapTypeId: google.maps.MapTypeId.TERRAIN

  data.map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions)

removeFromMap = (c) ->

$ ->
  meta = window.meta
  country_names = _.map meta, (c) -> c.name

  $('input').typeahead(
    name: 'countries',
    local: country_names,
    limit: 10
  ).on 'typeahead:selected', (e,selected, dataName) ->
    val = selected.value
    country = getLoadedCountry(val)

    if country
      displayCountry(country)
    else
      map = data.map
      country = _.find(meta, (c) -> val == c.name)
      country.polygons = polys = []

      $.getJSON("public/data/countries/#{country.abbrev}.json").then (resp) ->
        for poly in resp.polygons
          coords = []
          for point in poly.points
            if point.length == 2
              coords.push(new google.maps.LatLng(point[0], point[1]))

          polygon = {}

          polygon = new google.maps.Polygon(
            map: map
            paths: coords
            strokeColor: "#FF0000"
            strokeOpacity: 0.8
            strokeWeight: 1
            fillColor: "#FF0000"
            fillOpacity: 0.35
            draggable: true
            geodesic: true
          )

          polys.push polygon
        loadCountry(country)

  ##for country in window.data.views[0].features
  ##  if country.id == 'JP'
  ##    for pg in country.polygons
  ##      c = []
  ##      for coord in pg.shell
  ##        c.push new google.maps.LatLng(coord[0],coord[1])
  ##      myCoords.push c
  ##
  #$.getJSON('public/data/countries/taiwan.json').then(
  #  (tw) ->
  #    for p in tw.polygons
  #      coords = []
  #      for point in p.points
  #        if point.length == 2
  #          coords.push(new google.maps.LatLng(point[0], point[1]))

  #      if arr = 1
  #        new google.maps.Polygon(
  #          map: map
  #          paths: coords
  #          strokeColor: "#FF0000"
  #          strokeOpacity: 0.8
  #          strokeWeight: 1
  #          fillColor: "#FF0000"
  #          fillOpacity: 0.35



google.maps.event.addDomListener window, "load", initialize

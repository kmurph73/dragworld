_ = @_

window.data = data = {
  open_countries: []
}

openCountries = data.open_countries

getOpenCountry = (name, prop = 'name') ->
  _.find openCountries, (c) -> c[prop] == name

loadCountry = (c) ->
  country = getOpenCountry(c.name)
  if not country
    openCountries.push c
    renderCountries()

$ ->
  $(document).on 'mouseenter', '.tip', -> $(this).tooltip().tooltip('show')
  $(document).on 'mouseleave', '.tip', -> $(this).tooltip('hide')

renderCountries = ->
  oDiv = $('#open_countries').empty()

  len = openCountries.length
  for c,index in openCountries
    html =
     "<span id='#{c.abbrev}'>#{c.name}
        <a href='#' class='tip remove' title='remove'>x</a>
        <a href='#' class='tip reset' title='reset'>r</a>
      </span>"

    if index + 1 != len
      html += " - "

    oDiv.append html


  index = _.indexOf(openCountries, c)

initialize = ->
  mapOptions =
    zoom: 3
    center: new google.maps.LatLng(24.4441, 121.19313333333334)
    mapTypeId: google.maps.MapTypeId.TERRAIN

  data.map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions)

removeCountry = (c) ->
  removePolygons(c)
  openCountries = _.without openCountries, c
  renderCountries()

removePolygons = (c) ->
  for poly in c.polygons
    poly.setMap(null)

resetCountry = (c) ->
  removePolygons(c)
  renderPolygons(c)

renderPolygons = (country) ->
  country.polygons = polys = []
  map = data.map

  for poly in country.data.polygons
    coords = []
    for point in poly.points
      if point.length == 2
        coords.push(new google.maps.LatLng(point[0], point[1]))

    polygon = {}

    polygon = new google.maps.Polygon
      map: map
      paths: coords
      strokeColor: "#FF0000"
      strokeOpacity: 0.8
      strokeWeight: 1
      fillColor: "#FF0000"
      fillOpacity: 0.35
      draggable: true
      geodesic: true

    polys.push polygon

$ ->
  meta = window.meta
  country_names = _.map meta, (c) -> c.name

  $('input').typeahead(
    name: 'countries',
    local: country_names,
    limit: 10
  ).on 'typeahead:selected', (e,selected, dataName) ->
    target = $(e.currentTarget)
    target.val('')

    val = selected.value

    map = data.map

    country = getOpenCountry(val)
    if not country
      country = _.find(meta, (c) -> val == c.name)

      $.getJSON("public/data/countries/#{country.abbrev}.json").then (resp) ->
        country.data = resp
        renderPolygons(country)

        loadCountry(country)

  $('#open_countries').on 'click', 'a', (e) ->
    e.preventDefault()
    target = $(e.currentTarget)

    abbrev = target.closest('span').attr('id')
    country = getOpenCountry abbrev, 'abbrev'

    if target.hasClass('remove')
      removeCountry(country)
    else if target.hasClass('reset')
      resetCountry(country)


google.maps.event.addDomListener window, "load", initialize

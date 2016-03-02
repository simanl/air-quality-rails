# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
findAssociated = (reference, associations) ->
  associations.find (element) ->
    element.type == reference.type && element.id = reference.id

displayFetchedData = (response) ->
  lastMeasurement = findAssociated response.data.relationships.last_measurement.data, response.included
  console.log lastMeasurement

  imecaPoints = if lastMeasurement.attributes.imeca_points?
    lastMeasurement.attributes.imeca_points
  else
    "N/A"

  jQuery(".imeca-points.value").html imecaPoints
  jQuery(".imeca-category.value").html lastMeasurement.attributes.imeca_category || "N/A"
  jQuery(".wind-speed.value").html lastMeasurement.attributes.wind_speed || "N/A"
  jQuery(".temperature.value").html lastMeasurement.attributes.temperature || "N/A"
  jQuery(".toracic-particles.value").html lastMeasurement.attributes.toracic_particles || "N/A"
  jQuery(".respirable-particles.value").html lastMeasurement.attributes.respirable_particles || "N/A"
  jQuery(".ozone.value").html lastMeasurement.attributes.ozone || "N/A"

fetchData = (latlon)->
  stationPath = "/3.json?"
  stationPath = "/nearest_from.json?latlon=#{latlon}" if latlon
  path = "/stations#{stationPath}&include=last_measurement"

  console.log "fetching data from #{path}..."
  jQuery.getJSON path, displayFetchedData


geoSuccess = (position) ->
  latlon = "#{position.coords.latitude},#{position.coords.longitude}"
  fetchData latlon

geoFailure = (error) ->
  console.log 'Geolocation error occurred. Error code: ' + error.code
  fetchData()


$(document).on 'ready page:load', ->

  $('.modal-content').easyModal
    top: 'auto',
    overlayOpacity: 0.6,
    overlayColor: "#fff"

  $('.modal-link').on 'click', (e) ->
    e.preventDefault()
    $($(@).data('modal')).trigger 'openModal'

  # check for Geolocation support
  if (navigator.geolocation)
    console.log 'Geolocation is supported!'
    navigator.geolocation.getCurrentPosition geoSuccess, geoFailure
  else
    console.log 'Geolocation is not supported for this Browser/OS version yet.'
    fetchData()

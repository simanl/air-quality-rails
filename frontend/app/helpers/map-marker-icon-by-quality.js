import Ember from 'ember';

export function mapMarkerIconByQuality(params/*, hash*/) {

  let quality = params[0];
  if (typeof quality === 'undefined' || quality === null) {
    quality = "not_available";
  }

  if (!window.aireNlMapMarkers || !window.aireNlMapMarkers[quality]) {
    Ember.Logger.error('No mapMarkerIcon found for ' + quality);
  }

  return `/${window.aireNlMapMarkers[quality]}`;
}

export default Ember.Helper.helper(mapMarkerIconByQuality);

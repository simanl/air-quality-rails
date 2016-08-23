import Ember from 'ember';

export function mapMarkerIconByQuality(params/*, hash*/) {
  let quality = params[0];
  if (typeof quality === 'undefined' || quality === null) {
    quality = "not_available";
  }
  return `/assets/images/map-markers/${quality}.png`;
}

export default Ember.Helper.helper(mapMarkerIconByQuality);

import Ember from 'ember';

export function temperature(params/*, hash*/) {
  var temperature = params.get("firstObject");
  if (temperature) {
    return `${Math.round(temperature)}°`;
  } else {
    return "N.D.";
  }
}

export default Ember.Helper.helper(temperature);

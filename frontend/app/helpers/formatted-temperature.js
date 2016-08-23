import Ember from 'ember';

export function temperature(params, hash) {
  let temperature = params.get("firstObject");
  let coalesceWith = hash.coalesceWith || "--";
  if (typeof temperature !== 'undefined' && temperature !== null) {
    return `${Math.round(temperature)}°`;
  } else {
    return coalesceWith;
  }
}

export default Ember.Helper.helper(temperature);

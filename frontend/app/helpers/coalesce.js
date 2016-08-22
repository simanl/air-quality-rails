import Ember from 'ember';

export function coalesce(params/*, hash*/) {
  let coalesceable = params[0];
  let devaultValue = params[1];
  if (typeof coalesceable !== 'undefined' && coalesceable !== null) {
    return coalesceable;
  } else {
    return devaultValue;
  }
}

export default Ember.Helper.helper(coalesce);

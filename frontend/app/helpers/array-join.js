import Ember from 'ember';

export function arrayJoin(params/*, hash*/) {
  let [arr, separator] = params;
  return arr.join(separator);
}

export default Ember.Helper.helper(arrayJoin);

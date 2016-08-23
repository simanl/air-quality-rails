import Ember from 'ember';

export function arrayJoin(params/*, hash*/) {
  let [arr, separator] = params;
  if (typeof arr === 'undefined' || arr === null) { arr = []; }
  if (typeof separator === 'undefined' || separator === null) { separator = ' '; }
  return arr.join(separator);
}

export default Ember.Helper.helper(arrayJoin);

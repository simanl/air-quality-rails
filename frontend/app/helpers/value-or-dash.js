import Ember from 'ember';

export function valueOrDash(params/*, hash*/) {
  var value = params.get("firstObject");
  if (value) { return value; }
  else { return "--"; }
}

export default Ember.Helper.helper(valueOrDash);

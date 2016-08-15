import Ember from 'ember';

export function hour(params/*, hash*/) {
  var date = params.get("firstObject");
  return String("00" + date.getHours()).slice(-2) + ":00";
}

export default Ember.Helper.helper(hour);

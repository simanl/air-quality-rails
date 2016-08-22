import Ember from 'ember';
import DS from 'ember-data';

export default DS.Model.extend({
  code: DS.attr('string'),
  name: DS.attr('string'),
  shortName: DS.attr('string'),
  latlon: DS.attr('string'),

  latitude: Ember.computed('latlon', function() {
    return this.get('latlon').split(',')[0];
  }),

  longitude: Ember.computed('latlon', function() {
    return this.get('latlon').split(',')[1];
  }),

  measurements: DS.hasMany("measurement", { inverse: "station" }),
  lastMeasurement: DS.belongsTo("measurement", { inverse: null }),

  forecasts: DS.hasMany("forecast", { inverse: "station" }),
  currentForecasts: DS.hasMany("forecast", { inverse: null })
});

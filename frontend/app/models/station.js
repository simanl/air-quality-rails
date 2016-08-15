import DS from 'ember-data';

export default DS.Model.extend({
  code: DS.attr('string'),
  name: DS.attr('string'),
  shortName: DS.attr('string'),

  measurements: DS.hasMany("measurement", { inverse: "station" }),
  lastMeasurement: DS.belongsTo("measurement", { inverse: null }),

  forecasts: DS.hasMany("forecast", { inverse: "station" }),
  currentForecasts: DS.hasMany("forecast", { inverse: null })
});

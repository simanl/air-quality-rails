import DS from 'ember-data';

export default DS.Model.extend({
  startsAt: DS.attr('date'),
  endsAt: DS.attr('date'),
  ozoneIndex: DS.attr('number'),
  ozoneCategory: DS.attr('string'),
  toracicParticlesIndex: DS.attr('number'),
  toracicParticlesCategory: DS.attr('string'),
  respirableParticlesIndex: DS.attr('number'),
  respirableParticlesCategory: DS.attr('string'),
  updatedAt: DS.attr('date'),

  station: DS.belongsTo('station', { inverse: "forecasts" })
});

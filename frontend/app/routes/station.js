import Ember from 'ember';
import CycloramaRouteMixin from '../mixins/cyclorama-route';

export default Ember.Route.extend(CycloramaRouteMixin, {
  model(params) {
    return this.get('store').findRecord('station', params.station_id, {
      reload: true,
      include: 'last_measurement,current_forecasts'
    });
  }
});

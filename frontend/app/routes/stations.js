import Ember from 'ember';
import CycloramaRouteMixin from '../mixins/cyclorama-route';

export default Ember.Route.extend(CycloramaRouteMixin, {
  setupController: function(controller, model) {
    this._super(controller, model);
    controller.setProperties({
      mapOptions: {
        draggable: false,
        streetViewControl: false,
        mapTypeControl: false
      }
    });
  },
  model() {
    return this.get('store').query('station', { include: 'last_measurement' });
  }
});

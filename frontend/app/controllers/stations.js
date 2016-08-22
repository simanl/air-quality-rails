import Ember from 'ember';

export default Ember.Controller.extend({
  actions: {
    goToStation: function(station) {
      // If a literal is passed (such as a number or a string), it will be
      // treated as an identifier instead. In this case, the model hook of the
      // route will be triggered:
      this.transitionToRoute('station', station.get("id"));
    },
  }
});

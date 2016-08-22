import Ember from 'ember';
import CycloramaRouteMixin from '../mixins/cyclorama-route';

export default Ember.Route.extend(CycloramaRouteMixin, {
  geolocation: Ember.inject.service(),

  model() {
    var self = this;
    return this.get('geolocation').getLocation().then(function(geoObject) {

      var filters = {
        nearest_from: (geoObject.coords.latitude.toString() + "," + geoObject.coords.longitude.toString()),
        include: "last_measurement,current_forecasts",
        page: { limit: 1 }
      };

      return self.get("store").query("station", filters).then(function(stations){
        return stations.get("firstObject");
      });
    }, function(error) {
      console.warn(error);
      // If we can't get the user's current location (commonly because of
      // https://goo.gl/rStTGz), then we'll return the "Centro Obispado" station
      return self.get("store").findRecord("station", 3, {
        reload: true,
        include: "last_measurement,current_forecasts"
      });
    });
  }
});

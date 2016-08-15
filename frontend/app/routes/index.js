import Ember from 'ember';

export default Ember.Route.extend({
  geolocation: Ember.inject.service(),

  activate: function() {
    var cssClass = this.toCssClass();
    // you probably don't need the application class
    // to be added to the body
    if (cssClass !== 'application') {
      Ember.$('body').addClass(cssClass);
    }
  },

  deactivate: function() {
    Ember.$('body').removeClass(this.toCssClass());
  },

  toCssClass: function() {
    var current = new Date();
    var currentHourDecimal = current.getHours() + (current.getMinutes() * (1/60));
    var backgroundName = "night";
    if (currentHourDecimal >= 18.5 && currentHourDecimal <= 19.5) { backgroundName = "sunset"; }
    else if (currentHourDecimal >= 6.5 && currentHourDecimal < 18.5) { backgroundName = "day"; }

    return this.routeName.replace(/\./g, '-').dasherize() + " " + backgroundName;
  },

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
        include: "last_measurement,current_forecasts"
      });
    });
  }
});

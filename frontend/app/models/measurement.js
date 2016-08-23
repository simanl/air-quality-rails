import Ember from "ember";
import DS from 'ember-data';

export default DS.Model.extend({
  measuredAt: DS.attr("date"),
  temperature: DS.attr("number"),
  relativeHumidity: DS.attr("number"),
  windDirection: DS.attr("number"),
  windSpeed: DS.attr("number"),
  imecaPoints: DS.attr("number"),
  imecaCategory: DS.attr("string"),
  precipitation: DS.attr("string"),
  carbonMonoxide: DS.attr("number"),
  nitricOxide: DS.attr("number"),
  nitrogenDioxide: DS.attr("number"),
  nitrogenOxides: DS.attr("number"),
  ozone: DS.attr("number"),
  sulfurDioxide: DS.attr("number"),
  toracicParticles: DS.attr("number"),
  respirableParticles: DS.attr("number"),

  station: DS.belongsTo("station", { inverse: "measurements" }),

  recommendedActivities: Ember.computed("imecaCategory", {
    get() {
      switch(this.get("imecaCategory")) {
        case "extremely_bad":
          return ["no-exercise", "no-outdoors", "no-sensible", "window", "limited-heart", "no-car", "no-fuel", "no-smoking"];
        case "very_bad":
          return ["no-exercise", "no-outdoors", "no-sensible", "window", "limited-heart", "limited-car", "no-fuel", "limited-smoking"];
        case "bad":
          return ["limited-exercise", "limited-outdoors", "no-sensible"];
        case "good":
          return ["exercise", "outdoors", "sensible"];
        case "regular":
          return ["exercise", "outdoors", "limited-sensible"];
        default:
          return [];
      }
    }
  })
});

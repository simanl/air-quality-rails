import Ember from 'ember';

export default Ember.Mixin.create({
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
  }
});

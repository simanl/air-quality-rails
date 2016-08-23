import Ember from 'ember';
import jQuery from "jquery";

export default Ember.Component.extend({
  tagName: "article",
  classNames: ["item forecast pollutant-forecasts-indicator"],
  classNameBindings: ['isAvailable::unavailable'],
  isAvailable: Ember.computed('forecasts', {
    get() {
      let forecasts = this.get('forecasts');
      return (typeof forecasts !== 'undefined' && forecasts !== null && forecasts.get("length") > 0);
    }
  }),
  didInsertElement() {
    this.$().find('.modal-link').on('click', function(e){
      e.preventDefault();
      jQuery(jQuery(e.currentTarget).data("modal")).trigger('openModal');
    });
  }
});

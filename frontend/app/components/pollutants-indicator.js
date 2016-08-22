import Ember from 'ember';
import jQuery from "jquery";

export default Ember.Component.extend({
  tagName: "article",
  classNames: ["item pollutants-indicator"],
  didInsertElement() {
    this.$().find('.modal-link').on('click', function(e){
      e.preventDefault();
      jQuery(jQuery(e.currentTarget).data("modal")).trigger('openModal');
    });
  }
});

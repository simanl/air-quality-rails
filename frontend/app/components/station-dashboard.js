import Ember from 'ember';
import jQuery from "jquery";

export default Ember.Component.extend({
  didInsertElement() {
    jQuery(".modal-content").easyModal({
      top: "auto",
      overlayOpacity: 0.3,
      overlayColor: "#333",
      onOpen: function() { jQuery("body").addClass("blur"); },
      onClose: function() { jQuery("body").removeClass("blur"); }
    });
  }
});

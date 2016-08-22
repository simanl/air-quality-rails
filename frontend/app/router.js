import Ember from 'ember';
import config from './config/environment';

const Router = Ember.Router.extend({
  location: config.locationType,
  rootURL: config.rootURL
});

Router.map(function() {
  this.route('stations', { path: "/stations" });
  this.route("station", { path: "/stations/:station_id" });
});

export default Router;

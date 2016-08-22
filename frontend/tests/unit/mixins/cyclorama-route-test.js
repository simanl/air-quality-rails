import Ember from 'ember';
import CycloramaRouteMixin from 'frontend/mixins/cyclorama-route';
import { module, test } from 'qunit';

module('Unit | Mixin | cyclorama route');

// Replace this with your real tests.
test('it works', function(assert) {
  let CycloramaRouteObject = Ember.Object.extend(CycloramaRouteMixin);
  let subject = CycloramaRouteObject.create();
  assert.ok(subject);
});

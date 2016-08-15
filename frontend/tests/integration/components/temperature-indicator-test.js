import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('temperature-indicator', 'Integration | Component | temperature indicator', {
  integration: true
});

test('it renders', function(assert) {
  // Set any properties with this.set('myProperty', 'value');
  // Handle any actions with this.on('myAction', function(val) { ... });

  this.render(hbs`{{temperature-indicator}}`);

  assert.equal(this.$().text().trim(), '');

  // Template block usage:
  this.render(hbs`
    {{#temperature-indicator}}
      template block text
    {{/temperature-indicator}}
  `);

  assert.equal(this.$().text().trim(), 'template block text');
});

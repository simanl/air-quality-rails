import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('pollutants-indicator', 'Integration | Component | pollutants indicator', {
  integration: true
});

test('it renders', function(assert) {
  // Set any properties with this.set('myProperty', 'value');
  // Handle any actions with this.on('myAction', function(val) { ... });

  this.render(hbs`{{pollutants-indicator}}`);

  assert.equal(this.$().text().trim(), '');

  // Template block usage:
  this.render(hbs`
    {{#pollutants-indicator}}
      template block text
    {{/pollutants-indicator}}
  `);

  assert.equal(this.$().text().trim(), 'template block text');
});

import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('pollutant-forecasts-indicator', 'Integration | Component | pollutant forecasts indicator', {
  integration: true
});

test('it renders', function(assert) {
  // Set any properties with this.set('myProperty', 'value');
  // Handle any actions with this.on('myAction', function(val) { ... });

  this.render(hbs`{{pollutant-forecasts-indicator}}`);

  assert.equal(this.$().text().trim(), '');

  // Template block usage:
  this.render(hbs`
    {{#pollutant-forecasts-indicator}}
      template block text
    {{/pollutant-forecasts-indicator}}
  `);

  assert.equal(this.$().text().trim(), 'template block text');
});

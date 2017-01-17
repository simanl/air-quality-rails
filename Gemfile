source 'https://rubygems.org'

################################################################################
# App Ruby Version:

# Use MRI 2.2.5:
ruby '2.2.5', engine: 'ruby', engine_version: '2.2.5'

# Use JRuby 9.0.0.0:
# ruby '2.2.2', engine: 'jruby', engine_version: '9.0.0.0.pre2'

# Use Rubinius 2.5.3:
# ruby '2.1.0', engine: 'rbx', engine_version: '2.5.3'

################################################################################

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.7'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.15'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'rails_stdout_logging', group: :production

gem 'activerecord-postgis-adapter', '~> 3.0'
gem 'active_model_serializers', '~> 0.10.2'

# Libraries used to connect with the forecasts engine core:
gem 'rserve-client',  '~> 0.3.1', require: nil
gem 'rserve-simpler', '~> 0.0.6', require: nil

gem 'devise', '~> 4.2.0'

gem 'bootstrap-sass', '~> 3.3.6'

gem 'sinatra',  require: nil
gem 'sidekiq',           '~> 4.1.4'
gem 'sidekiq-scheduler', '~> 2.0.8'

gem 'faraday',     '~> 0.9.2'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Puma as the app server
gem 'puma', '~> 3.4.0'

gem 'ember-cli-rails', '~> 0.8.0'

# Guard setup for automatic testing:
group :development do
  gem 'guard',       '~> 2.14.0'
  gem 'guard-rspec', '~> 4.7.2', require: nil
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-commands-rspec', '~> 1.0.4'

  gem 'rspec-rails', '~> 3.5.1'
  gem 'factory_girl_rails', '~> 4.7.0'
end

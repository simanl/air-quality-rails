source 'https://rubygems.org'

################################################################################
# App Ruby Version:

# Use MRI 2.2.2:
ruby '2.2.3', engine: 'ruby', engine_version: '2.2.3'

# Use JRuby 9.0.0.0:
# ruby "2.2.2", engine: 'jruby', engine_version: '9.0.0.0.pre2'

# Use Rubinius 2.5.3:
# ruby "2.1.0", engine: 'rbx', engine_version: '2.5.3'

################################################################################

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.4'
# Use postgresql as the database for Active Record
gem 'pg'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'activerecord-postgis-adapter', '~> 3.0'
gem 'active_model_serializers', '~> 0.10.0.rc2', github: 'rails-api/active_model_serializers', branch: 'master'

gem 'whenever', require: false

# Libraries used to connect with the forecasts engine core:
gem 'rserve-client',  '~> 0.3.1', require: nil
gem 'rserve-simpler', '~> 0.0.6', require: nil

# Gem used on the demo to generate the measurement data from cycle CVS files:
gem 'msgpack', '~> 0.6.2', require: nil

gem 'sidekiq',     '~> 3.4.2'
gem 'faraday',     '~> 0.9'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Puma as the app server
gem 'puma', '~> 2.13.4'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Guard setup for automatic testing:
group :development do
  gem 'guard',       '~> 2.13.0'
  gem 'guard-rspec', '~> 4.6.4', require: false
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  gem 'pry-rails'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'rspec-rails', '~> 3.0'

  gem 'factory_girl_rails', '~> 4.5'
end

# This Dockerfile is intended to build a production-ready Docker container with
# the app... however, further shrinking can be achieved...
# See - for example - https://blog.jtlebi.fr/2015/04/25/how-i-shrunk-a-docker-image-by-98-8-featuring-fanotify
FROM ruby:2.2.3
MAINTAINER Roberto Quintanilla <vov@icalialabs.com>

ENV PATH=/usr/src/app/bin:$PATH RAILS_ENV=production RACK_ENV=production

ADD . /usr/src/app
WORKDIR /usr/src/app

RUN bundle install --deployment --without development test
RUN rake assets:precompile

# The base image has an 'ONBUILD' command that should run `bundle install --deployment --without development test`

# Default command starts the rails server:
CMD ["rails","server", "-p", "3000","-b","0.0.0.0"]

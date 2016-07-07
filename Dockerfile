# This Dockerfile is intended to build a production-ready Docker container with
# the app... however, further shrinking can be achieved...
# See - for example - https://blog.jtlebi.fr/2015/04/25/how-i-shrunk-a-docker-image-by-98-8-featuring-fanotify
FROM ruby:2.2.5-alpine
MAINTAINER Roberto Quintanilla <vov@icalialabs.com>

ENV PATH=/usr/src/app/bin:$PATH RAILS_ENV=production
WORKDIR /usr/src/app

# 1: Install dependencies:

# 1.1: Copy just the Gemfile & Gemfile.lock, to avoid the build cache failing
# whenever any other file changed and installing dependencies all over again - a
# must if your'e developing this Dockerfile...
ADD ./Gemfile* /usr/src/app/

# 1.2: Install dependencies (including nginx and supervisord):
# NGINX Config/Installation
RUN set -ex \
  && echo "Installing nginx & supervisord" \
	&& apk add --no-cache --virtual .app-rundeps libpq nginx supervisor \
  && apk add --no-cache --virtual .app-builddeps build-base git postgresql-dev \
  && bundle install --deployment --without development test \
  && apk del .app-builddeps \
	&& ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

# 2: Add the application code:

# 2.1: Copy the rest of the code, and then compile the assets:
ADD . /usr/src/app
RUN set -ex \
  && mkdir -p /usr/src/app/tmp/cache \
  && mkdir -p /usr/src/app/tmp/pids \
  && mkdir -p /usr/src/app/tmp/sockets \
  && DATABASE_URL=postgres://postgres@example.com:5432/fakedb \
  TWITTER_API_KEY=SOME_KEY TWITTER_API_SECRET=SOME_SECRET \
  SECRET_KEY_BASE=10167c7f7654ed02b3557b05b88ece \
  rake assets:precompile \
  && chown -R nobody /usr/src/app

# 3: Expose the following ports:
# - Port 3000 for the Rails web process
EXPOSE 3000

# 4: Set the user used to run the process to a 'nobody' unprivileged user:
USER nobody

# 5: Set the default Puma config values:
ENV PUMA_MIN_THREADS=8 PUMA_MAX_THREADS=12 PUMA_WORKR_COUNT=2

# 6: Set the default command:
CMD bundle exec puma --bind tcp://0.0.0.0:3000

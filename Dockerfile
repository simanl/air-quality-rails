# This Dockerfile is intended to build a production-ready Docker container with
# the app... however, further shrinking can be achieved...
# See - for example - https://blog.jtlebi.fr/2015/04/25/how-i-shrunk-a-docker-image-by-98-8-featuring-fanotify
FROM ruby:2.2.5-slim
MAINTAINER Roberto Quintanilla <vov@icalialabs.com>

ENV PATH=/usr/src/app/bin:$PATH RAILS_ENV=production
WORKDIR /usr/src/app

# 1: Install dependencies:

# 1.1: Copy just the Gemfile & Gemfile.lock, to avoid the build cache failing
# whenever any other file changed and installing dependencies all over again - a
# must if your'e developing this Dockerfile...
ADD ./Gemfile* /usr/src/app/

# 1.2: Install dependencies (including nginx and supervisord):
RUN set -ex \
  && apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 \
  && echo "deb http://nginx.org/packages/mainline/debian/ jessie nginx" >> /etc/apt/sources.list \
  && apt-get update \
  && runDeps=' \
      ca-certificates \
      gettext-base \
      libpq5 \
      nginx=1.9.11-1~jessie \
      supervisor \
  ' \
  && buildDeps=' \
      autoconf \
      g++ \
      gcc \
      git \
      libpq-dev \
      libxml2-dev \
      libxslt-dev \
      make \
      patch \
  ' \
  && apt-get install -y --no-install-recommends $runDeps $buildDeps \
  && rm -rf /var/lib/apt/lists/* \
  && bundle install --deployment --without development test \
  && apt-get purge -y --auto-remove $buildDeps \
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

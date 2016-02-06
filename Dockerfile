# This Dockerfile is intended to build a production-ready Docker container with
# the app... however, further shrinking can be achieved...
# See - for example - https://blog.jtlebi.fr/2015/04/25/how-i-shrunk-a-docker-image-by-98-8-featuring-fanotify
FROM ruby:2.2.4-slim
MAINTAINER Roberto Quintanilla <vov@icalialabs.com>

ENV PATH=/usr/src/app/bin:$PATH RAILS_ENV=production RACK_ENV=production

ADD . /usr/src/app
WORKDIR /usr/src/app

RUN set -ex \
  && apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 \
  && echo "deb http://nginx.org/packages/mainline/debian/ jessie nginx" >> /etc/apt/sources.list \
  && apt-get update \
  && runDeps=' \
    ca-certificates \
    gettext-base \
    libpq5 \
    nginx=1.9.10-1~jessie \
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
  && rake assets:precompile \
  && ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

# Expose the HTTP port:
EXPOSE 80

ENTRYPOINT ["/usr/src/app/entrypoint.sh"]

# Default command starts the web server:
CMD ["/usr/bin/supervisord", "--configuration=/usr/src/app/config/supervisord-web.conf"]

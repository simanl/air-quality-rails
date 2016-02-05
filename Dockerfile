# This Dockerfile is intended to build a production-ready Docker container with
# the app... however, further shrinking can be achieved...
# See - for example - https://blog.jtlebi.fr/2015/04/25/how-i-shrunk-a-docker-image-by-98-8-featuring-fanotify
FROM ruby:2.2.4
MAINTAINER Roberto Quintanilla <vov@icalialabs.com>

ENV PATH=/usr/src/app/bin:$PATH RAILS_ENV=production RACK_ENV=production

# NGINX Config/Installation
RUN echo "Installing nginx & supervisord" \
  && apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 \
	&& echo "deb http://nginx.org/packages/mainline/debian/ jessie nginx" >> /etc/apt/sources.list \
	&& apt-get update \
	&& apt-get install -y ca-certificates nginx=1.9.10-1~jessie gettext-base supervisor --no-install-recommends \
	&& rm -rf /var/lib/apt/lists/* \
	&& echo "Configuring forwarding of request and error logs to docker log collector" \
	&& ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

ADD . /usr/src/app
WORKDIR /usr/src/app

RUN echo "Installing app dependencies & precompiling assets" \
  && bundle install --deployment --without development test \
	&& rake assets:precompile

# Expose the HTTP port:
EXPOSE 80

ENTRYPOINT ["/usr/src/app/entrypoint.sh"]

# Default command starts the web server:
CMD ["/usr/bin/supervisord", "--configuration=/usr/src/app/config/supervisord-web.conf"]

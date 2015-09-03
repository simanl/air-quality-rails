# This Dockerfile is intended to build a production-ready Docker container with
# the app... however, further shrinking can be achieved...
# See - for example - https://blog.jtlebi.fr/2015/04/25/how-i-shrunk-a-docker-image-by-98-8-featuring-fanotify
FROM vovimayhem/app:mri-2.2.3
MAINTAINER Roberto Quintanilla <vov@icalialabs.com>

# Copying of the code, invoking bundle install, etc will be run by the 'ONBUILD'
# commands of the base image.

ENV RAILS_ENV=production RACK_ENV=production

# The base image has an 'ONBUILD' command that should run `bundle install --deployment --without development test`

# Default command starts the rails server:
CMD ["rails","server", "-p", "3000","-b","0.0.0.0"]

FROM ruby:2.2.5

WORKDIR /usr/src/app

ENV HOME=/usr/src/app \
    PATH=/usr/src/app/bin:$PATH

# Install the current project gems - they can be safely changed later during
# developmenr via `bundle install` or `bundle update`:
ADD Gemfile* /usr/src/app/
RUN bundle install

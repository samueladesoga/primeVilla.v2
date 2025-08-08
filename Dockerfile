# syntax = docker/dockerfile:1
ARG RUBY_VERSION=3.3.1
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# Install build tools + SQLite
RUN apt-get update -qq && \
    apt-get install -y build-essential sqlite3 libsqlite3-dev && \
    rm -rf /var/lib/apt/lists/*

# Bundle gems
COPY Gemfile* ./
RUN bundle install --jobs 4 --retry 3

# Copy app, precompile assets
COPY . .
RUN bundle exec rails assets:precompile

EXPOSE 3000
ENTRYPOINT ["/rails/bin/docker-entrypoint"]
CMD ["bundle", "exec", "foreman", "start"]

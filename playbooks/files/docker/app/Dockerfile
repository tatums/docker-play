FROM ruby:2.2.0

RUN apt-get update -qq
RUN apt-get install -y build-essential libpq-dev

WORKDIR /app
ADD . /app
RUN gem install bundler
RUN bundle install


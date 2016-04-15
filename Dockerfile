FROM rails:latest

RUN apt-get update && apt-get install -y netcat

RUN mkdir /web
WORKDIR /web

ADD Gemfile /web/Gemfile
ADD Gemfile.lock /web/Gemfile.lock

RUN bundle install

ADD . /web

#EXPOSE 3000
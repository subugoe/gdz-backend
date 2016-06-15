FROM rails:4.2

RUN apt-get update && apt-get install -y netcat

ENV EFFECTIVE_UID=10021
ENV EFFECTIVE_GID=999

RUN groupadd -r -g $EFFECTIVE_GID web && \
  useradd -r -u $EFFECTIVE_UID -g $EFFECTIVE_GID web

RUN mkdir /home/web
WORKDIR /home/web

ADD Gemfile /home/web/Gemfile
ADD Gemfile.lock /home/web/Gemfile.lock

RUN bundle install

ADD . /home/web

RUN RAILS_ENV=development rake db:migrate

USER web

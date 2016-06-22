FROM rails:4.2

RUN apt-get update && apt-get install -y netcat

ENV USER_UID=10021
ENV USER_GID=999

RUN groupadd -r -g $USER_GID web && \
  useradd -r -u $USER_UID -g $USER_GID web

RUN mkdir /home/web
WORKDIR /home/web

ADD Gemfile /home/web/Gemfile
ADD Gemfile.lock /home/web/Gemfile.lock

RUN bundle install

ADD . /home/web

RUN rake db:migrate

USER web

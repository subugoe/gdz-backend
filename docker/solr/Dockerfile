FROM    java:openjdk-8-jre
MAINTAINER  Jörg Panzer, SUB (based on https://github.com/docker-solr/docker-solr/blob/2e1ccd64970c65e7dacfe33203963b315f665cc3/5.5/Dockerfile)

RUN apt-get update && \
  apt-get -y install  lsof  vim && \
    rm -rf /var/lib/apt/lists/*


ENV EFFECTIVE_UID=10021
ENV EFFECTIVE_GID=999

RUN groupadd -r -g $EFFECTIVE_GID solr && \
  useradd -r -u $EFFECTIVE_UID -g $EFFECTIVE_GID solr


ENV SOLR_KEY 2C72EB1397733A551DDB60CCF119941F6E68DA61
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$SOLR_KEY"

ENV SOLR_VERSION 5.5.0
ENV SOLR_SHA256 c5fa5cb996fe1432e09bb2f6053ffbeb095436db4a77e9c6488b531db726b04d

RUN mkdir -p /opt/solr/gdz/data
RUN wget -nv --output-document=/opt/solr.tgz http://archive.apache.org/dist/lucene/solr/$SOLR_VERSION/solr-$SOLR_VERSION.tgz
RUN wget -nv --output-document=/opt/solr.tgz.asc http://archive.apache.org/dist/lucene/solr/$SOLR_VERSION/solr-$SOLR_VERSION.tgz.asc
RUN gpg --verify /opt/solr.tgz.asc
RUN echo "$SOLR_SHA256 */opt/solr.tgz" | sha256sum -c -
RUN tar -C /opt/solr --extract --file /opt/solr.tgz --strip-components=1
RUN rm /opt/solr.tgz*
RUN mkdir -p /opt/solr/server/solr/lib
RUN sed -i -e 's/#SOLR_PORT=8983/SOLR_PORT=8983/' /opt/solr/bin/solr.in.sh
RUN sed -i -e '/-Dsolr.clustering.enabled=true/ a SOLR_OPTS="$SOLR_OPTS -Dsun.net.inetaddr.ttl=60 -Dsun.net.inetaddr.negative.ttl=60"' /opt/solr/bin/solr.in.sh

RUN mkdir -p /opt/solr/gdz/conf
COPY  config/sub/solr.xml  /opt/solr/solr.xml
COPY  config/sub/zoo.cfg   /opt/solr/zoo.cfg
COPY  config/sub/core.properties /opt/solr/gdz/core.properties
COPY  config/sub/currency.xml /opt/solr/gdz/conf/currency.xml
COPY  config/sub/mapping-FoldToASCII.txt /opt/solr/gdz/conf/mapping-FoldToASCII.txt
COPY  config/sub/mapping-ISOLatin1Accent.txt /opt/solr/gdz/conf/mapping-ISOLatin1Accent.txt
COPY  config/schema.xml /opt/solr/gdz/conf/schema.xml
COPY  config/solrconfig.xml /opt/solr/gdz/conf/solrconfig.xml

RUN chown -R solr:solr /opt/solr

WORKDIR /opt/solr
USER solr
CMD ["/opt/solr/bin/solr", "-f"]

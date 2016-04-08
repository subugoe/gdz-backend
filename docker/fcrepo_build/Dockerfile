FROM java:openjdk-8-jdk

MAINTAINER  Jörg Panzer, SUB

ENV FEDORA_VERSION 4.5.0
ENV FEDORA_TAG 4.5.0
ENV FCREPO_GIT_DOWNLOAD  https://github.com/fcrepo4/fcrepo4/archive/fcrepo-$FEDORA_VERSION.tar.gz


ENV MAVEN_OPTS  "-Xmx1024m" -XX:MaxMetaspaceSize=1024m"
ENV MAVEN_VERSION 3.3.3
ENV MAVEN_HOME /usr/share/maven
ENV PATH "$PATH:$MAVEN_HOME/bin"


ENV FCREPO_USER docker
ENV FCREPO_UID 8080
RUN groupadd -r $FCREPO_USER && \
  useradd -r -u $FCREPO_UID -g $FCREPO_USER $FCREPO_USER


RUN apt-get update && \
    apt-get -y install --no-install-recommends  git  curl



# install maven


RUN curl -fsSL http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xzf - -C /usr/share \
    && mv /usr/share/apache-maven-$MAVEN_VERSION /usr/share/maven \
    && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn



# Install Fedora4


WORKDIR /fcrepo4
RUN curl -fsSL $FCREPO_GIT_DOWNLOAD -o fcrepo.tar.gz \
	&& tar -xzf fcrepo.tar.gz --strip-components=1 \
	&& rm fcrepo.tar.gz*

# build the module fcrepo-webapp (pl for projects) and required modules (am for also-make)
RUN mvn install -pl fcrepo-webapp -am   -DskipTests                # todo remove flag skip tests


# just package the war but do not install anything in your local repository
# RUN mvn package -pl fcrepo-webapp -am  -DskipTests                # todo remove flag skip tests



# move the file to the host file system


RUN mkdir /fcrepo
RUN cp /fcrepo4/fcrepo-webapp/target/fcrepo-webapp-$FEDORA_VERSION.war /fcrepo/fcrepo-webapp.war
RUN chown -R $FCREPO_USER:$FCREPO_USER /fcrepo
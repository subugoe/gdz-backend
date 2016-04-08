FROM jetty:9.3-jre8


MAINTAINER  Jörg Panzer, SUB


#ENV FCREPO_GIT  https://github.com/fcrepo4/fcrepo4.git

#ENV MAVEN_OPTS  "-Xmx1024m" -XX:MaxMetaspaceSize=1024m"
#ENV MAVEN_VERSION 3.3.3
#ENV MAVEN_HOME /usr/share/maven
#ENV PATH "$PATH:$MAVEN_HOME/bin"

ENV JRE_HOME         /usr

#RUN apt-get update && \
#    apt-get -y install --no-install-recommends  git  curl

# install maven
#RUN curl -fsSL http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xzf - -C /usr/share \
#    && mv /usr/share/apache-maven-$MAVEN_VERSION /usr/share/maven \
#    && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn


# Install Fedora4
#ENV FEDORA_VERSION 4.5.0
#ENV FEDORA_TAG 4.5.0

#WORKDIR /
#RUN git clone $FCREPO_GIT


#WORKDIR /fcrepo4

# build all and install it to the local maven repo
# RUN mvn install
# RUN mvn install -DskipTests                # todo remove flag skip tests

# build the module fcrepo-webapp (pl for projects) and required modules (am for also-make)
#RUN mvn install -pl fcrepo-webapp -am


# just package the war but do not install anything in your local repository
#RUN mvn package -pl fcrepo-webapp -am

# todo ensure jetty/fedora is not running under root

#WORKDIR /fcrepo4/fcrepo-webapp/target/
#CMD ["mvn", "jetty:run"]




# WORKDIR /
# RUN git clone $FCREPO_GIT
# WORKDIR /fcrepo4
# RUN mvn package -pl fcrepo-webapp -am
# RUN mv /fcrepo4/fcrepo-webapp/target/fcrepo-webapp-4.5.1-SNAPSHOT.war /var/lib/jetty/webapps/fcrepo-webapp.war

WORKDIR /var/lib/jetty/webapps
CMD ["java","-Djava.io.tmpdir=/tmp/jetty","-jar","/usr/local/jetty/start.jar"]
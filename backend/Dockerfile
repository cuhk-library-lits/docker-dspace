FROM maven:3.8-amazoncorretto-17 AS build-backend

ARG DSPACE_RELEASE_URL=https://github.com/DSpace/DSpace/archive/refs/tags/dspace-7.5.tar.gz
ARG DSPACE_RELEASE_FOLDER=DSpace-dspace-7.5

RUN yum install -y ant git

RUN curl -OL $DSPACE_RELEASE_URL && \
    tar -xf dspace-*.tar.gz && \
    cd $DSPACE_RELEASE_FOLDER && \
    mvn package && \
    cd dspace/target/dspace-installer/ && \
    ant init_installation init_configs install_code copy_webapps


FROM tomcat:9-jre17

VOLUME [ "/deploy/solr" ]

RUN groupadd -g 8983 solr && \
    useradd solr -u 8983 -g 8983

RUN mkdir -p /deploy/solr && \
    chown -R solr:solr /deploy/solr

COPY --from=build-backend  --chown=solr  /dspace/solr      /deploy/solr
COPY --from=build-backend                /dspace           /dspace
COPY --from=build-backend                /dspace/webapps   /usr/local/tomcat/webapps

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod u+x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

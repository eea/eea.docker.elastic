FROM elasticsearch:5.6.14

COPY plugins/readonlyrest-1.16.29_es6.5.0.zip /tmp/

RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install analysis-icu
RUN mv /docker-entrypoint.sh /elastic-entrypoint.sh

COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY config /usr/share/elasticsearch/config

RUN mv /usr/share/elasticsearch/config/readonlyrest.yml /tmp


FROM docker.elastic.co/elasticsearch/elasticsearch-oss:6.3.0

COPY plugins/readonlyrest-1.16.21_es6.3.0.zip /tmp/


RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install analysis-icu 
    
RUN mv /usr/local/bin/docker-entrypoint.sh /usr/local/bin/elastic-entrypoint.sh

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

COPY config /usr/share/elasticsearch/config

RUN mv /usr/share/elasticsearch/config/readonlyrest.yml /tmp


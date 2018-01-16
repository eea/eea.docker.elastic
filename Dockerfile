FROM docker.elastic.co/elasticsearch/elasticsearch:6.1.1

COPY plugins/readonlyrest-1.16.15_es6.1.1.zip /tmp/


RUN /usr/share/elasticsearch/bin/elasticsearch-plugin remove x-pack \
    && /usr/share/elasticsearch/bin/elasticsearch-plugin install analysis-icu 
    


RUN mv /usr/local/bin/docker-entrypoint.sh /usr/local/bin/elastic-entrypoint.sh

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

COPY config /usr/share/elasticsearch/config

RUN mv /usr/share/elasticsearch/config/readonlyrest.yml /tmp


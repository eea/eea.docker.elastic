FROM docker.elastic.co/elasticsearch/elasticsearch:6.1.1

RUN /usr/share/elasticsearch/bin/elasticsearch-plugin remove x-pack \
    && /usr/share/elasticsearch/bin/elasticsearch-plugin install analysis-icu

COPY config /usr/share/elasticsearch/config



FROM docker.elastic.co/elasticsearch/elasticsearch:7.17.29

RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install analysis-icu \
  && mv /usr/local/bin/docker-entrypoint.sh /usr/local/bin/elastic-entrypoint.sh \
  && mkdir -p /usr/share/elasticsearch/snapshot

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

COPY config /usr/share/elasticsearch/config




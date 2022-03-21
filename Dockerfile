FROM docker.elastic.co/elasticsearch/elasticsearch:8.1.0


USER root

RUN   apt-get update && apt-get install -y --no-install-recommends  gosu \
    && /usr/share/elasticsearch/bin/elasticsearch-plugin install analysis-icu \
    && rm -rf /var/lib/apt/lists/* /usr/share/doc

RUN mv /usr/local/bin/docker-entrypoint.sh /usr/local/bin/elastic-entrypoint.sh

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY config /usr/share/elasticsearch/config

RUN chown -R 1000:0 /usr/share/elasticsearch


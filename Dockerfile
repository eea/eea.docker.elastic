FROM docker.elastic.co/elasticsearch/elasticsearch:8.1.0


RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install analysis-icu 

USER root    
RUN mv /usr/local/bin/docker-entrypoint.sh /usr/local/bin/elastic-entrypoint.sh

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY config /usr/share/elasticsearch/config

RUN chown -R elasticsearch:elasticsearch /usr/share/elasticsearch

USER elasticsearch

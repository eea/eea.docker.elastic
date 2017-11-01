FROM elasticsearch:2.4.6

RUN bin/plugin install analysis-icu

COPY config /usr/share/elasticsearch/config


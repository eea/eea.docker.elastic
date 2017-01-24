FROM elasticsearch:1.7.5
ENV RIVER_VERSION=1.5.9
RUN plugin -install mobz/elasticsearch-head \
    && plugin -install elasticsearch/elasticsearch-analysis-icu/1.11.0 \
    && plugin --url https://github.com/eea/eea.elasticsearch.river.rdf/releases/download/${RIVER_VERSION}/eea-rdf-river-plugin-${RIVER_VERSION}.zip --install eea-rdf-river
COPY config /usr/share/elasticsearch/config

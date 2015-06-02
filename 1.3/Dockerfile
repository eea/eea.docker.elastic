FROM elasticsearch:1.3
#ENV RIVER_VERSION=1.5.6
ENV ANALYSIS_VERSION=2.3.0
RUN plugin -install mobz/elasticsearch-head \
    && plugin -install elasticsearch/elasticsearch-analysis-icu/${ANALYSIS_VERSION}
#    && plugin --url https://github.com/eea/eea.elasticsearch.river.rdf/releases/download/${RIVER_VERSION}/eea-rdf-river-plugin-${RIVER_VERSION}.zip --install eea-rdf-river
COPY config /usr/share/elasticsearch/config

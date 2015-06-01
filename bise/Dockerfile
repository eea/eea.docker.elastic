FROM eeacms/elastic:1.5.1-1.5.6

ENV MAPPER_VERSION=2.5.0

RUN plugin -install elasticsearch/elasticsearch-mapper-attachments/$MAPPER_VERSION

#
# Cannot set cluster.name with spaces in elasticsearch command (-Des.cluster.name="Something with spaces")
#
RUN echo 'cluster.name: "Catalogue Cluster"' >> /usr/share/elasticsearch/config/elasticsearch.yml
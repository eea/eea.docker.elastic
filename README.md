# Elasticsearch Docker image with EEA RDF River installed

## Plugins
This image is based on the official Elasticsearch Docker image
(https://github.com/docker-library/docs/tree/master/elasticsearch)
In addition to this, it has the following plugins installed:

* Analysis ICU
* eea.elasticsearch.river.rdf
* head

## Useful configurations

To configure an Elastic Cluster using this image you can add parameters
to the elasticsearch command so that the node can have a certain role in
the cluster.

### Runing a master only node
This ensures that the node can't hold data and can't be accessed with
the HTTP API.

```yaml
esmaster:
    image: eeacms/elastic
    command:
        - -Des.cluster.name="my_cluster"
        - -Des.node.data=false
        - -Des.http.enabled=false
        - -Des.node.master=true
```

### Running a client
This ensures that the node can't be elected as master and is in charge
only for responding to HTTP requests for clients

```yaml
esclient:
    image: eeacms/elastic
    command: # No data, http, can't be master
        - elasticsearch
        - -Des.cluster.name="my_cluster"
        - -Des.node.data=false
        - -Des.http.enabled=true
        - -Des.node.master=false
```

### Running a data node
This ensures that the node only holds data without being accessible
using the REST api and without being able to be elected as a master.

```yaml
esdata:
    image: eeacms/elastic
    command: # No data, http, can't be master
        - elasticsearch
        - -Des.cluster.name="my_cluster"
        - -Des.node.data=true
        - -Des.http.enabled=false
        - -Des.node.master=false
```

### Increasing java heap space for the node

Follow the instructions here:
http://www.elastic.co/guide/en/elasticsearch/guide/master/heap-sizing.html

You can add the ```ES_HEAP_SIZE``` environment variable using
the ```-e``` Docker parameter. Alternativelly you can pass
the ```-Xmx``` and ```-Xms``` directly to the command that runs inside
the container.

### Keeping the data persistent

By default the data is stored inside a volume.
The voulume is mounted inside the container at ```/usr/share/elasticsearch/data```.

In order to create backups of the data just run another container with
```--volumes-from```. e.g. Make a backup on your local system at ```/path/to/backup```.

```bash
docker run --volumes-from myelasticsearch -v /path/to/backup/:/backup busybox cp -r /usr/share/elasticsearch/data /backup
```

Alternatively you can mount that directory at a local path


## Development

If you want to integrate a local build of the RDF River plugin into this
image for development you can:

```bash
pushd /your/work/dir
git clone git@github.com:eea/eea.elasticsearch.river.rdf.git
# modify the code there
popd
./build_dev.sh /your/work/dir/eea.elasticsearch.river.rdf
# Now you have a local image called eeacms/elastic:latest that you can use
# locally with your latest build of the river plugin
```


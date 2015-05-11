#!/bin/bash

echo "Buidling eeacms/elastic locally with local RDF River"

set -e

if [ -z $1 ]; then
    echo "Usage: ./build_dev.sh PATH_TO_RIVER_REPO"
    exit 100
fi

if [ ! -d $1 ]; then
    echo "$1 is not a directory!"
    exit 100
fi

PLUGIN_DIR=$1

echo "Building River Plugin"
pushd $PLUGIN_DIR &> /dev/null
mvn clean install
popd

echo "Building Image"
PLUGIN=$(find ${PLUGIN_DIR} -name "eea-rdf-river-plugin-*.zip")
cp ${PLUGIN} ./eea-rdf-river.zip
docker build -f Dockerfile.dev -t eeacms/elastic:dev .
rm ./eea-rdf-river.zip

echo "Done"

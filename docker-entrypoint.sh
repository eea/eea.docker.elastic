#!/bin/bash
set -e



if [ $(env | grep -c "http.enabled=true") -ne 0 ]; then
    if [ ! -f /usr/share/elasticsearch/ssl/self.jks ]; then
      mkdir -p /usr/share/elasticsearch/ssl
      keytool -genkey -keyalg RSA -noprompt -alias $HOSTNAME -dname "CN=$HOSTNAME,OU=IDM,O=EEA,L=IDM1,C=DK" -keystore /usr/share/elasticsearch/ssl/self.jks -storepass $KEYSTORE_PASSWORD -keypass $KEY_PASSWORD
      keytool -keystore  /usr/share/elasticsearch/ssl/self.jks -alias $HOSTNAME -export -file  /usr/share/elasticsearch/ssl/self.cert
    fi
fi

sed -i "s/KEYSTORE_PASSWORD/$KEYSTORE_PASSWORD/g" /usr/share/elasticsearch/config/readonlyrest.yml

sed -i "s/KEY_PASSWORD/$KEY_PASSWORD/g" /usr/share/elasticsearch/config/readonlyrest.yml

sed -i "s/RW_USER/$RW_USER/g" /usr/share/elasticsearch/config/readonlyrest.yml
sed -i "s/RW_PASSWORD/$RW_PASSWORD/g" /usr/share/elasticsearch/config/readonlyrest.yml

sed -i "s/RO_USER/$RO_USER/g" /usr/share/elasticsearch/config/readonlyrest.yml
sed -i "s/RO_PASSWORD/$RO_PASSWORD/g" /usr/share/elasticsearch/config/readonlyrest.yml
    
sed -i "s/KIBANA_USER/$KIBANA_USER/g" /usr/share/elasticsearch/config/readonlyrest.yml
sed -i "s/KIBANA_PASSWORD/$KIBANA_PASSWORD/g" /usr/share/elasticsearch/config/readonlyrest.yml


exec /usr/local/bin/elastic-entrypoint.sh $@


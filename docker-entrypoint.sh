#!/bin/bash
set -e



if [ $(env | grep -c "http.enabled=false") -eq 0 ]; then

    if [ $(env | grep -c "http.type=ssl_netty4") -eq 1 ] && [ ! -f /usr/share/elasticsearch/ssl/self.jks ]; then
      mkdir -p /usr/share/elasticsearch/ssl
      $JAVA_HOME/bin/keytool -genkey -keyalg RSA -noprompt -alias $HOSTNAME -dname "CN=$HOSTNAME,OU=IDM,O=EEA,L=IDM1,C=DK" -keystore /usr/share/elasticsearch/ssl/self.jks -storepass $KEYSTORE_PASSWORD -keypass $KEY_PASSWORD
      $JAVA_HOME/bin/keytool -keystore  /usr/share/elasticsearch/ssl/self.jks -alias $HOSTNAME -export -file  /usr/share/elasticsearch/ssl/self.cert
    fi

fi

#make sure that elasticsearch volume has correct permissions
chown -R 1000:0 /usr/share/elasticsearch/data

exec /usr/local/bin/elastic-entrypoint.sh "$@"


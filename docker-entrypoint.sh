#!/bin/bash
set -e



if [ $(env | grep -c "http.enabled=false") -eq 0 ]; then

    if [ $(env | grep -c "http.type=ssl_netty4") -eq 1 ] && [ ! -f /usr/share/elasticsearch/ssl/self.jks ]; then
      mkdir -p /usr/share/elasticsearch/ssl
      $JAVA_HOME/bin/keytool -genkey -keyalg RSA -noprompt -alias $HOSTNAME -dname "CN=$HOSTNAME,OU=IDM,O=EEA,L=IDM1,C=DK" -keystore /usr/share/elasticsearch/ssl/self.jks -storepass $KEYSTORE_PASSWORD -keypass $KEY_PASSWORD
      $JAVA_HOME/bin/keytool -keystore  /usr/share/elasticsearch/ssl/self.jks -alias $HOSTNAME -export -file  /usr/share/elasticsearch/ssl/self.cert
    fi

    if [ $ENABLE_READONLY_REST == "true" ]; then
        if [ -f /tmp/readonlyrest-* ]; then
            plugin_name=$(ls /tmp/readonlyrest-*.zip)
            /usr/share/elasticsearch/bin/elasticsearch-plugin install --batch file://$plugin_name 

            mv /tmp/readonlyrest.yml /usr/share/elasticsearch/config/readonlyrest.yml

            sed -i "s/KEYSTORE_PASSWORD/$KEYSTORE_PASSWORD/g" /usr/share/elasticsearch/config/readonlyrest.yml

            sed -i "s/KEY_PASSWORD/$KEY_PASSWORD/g" /usr/share/elasticsearch/config/readonlyrest.yml

            sed -i "s/RW_USER/$RW_USER/g" /usr/share/elasticsearch/config/readonlyrest.yml
            sed -i "s/RW_PASSWORD/$RW_PASSWORD/g" /usr/share/elasticsearch/config/readonlyrest.yml

            sed -i "s/RO_USER/$RO_USER/g" /usr/share/elasticsearch/config/readonlyrest.yml
            sed -i "s/RO_PASSWORD/$RO_PASSWORD/g" /usr/share/elasticsearch/config/readonlyrest.yml


            if [ -n "$KIBANA_HOSTNAME" ]; then
	        echo "
    - name: \"::KIBANA_HOST::\"
      kibana_access: ro_strict
      hosts: [\"$KIBANA_HOSTNAME\"]
      verbosity: error # don't log successful request" >> /usr/share/elasticsearch/config/readonlyrest.yml
                if [ -n "$KIBANA_USER" ]; then
                       echo "
    # We trust Kibana's server side process, full access granted via HTTP authentication
    - name: \"::KIBANA-SRV::\"
      # auth_key is good for testing, but replace it with `auth_key_sha256`!
      auth_key: $KIBANA_USER:$KIBANA_PASSWORD
      verbosity: error # don't log successful request" >> /usr/share/elasticsearch/config/readonlyrest.yml
                fi
            fi

            rm -f /tmp/readonlyrest-*
        fi
    fi
fi

#make sure that elasticsearch volume has correct permissions
chown -R 1000:0 /usr/share/elasticsearch/data

exec /usr/local/bin/elastic-entrypoint.sh "$@"


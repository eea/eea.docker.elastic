#!/bin/bash
set -e


#make sure that elasticsearch volume has correct permissions
chown -R 1000:0 /usr/share/elasticsearch/data

if [ -n "$elastic_password" ] && [ $( env | grep "xpack.security.enabled=true" | wc -l ) -eq 1 ] && [ ! -f /tmp/users_created ] && [ -z "$DO_NOT_CREATE_USERS" ]; then

#manage certification
if [ $(env | grep "xpack.security.transport.ssl.enabled=true" | wc -l) -eq 1 ]; then
  certificate_path=$(env | grep "xpack.security.transport.ssl.keystore.path" | awk -F= '{print $2}')
  keystore_password=$( env | grep "xpack.security.transport.ssl.keystore.password" | awk -F= '{print $2}') 
  
  export KEYSTORE_PASSWORD=$keystore_password
  
  if [ ! -f /usr/share/elasticsearch/config/$certificate_path ]; then
     bin/elasticsearch-certutil cert -out config/$certificate_path -pass "$keystore_password"
  fi
  
  if [ -n "$keystore_password" ]; then
    bin/elasticsearch-keystore add xpack.security.transport.ssl.keystore.secure_password
    bin/elasticsearch-keystore add xpack.security.transport.ssl.truststore.secure_password
  fi
  chown -R 1000:0 /usr/share/elasticsearch/config
fi

export ELASTIC_PASSWORD=$elastic_password

/usr/local/bin/elastic-entrypoint.sh "$@" &

while [ $( curl -I -s localhost:9200 | grep -c 401 )  -eq 0 ]; do sleep 10; done

if  [ $( curl -I -s -uelastic:$elastic_password  localhost:9200 | grep -ic "200 OK" )  -eq 0 ]; then
  echo "Start setting up passwords"
  passwords=$(bin/elasticsearch-setup-passwords auto -b)
  curl -uelastic:$(echo "$passwords" | grep "elastic = " | awk '{print $4}') -X POST "localhost:9200/_security/user/elastic/_password?pretty" -H 'Content-Type: application/json' -d"{\"password\" : \"$elastic_password\"}"
  echo "Elastic superuser password set"
  for i in $( env | grep "_password" | grep -v "elastic_password" ); do var=$(echo $i | awk -F= '{print $1}');  new_password=$(echo $i | awk -F= '{print $2}'); curl -uelastic:$elastic_password -X POST "localhost:9200/_security/user/${var/_password/}/_password?pretty" -H 'Content-Type: application/json' -d"{\"password\" : \"$new_password\"}"; echo "${var/_password} user password set"; done
 touch /tmp/users_created
else
    for i in $( env | grep "_password" | grep -v "elastic_password" ); do 
	    var=$(echo $i | awk -F= '{print $1}');  
	    new_password=$(echo $i | awk -F= '{print $2}'); 
	    if  [ $( curl -I -s -u${var/_password/}:$new_password  localhost:9200 | grep -ic "200 OK" )  -eq 0 ]; then
                echo "Start setting up password for ${var/_password/} "
	        curl -uelastic:$elastic_password -X POST "localhost:9200/_security/user/${var/_password/}/_password?pretty" -H 'Content-Type: application/json' -d"{\"password\" : \"$new_password\"}"; 
		echo "${var/_password} user password set";
	    fi	
    done
    touch /tmp/users_created
fi

wait 

else
  /usr/local/bin/elastic-entrypoint.sh "$@"
fi


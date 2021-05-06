#!/bin/bash
set -e

#make sure that elasticsearch volume has correct permissions
chown -R 1000:0 /usr/share/elasticsearch/data




if [ -n "$elastic_password" ] && [ $( env | grep "xpack.security.enabled=true" | wc -l ) -eq 1 ] && [ -z "$DO_NOT_CREATE_USERS" ]; then

if [ "${#elastic_password}" -lt 6 ]; then
  echo "ERROR - elastic password is set to less to 6 characters, exiting"
  exit 1
fi

#manage certification
if [ $(env | grep "xpack.security.transport.ssl.enabled=true" | wc -l) -eq 1 ]; then
  certificate_path=$(env | grep "xpack.security.transport.ssl.keystore.path" | awk -F= '{print $2}')
  keystore_password=$( env | grep "xpack.security.transport.ssl.keystore.password" | awk -F= '{print $2}') 
  
  export KEYSTORE_PASSWORD=$keystore_password
  
  if [ ! -f /usr/share/elasticsearch/config/$certificate_path ]; then
     bin/elasticsearch-certutil cert -out config/$certificate_path -pass "$keystore_password"
  fi
  
  if [ -n "$keystore_password" ]; then
    echo "$keystore_password" | bin/elasticsearch-keystore add xpack.security.transport.ssl.keystore.secure_password
    echo "$keystore_password" | bin/elasticsearch-keystore add xpack.security.transport.ssl.truststore.secure_password
  fi
  chown -R 1000:0 /usr/share/elasticsearch/config
fi

export ELASTIC_PASSWORD=$elastic_password


if [ -f /usr/share/elasticsearch/config/userscreated ]; then

        # users were already created, will check if there are any changes on passwords, then start the process

      	 for i in $( env | grep "_password" ); do
             var=$(echo $i | awk -F= '{print $1}');
	     user=${var/_password/}
             new_password=$(echo $i | awk -F= '{print $2}');
	     if [ $(grep "$user = $new_password$" /usr/share/elasticsearch/config/userscreated | wc -l ) -eq 0 ]; then
		    CHECK_USERS='yes'
	     fi
         done

         if [ -z "$CHECK_USERS" ]; then
            /usr/local/bin/elastic-entrypoint.sh "$@"
	 fi
fi


if [ -f /usr/share/elasticsearch/config/userscreated ] && [ -n "$CHECK_USERS" ] || [ ! -f /usr/share/elasticsearch/config/userscreated ]; then

/usr/local/bin/elastic-entrypoint.sh "$@" &

while [ $( curl -I -s localhost:9200 | grep -c 401 )  -eq 0 ]; do sleep 10; done

#ensure elastic password is ok
if  [ $( curl -I -s -uelastic:$elastic_password  localhost:9200 | grep -ic "200 OK" )  -eq 0 ]; then
  if  [ ! -f /usr/share/elasticsearch/config/userscreated ]; then 
  	echo "Start setting up passwords"
  	passwords=$(bin/elasticsearch-setup-passwords auto -b)
  	old_password=$(echo "$passwords" | grep "elastic = " | awk '{print $4}')
	sleep 5
        if  [ $( curl -I -s -uelastic:$old_password  localhost:9200 | grep -ic "200 OK" )  -eq 1 ]; then
		echo "Passwords are set correctly"
                echo $password > /usr/share/elasticsearch/config/userscreated
	else
		echo "There is a problem with the setting up of the passwords"
		echo "The current elastic user password does not work, and there is no old one"
		exit 1
        fi
  else
        old_password=$(cat /usr/share/elasticsearch/config/userscreated | grep "elastic = " | awk '{print $4}')
  fi
 
  curl -uelastic:$old_password -X POST "localhost:9200/_security/user/elastic/_password?pretty" -H 'Content-Type: application/json' -d"{\"password\" : \"$elastic_password\"}"
  sleep 5
  if  [ $( curl -I -s -uelastic:$elastic_password  localhost:9200 | grep -ic "200 OK" )  -eq 1 ]; then
          echo "Elastic superuser password set"
	  sed -i "s/elastic = .*/elastic = $elastic_password/" /usr/share/elasticsearch/config/userscreated
  else
	    echo "There is a problem with the setting of the elastic superuser password, will exit"
            echo "The auto-generated password is $old_password"
            exit 1
  fi
else
   echo "Elastic password is set"	
   if  [ ! -f /usr/share/elasticsearch/config/userscreated ]; then
	   echo "PASSWORD elastic = $elastic_password" > /usr/share/elasticsearch/config/userscreated
   fi	   
fi

# check all other passwords

for i in $( env | grep "_password" | grep -v "elastic_password" ); do 
     var=$(echo $i | awk -F= '{print $1}'); 
     user=${var/_password/}
     new_password=$(echo $i | awk -F= '{print $2}'); 
     old_password=$(cat /usr/share/elasticsearch/config/userscreated | grep "${user} = " | awk '{print $4}')
  
     if [[ ! "$old_pasword" == "$new_password" ]]; then
	     echo "Saved password different from new password for user $user, resetting it"
             curl -uelastic:$elastic_password -X POST "localhost:9200/_security/user/${user}/_password?pretty" -H 'Content-Type: application/json' -d"{\"password\" : \"$new_password\"}"; 
             if  [ $( curl -I -s -u${user}:$new_password  localhost:9200 | grep -ic "200 OK" )  -eq 1 ]; then
                echo "${user} password set succesfully"
		if [ -n "$old_password" ]; then
                   sed -i "s/${user} = .*/${user} = $new_password/" /usr/share/elasticsearch/config/userscreated
	        else
                   echo "PASSWORD ${user} = $new_password" >> /usr/share/elasticsearch/config/userscreated
		fi  
             else
                echo "There is a problem with the setting of user ${user} password, exiting"
		exit 1
             fi
      fi	     
done

wait 

fi

else

  #force restart on data nodes for them to have the passwords & ssl
  if [ -n "$elastic_password" ] && [ -n "$DO_NOT_CREATE_USERS" ] && [ ! -f /usr/share/elasticsearch/config/userscreated ] ; then	
   
     #data node, needs to start without users and then restart when they are created
     #export ELASTIC_PASSWORD=$elastic_password

     /usr/local/bin/elastic-entrypoint.sh "$@" &

     while [ ! -f /usr/share/elasticsearch/config/userscreated ]; do sleep 10; done

     sleep 20

     exit 1

  else 

     /usr/local/bin/elastic-entrypoint.sh "$@"
  
  fi
fi


#! /bin/bash

echo Always getting the newest security updates

apt-get update
apt-get upgrade -y openssh-server
apt-get clean

echo "Copying the templates"
cp -v -p /ssh.template/*.template /ssh/
cp -v -p -u /ssh.template/* /ssh/


echo "Checking for stored prime numbers in volume"
if test "${SKIP_SERVER_PRIME_NUMBERS}" != 1
then
  rm /etc/ssh/moduli || true
  if test -f /ssh/moduli 
  then
    echo "Using stored prime numbers"
  	cp -v -p /ssh/moduli /etc/ssh/moduli
  else
	echo "Updating prime numbers"
	echo "This will take about an hour, even on a fast server"
  	
  	ssh-keygen -G /tmp/moduli -b 4096
    ssh-keygen -T /etc/ssh/moduli -f /tmp/moduli
  fi
  cp -v -p -u /etc/ssh/moduli /ssh/
else
	echo "Use prime numbers delivered with OpenSSH. These might be compromised."
fi

echo "Updating server keys from container"

if test "${STORE_SERVER_KEYS_IN_CONTAINER}" != 1 
then
    echo "Deleting host keys from container"
	rm -f /etc/ssh/ssh_host_*key* || echo "No host keys found"
else
	echo "Using host keys stored in container. This should only be used for debug purpoeses."
fi

echo "Checking stored host keys in volume"
cp -v -p /ssh/ssh_host_*key* /etc/ssh/ || echo "No server keys in container, creating new ones"

if test ! -f /etc/ssh/ssh_host_ed25519_key
then
	ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N '' < /dev/null
fi

if test ! -f /etc/ssh/ssh_host_rsa_key
then
	ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N '' < /dev/null
fi
echo "Storing host keys in volume"
cp -v -u -p /etc/ssh/ssh_host_*key* /ssh/

echo Fixing permissions
chown -R root:root /etc/ssh /ssh
chmod -R a=rX /etc/ssh/
chmod go= /etc/ssh/ssh_host_*key*

chmod a=rX,u+w /ssh /ssh/authorized_keys*

ls -ld /etc/ssh /etc/ssh/ssh_host_*_key* /ssh /ssh/authorized_keys*

echo Starting OpenSSH

exec $@

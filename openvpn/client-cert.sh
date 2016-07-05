#!/bin/bash

# Generate a client certificate..
# Take the name of the client in parameters.

usage()
{
        echo -e "Utilisation:\tclient-cert.sh <client_name> \n\t--help:\t\tPrint help."
}

EASY_RSA=/etc/openvpn/easy-rsa
VARS_FILE=$EASY_RSA/vars
KEYS=$EASY_RSA/keys
BUILD_KEY=$EASY_RSA/build-key
CLIENT_DIR=/etc/openvpn/clients

[ $# -ne 1 ] && usage && exit 1

[[ $1 == "--help" ]] && usage && exit 0

CLIENT=$1

cd $EASY_RSA
source $VARS
$BUILD_KEY $CLIENT
echo -e "\n\nFiles created: "
ls -lh $KEYS | grep $CLIENT
echo -e "\n\n"

# if /etc/openvpn/clients/ doesn't exist, create it.
[ ! -d $CLIENT_DIR ] && mkdir -p $CLIENT_DIR

# Copy ca.crt, $client.crt, $client.key and ta.key in /etc/openvpn/clients/client_name
mkdir -v $CLIENT_DIR/$CLIENT
cp -v $KEYS/$CLIENT.{crt,key} $CLIENT_DIR/$CLIENT
cp -v $KEYS/ca.crt $CLIENT_DIR/$CLIENT
cp -v $KEYS/ta.key $CLIENT_DIR/$CLIENT

# Create a .tar.gz archive with client certificates and config file...
cp -v $CLIENT_DIR/client.conf $CLIENT_DIR/$CLIENT/
cd $CLIENT_DIR/$CLIENT/
# ... but before add certificates to the client.conf:
echo "ca ca.crt" >> client.conf
echo "cert $CLIENT.crt" >> client.conf
echo "key $CLIENT.key" >> client.conf

echo -e "\n\n"
cd ..
tar zcvf $CLIENT.tar.gz $CLIENT/


exit 0


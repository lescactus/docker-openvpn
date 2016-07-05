# docker-openvpn
This is the a Docker image for OpenVPN containers.

### How to build
```sh
$ docker build -t docker-openvpn .
```

### Hown to run
```sh
$ docker run -d --privileged -p 443:443 --net host --name openvpn docker-openvpn
```

### Create client certificates
```sh
# Get a shell inside the container.
$ docker exec -it openvpn bash

# Execute the client-cert.sh script. 
$ /root/client-cert.sh <nom client>

# Certificates and keys are availables in the container in /etc/openvpn/clients/<client_name.tar.gz>
# Outside the container, copy the archive on the host filesystem.
$ docker cp openvpn:/etc/openvpn/clients/<client_name.tar.gz> /path/to/copy/it
```

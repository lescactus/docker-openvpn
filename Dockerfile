# Debian-based image.
FROM debian:latest

MAINTAINER Alexandre MALDÉMÉ

# Packages
RUN apt-get update \
    && apt-get install -y openvpn iptables iptables-persistent

WORKDIR /etc/openvpn/easy-rsa

# Easy-RSA variables.
ENV WORKDIR /etc/openvpn/easy-rsa
ENV EASY_RSA $WORKDIR
ENV OPENSSL openssl
ENV PKCS11TOOL pkcs11-tool
ENV GREP grep
ENV KEY_CONFIG ${EASY_RSA}/openssl-1.0.0.cnf
ENV KEY_DIR ${EASY_RSA}/keys
ENV PKCS11_MODULE_PATH dummy
ENV PKCS11_PIN dummy
ENV KEY_SIZE 2048
ENV CA_EXPIRE 3650
ENV KEY_EXPIRE 3650
ENV KEY_COUNTRY FR
ENV KEY_PROVINCE France
ENV KEY_CITY Nancy
ENV KEY_ORG alexandre.maldeme.org
ENV KEY_EMAIL amaldeme@mail.alexasr.tk
ENV KEY_OU IT
ENV KEY_NAME server


# OpenVPN configuration.
RUN cp -a /usr/share/easy-rsa /etc/openvpn/
RUN mkdir /etc/openvpn/clients
ADD ./openvpn/vars /etc/openvpn/easy-rsa/
ADD ./openvpn/client-cert.sh /root/
ADD ./openvpn/client.conf /etc/openvpn/clients

RUN ./clean-all
RUN ${EASY_RSA:-.}/pkitool --initca			# Certificat et clef de du CA.
RUN ./build-dh
RUN ${EASY_RSA:-.}/pkitool --server srvcert		# Certificat et clef du serveur.
RUN openvpn --genkey --secret keys/ta.key		# Clef pour tls-auth.

RUN gunzip -c /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz > /etc/openvpn/server.conf
ADD openvpn/server.conf /etc/openvpn
RUN sed -i 's/ca\ \/etc\/openvpn\/ca.crt/ca\ \/etc\/openvpn\/easy-rsa\/keys\/ca.crt/g' /etc/openvpn/server.conf
RUN sed -i 's/cert\ \/etc\/openvpn\/server.crt/cert\ \/etc\/openvpn\/easy-rsa\/keys\/srvcert.crt/g' /etc/openvpn/server.conf
RUN sed -i 's/key\ \/etc\/openvpn\/server.key/key\ \/etc\/openvpn\/easy-rsa\/keys\/srvcert.key/g' /etc/openvpn/server.conf
RUN sed -i 's/dh\ \/etc\/openvpn\/dh2048.pem/dh\ \/etc\/openvpn\/easy-rsa\/keys\/dh2048.pem/g' /etc/openvpn/server.conf
RUN mkdir -p /etc/openvpn/jail/tmp

# Open port 443.
EXPOSE 443

WORKDIR /root
ADD ./openvpn/entrypoint.sh entrypoint.sh

ENTRYPOINT ["/root/entrypoint.sh"]

# Run OpenVPN
CMD ["/usr/sbin/openvpn","/etc/openvpn/server.conf"]


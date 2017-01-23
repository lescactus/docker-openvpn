# Debian-based image.
FROM debian:latest

MAINTAINER Alexandre MALDÉMÉ

# Easy-RSA variables.
ENV WORKDIR="/etc/openvpn/easy-rsa"                             \
        EASY_RSA="$/etc/openvpn/easy-rsa"                       \
        OPENSSL="openssl"                                       \
        PKCS11TOOL="pkcs11-tool"                                \
        GREP="grep"                                             \
        KEY_CONFIG="/etc/openvpn/easy-rsa/openssl-1.0.0.cnf"    \
        KEY_DIR="/etc/openvpn/easy-rsa/keys"                    \
        PKCS11_MODULE_PATH="dummy"                              \
        PKCS11_PIN="dummy"                                      \
        KEY_SIZE="4096"                                         \
        CA_EXPIRE="3650"                                        \
        KEY_EXPIRE="3650"                                       \
        KEY_COUNTRY="FR"                                        \
        KEY_PROVINCE="France"                                   \
        KEY_CITY="Nancy"                                        \
        KEY_ORG="alexandre.maldeme.org"                         \
        KEY_EMAIL="amaldeme@mail.alexasr.tk"                    \
        KEY_OU="IT"                                             \
        KEY_NAME="server"


#ADD ./vars /etc/openvpn/easy-rsa/
ADD ./client-cert.sh /root/
ADD ./client.conf /etc/openvpn/clients/client.conf
ADD ./server.conf /etc/openvpn
ADD ./entrypoint.sh /root/entrypoint.sh


WORKDIR /etc/openvpn/easy-rsa

# Packages
RUN apt-get update && apt-get install -y        \
    openvpn                                     \
    iptables                                    \
    iptables-persistent                         \
        && rm -rf /var/lib/apt/lists/*


# OpenVPN configuration.
RUN cp -a /usr/share/easy-rsa /etc/openvpn/

RUN ./clean-all                                         \
        && ./pkitool --initca                           \
        && ./build-dh                                   \
        && ./pkitool --server srvcert                   \
        && openvpn --genkey --secret keys/ta.key        \
        && mkdir -p /etc/openvpn/jail/tmp

# Open port 443.
EXPOSE 443

WORKDIR /root

ENTRYPOINT ["/root/entrypoint.sh"]

# Run OpenVPN
CMD ["/usr/sbin/openvpn","/etc/openvpn/server.conf"]

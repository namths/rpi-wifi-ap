FROM jonaskello/rpi-alpine-scratch-qemu

MAINTAINER namthz <namth.dev@gmail.com>

RUN apk update && apk add bash hostapd iptables dhcp && rm -rf /var/cache/apk/*
RUN echo "" > /var/lib/dhcp/dhcpd.leases
ADD wlanstart.sh /bin/wlanstart.sh
RUN chmod -R 775 /bin/wlanstart.sh

ENTRYPOINT [ "/bin/wlanstart.sh" ]

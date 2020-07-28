FROM alpine
RUN apk add --update curl build-base

# Daemontools
RUN mkdir -p /package && chmod 1755 /package
WORKDIR /package
RUN curl --silent https://cr.yp.to/daemontools/daemontools-0.76.tar.gz -o daemontools-0.76.tar.gz
RUN tar -xf daemontools-0.76.tar.gz && rm daemontools-0.76.tar.gz
RUN cd admin/daemontools-0.76 && sed -i 's/gcc -O2/gcc -O2 -include \/usr\/include\/errno.h/g' src/conf-cc && package/install

#Djbdns
WORKDIR /tmp
RUN curl --silent https://cr.yp.to/djbdns/djbdns-1.05.tar.gz -o djbdns-1.05.tar.gz
RUN tar -xf djbdns-1.05.tar.gz && rm djbdns-1.05.tar.gz
# Prevent DNS poisonig attacks
# http//your.org/dnscache
RUN curl --silent http://www.your.org/dnscache/0001-dnscache-merge-similar-outgoing-queries.patch -o 01.patch
RUN curl --silent http://www.your.org/dnscache/0002-dnscache-cache-soa-records.patch -o 02.patch
RUN cd djbdns-1.05 && patch -p1 < ../01.patch && patch -p1 ../02.patch && rm ../01.patch ../02.patch
RUN cd djbdns-1.05 && echo gcc -O2 -include /usr/include/errno.h > conf-cc && make && make setup check
# Fetch current DNS root server
RUN dnsip `dnsqr ns . | awk '/answer:/ { print $5; }' |sort` > /etc/dnsroots.global

FROM alpine
# Copy compiled binaries
COPY --from=0 /usr/local/bin/ /usr/local/bin/
COPY --from=0 /package/ /package/
COPY --from=0 /command/ /command/
# Copy updated DNS root server list
COPY --from=0 /etc/dnsroots.global /etc

RUN adduser --system --no-create-home dnscache
RUN adduser --system --no-create-home dnslog

ENV ROOT /srv/dnscache
RUN dnscache-conf dnscache dnslog $ROOT 0.0.0.0

# Allow default docker network
RUN touch $ROOT/root/ip/172.17

VOLUME $ROOT
EXPOSE 53/udp

WORKDIR $ROOT
ENTRYPOINT ./run

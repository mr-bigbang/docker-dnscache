# DJB's Dnscache inside a Docker container

Alpine based dnscache docker image.

Run: `docker run -d -v dnscache:/srv/dnscache -p 127.0.0.1:53:53/udp --restart always --name dnscache mrbigbang/dnscache` and point your /etc/resolv.conf to 127.0.0.1

Or via docker-compose: 
```yaml
version: "3.8"

services:
  dnscache:
    image: mrbigbang/dnscache
    restart: "always"
    ports:
      - "127.0.0.1:53:53/udp"
    volumes:
      - dnscache:/srv/dnscache
    #depends_on:
    #  - tinydns

volumes:
  dnscache:
    driver: local
```

Don't forget to configure dnscache (especially the allowed IPs in /srv/dnscache/root/ip/ and your DNS-Server in /srv/dnscache/root/servers) according to the official documentation: https://cr.yp.to/djbdns.html

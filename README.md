# docker-base-alpine-s6-overlay
Base docker image including the s6-overlay but using Alpine's official base.

See the original [s6-overlay project](https://github.com/just-containers/s6-overlay)
for more details.

# Updating

To synchronize the source tree with s6-overlay, update the S6\_OVERLAY\_RELEASE item
inside the Dockerfile.

# Notes

Previously the included copy of s6 was from Alpine, but the overlay
has gotten to the point where version incompatibilities are frequent enough
to be annoying. The benefit of using Alpine's s6 are probably irrelevant now.

Also there is no gnupg key for the overlay binaries - so that mechanism has been dropped.

# Quickstart

Build the following Dockerfile and try this guy out:

```
FROM harningt/base-alpine-s6-overlay:edge
RUN apk add --update nginx && \
    rm -rf /var/cache/apk/* && \
    echo "daemon off;" >> /etc/nginx/nginx.conf
ENTRYPOINT ["/init"]
CMD ["nginx"]
```

```
docker-host $ docker build -t demo .
docker-host $ docker run --name s6demo -d -p 80:80 demo
docker-host $ docker top s6demo acxf
PID                 TTY                 STAT                TIME                COMMAND
3788                ?                   Ss                  0:00                \_ s6-svscan
3827                ?                   S                   0:00                | \_ foreground
3834                ?                   S                   0:00                | | \_ foreground
3879                ?                   S                   0:00                | | \_ nginx
3880                ?                   S                   0:00                | | \_ nginx
3881                ?                   S                   0:00                | | \_ nginx
3882                ?                   S                   0:00                | | \_ nginx
3883                ?                   S                   0:00                | | \_ nginx
3828                ?                   S                   0:00                | \_ s6-supervise
3829                ?                   S                   0:00                | \_ s6-supervise
3830                ?                   Ss                  0:00                | \_ s6-log
docker-host $ curl --head http://127.0.0.1/
HTTP/1.1 200 OK
Server: nginx/1.4.6 (Ubuntu)
Date: Thu, 26 Mar 2015 14:57:34 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Tue, 04 Mar 2014 11:46:45 GMT
Connection: keep-alive
ETag: "5315bd25-264"
Accept-Ranges: bytes
```

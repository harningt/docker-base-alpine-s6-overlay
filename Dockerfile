# VERSION latest
# AUTHOR:       Thomas Harning Jr <harningt@gmail.com>
# DESCRIPTION:  Alpine linux base image with s6-overlay injected

FROM alpine:3.6
MAINTAINER Thomas Harning Jr <harningt@gmail.com>

ENV S6_OVERLAY_RELEASE v1.19.1.1
ENV TMP_BUILD_DIR /tmp/build

# Pull in the overlay binaries
ADD https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_RELEASE}/s6-overlay-nobin.tar.gz ${TMP_BUILD_DIR}/
ADD https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_RELEASE}/s6-overlay-nobin.tar.gz.sig ${TMP_BUILD_DIR}/

# Pull in the trust keys
COPY keys/trust.gpg ${TMP_BUILD_DIR}/

# Patch in source for testing sources...
# Update, install necessary packages, fixup permissions, delete junk
RUN apk add --update s6 s6-portable-utils && \
    apk add --virtual verify gnupg && \
    cd ${TMP_BUILD_DIR} && \
    gpg --no-default-keyring --keyring ./trust.gpg --verify s6-overlay-nobin.tar.gz.sig && \
    apk del verify && \
    tar -C / -xzf s6-overlay-nobin.tar.gz && \
    cd / && \
    rm -rf /var/cache/apk/* && \
    rm -rf ${TMP_BUILD_DIR}

ENTRYPOINT [ "/init" ]

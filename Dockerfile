# VERSION latest
# AUTHOR:       Thomas Harning Jr <harningt@gmail.com>
# DESCRIPTION:  Alpine linux base image with s6-overlay injected

FROM alpine:edge
MAINTAINER Thomas Harning Jr <harningt@gmail.com>

ENV S6_OVERLAY_RELEASE v3.1.2.1
ENV TMP_BUILD_DIR /tmp/build

# Pull in the overlay script binaries
ADD https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_RELEASE}/s6-overlay-noarch.tar.xz ${TMP_BUILD_DIR}/
ADD https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_RELEASE}/s6-overlay-noarch.tar.xz.sha256 ${TMP_BUILD_DIR}/

# Pull in the overlay architecture-specific binaries
ADD https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_RELEASE}/s6-overlay-x86_64.tar.xz ${TMP_BUILD_DIR}/
ADD https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_RELEASE}/s6-overlay-x86_64.tar.xz.sha256 ${TMP_BUILD_DIR}/

# Perform an apk upgrade, too to make sure all security updates are applied
# - do not anticipate compatibility issues at this small layer
RUN apk update && apk upgrade && \
    cd ${TMP_BUILD_DIR} && \
    sha256sum -c *.sha256 && \
    tar -C / -Jxpf s6-overlay-noarch.tar.xz && \
    tar -C / -Jxpf s6-overlay-x86_64.tar.xz && \
    cd / && \
    rm -rf /var/cache/apk/* && \
    rm -rf ${TMP_BUILD_DIR}

ENTRYPOINT [ "/init" ]

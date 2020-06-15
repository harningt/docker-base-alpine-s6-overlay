# VERSION latest
# AUTHOR:       Thomas Harning Jr <harningt@gmail.com>
# DESCRIPTION:  Alpine linux base image with s6-overlay injected

FROM alpine:edge
MAINTAINER Thomas Harning Jr <harningt@gmail.com>

ENV S6_OVERLAY_RELEASE v2.0.0.1
ENV JUSTC_ENVDIR_RELEASE 1.0.0
ENV TMP_BUILD_DIR /tmp/build

# Pull in the overlay binaries
ADD https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_RELEASE}/s6-overlay-nobin.tar.gz ${TMP_BUILD_DIR}/
ADD https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_RELEASE}/s6-overlay-nobin.tar.gz.sig ${TMP_BUILD_DIR}/

# Pull in justc-envdir binary
ADD https://github.com/just-containers/justc-envdir/releases/download/v${JUSTC_ENVDIR_RELEASE}/justc-envdir-${JUSTC_ENVDIR_RELEASE}-linux-amd64.tar.gz ${TMP_BUILD_DIR}/
ADD https://github.com/just-containers/justc-envdir/releases/download/v${JUSTC_ENVDIR_RELEASE}/justc-envdir-${JUSTC_ENVDIR_RELEASE}-linux-amd64.tar.gz.sig ${TMP_BUILD_DIR}/

# Pull in the trust keys
COPY keys/trust.gpg ${TMP_BUILD_DIR}/

# Patch in source for testing sources...
# Update, install necessary packages, fixup permissions, delete junk
RUN apk add --update s6 s6-portable-utils && \
    apk add --virtual verify gnupg && \
    chmod 700 ${TMP_BUILD_DIR} && \
    cd ${TMP_BUILD_DIR} && \
    gpg --no-options --no-default-keyring --homedir ${TMP_BUILD_DIR} --keyring ./trust.gpg --no-auto-check-trustdb --trust-model always --verify s6-overlay-nobin.tar.gz.sig s6-overlay-nobin.tar.gz && \
    gpg --no-options --no-default-keyring --homedir ${TMP_BUILD_DIR} --keyring ./trust.gpg --no-auto-check-trustdb --trust-model always --verify justc-envdir-${JUSTC_ENVDIR_RELEASE}-linux-amd64.tar.gz.sig justc-envdir-${JUSTC_ENVDIR_RELEASE}-linux-amd64.tar.gz && \
    apk del verify && \
    tar -C / -xzf s6-overlay-nobin.tar.gz && \
    tar -C / -xzf justc-envdir-${JUSTC_ENVDIR_RELEASE}-linux-amd64.tar.gz && \
    cd / && \
    rm -rf /var/cache/apk/* && \
    rm -rf ${TMP_BUILD_DIR}

ENTRYPOINT [ "/init" ]

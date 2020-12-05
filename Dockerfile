# VERSION latest
# AUTHOR:       Thomas Harning Jr <harningt@gmail.com>
# DESCRIPTION:  Alpine linux base image with s6-overlay injected

FROM alpine:latest AS checker
MAINTAINER Thomas Harning Jr <harningt@gmail.com>

# Add binaries necessary for verification
RUN apk add --no-cache gnupg

ENV TMP_BUILD_DIR /tmp/build
# Pull in the trust keys
COPY keys/trust.gpg ${TMP_BUILD_DIR}/

ENV S6_OVERLAY_RELEASE v2.1.0.2
ENV JUSTC_ENVDIR_RELEASE 1.0.0
ENV S6_OVERLAY_PREINIT_RELEASE 1.0.3

# Pull in the overlay binaries
ADD https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_RELEASE}/s6-overlay-nobin.tar.gz ${TMP_BUILD_DIR}/
ADD https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_RELEASE}/s6-overlay-nobin.tar.gz.sig ${TMP_BUILD_DIR}/

# Pull in justc-envdir binary
ADD https://github.com/just-containers/justc-envdir/releases/download/v${JUSTC_ENVDIR_RELEASE}/justc-envdir-${JUSTC_ENVDIR_RELEASE}-linux-amd64.tar.gz ${TMP_BUILD_DIR}/
ADD https://github.com/just-containers/justc-envdir/releases/download/v${JUSTC_ENVDIR_RELEASE}/justc-envdir-${JUSTC_ENVDIR_RELEASE}-linux-amd64.tar.gz.sig ${TMP_BUILD_DIR}/

# Pull in s6-overlay-preinit binary
ADD https://github.com/just-containers/s6-overlay-preinit/releases/download/v${S6_OVERLAY_PREINIT_RELEASE}/s6-overlay-preinit-${S6_OVERLAY_PREINIT_RELEASE}-linux-amd64.tar.gz ${TMP_BUILD_DIR}/
ADD https://github.com/just-containers/s6-overlay-preinit/releases/download/v${S6_OVERLAY_PREINIT_RELEASE}/s6-overlay-preinit-${S6_OVERLAY_PREINIT_RELEASE}-linux-amd64.tar.gz.sig ${TMP_BUILD_DIR}/

# Patch in source for testing sources...
# Update, install necessary packages, fixup permissions, delete junk
WORKDIR ${TMP_BUILD_DIR}

RUN gpg --no-options --no-default-keyring --homedir ${TMP_BUILD_DIR} --keyring ./trust.gpg --no-auto-check-trustdb --trust-model always --verify-files *.sig

FROM alpine:edge

ENV TMP_BUILD_DIR /tmp/build

COPY --from=checker ${TMP_BUILD_DIR}/s6-overlay-nobin.tar.gz ${TMP_BUILD_DIR}/
COPY --from=checker ${TMP_BUILD_DIR}/justc-envdir-*-linux-amd64.tar.gz ${TMP_BUILD_DIR}/
COPY --from=checker ${TMP_BUILD_DIR}/s6-overlay-preinit-*-linux-amd64.tar.gz ${TMP_BUILD_DIR}/

RUN apk add --update s6 s6-portable-utils && \
    cd ${TMP_BUILD_DIR} && \
    tar -C / -xzf s6-overlay-nobin.tar.gz && \
    tar -C / -xzf justc-envdir-*-linux-amd64.tar.gz && \
    tar -C / -xzf s6-overlay-preinit-*-linux-amd64.tar.gz && \
    cd / && \
    rm -rf /var/cache/apk/* && \
    rm -rf ${TMP_BUILD_DIR}

ENTRYPOINT [ "/init" ]

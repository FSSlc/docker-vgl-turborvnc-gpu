# syntax=docker/dockerfile:1.7

ARG BASE_DISTRO=ubuntu2404
ARG NOVNC_VERSION=1.6.0

FROM alpine:3.20 AS downloader
ARG NOVNC_VERSION
ARG TARGETARCH
RUN apk add --no-cache curl tar
RUN mkdir -p /out/noVNC
RUN curl -fsSL "https://github.com/novnc/noVNC/archive/refs/tags/v${NOVNC_VERSION}.tar.gz" \
    -o /tmp/noVNC.tar.gz \
 && tar -xzf /tmp/noVNC.tar.gz -C /out/noVNC --strip-components=1 \
 && rm -f /tmp/noVNC.tar.gz

FROM downloader AS artifacts

FROM ubuntu:24.04 AS base-ubuntu2404
FROM ubuntu:22.04 AS base-ubuntu2204
FROM debian:13 AS base-debian13
FROM debian:12 AS base-debian12
FROM rockylinux:9 AS base-rocky9
FROM rockylinux:8 AS base-rocky8
FROM fedora:40 AS base-fedora40
FROM fedora:39 AS base-fedora39
FROM almalinux:9 AS base-alma9
FROM almalinux:8 AS base-alma8

ARG BASE_DISTRO
FROM base-${BASE_DISTRO} AS runtime

ENV HOME=/root \
    USER=root \
    LOGNAME=root \
    SHELL=/bin/bash \
    VNC_DISPLAY=:1 \
    VNC_GEOMETRY=1920x1080 \
    VNC_DEPTH=24 \
    VNC_PASSWORD=root \
    VNC_RESET_PASSWORD=1 \
    VNC_NOVNC_DIR=/opt/noVNC \
    VNC_EXTRA_ARGS= \
    VGL_DISPLAY=egl0 \
    VGL_COMPRESS=proxy \
    XDG_RUNTIME_DIR=/tmp/runtime-root \
    PATH=/opt/TurboVNC/bin:/opt/VirtualGL/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

COPY --from=artifacts /out/noVNC /tmp/artifacts/noVNC
COPY docker /opt/container

RUN chmod +x /opt/container/*.sh \
    /opt/container/install-runtime.sh \
 && rm -rf /tmp/artifacts

WORKDIR /root
EXPOSE 5801 5901

ENTRYPOINT ["/opt/container/entrypoint.sh"]
CMD ["start"]

# waypipe 0.11 (with --xwls), xwayland-satellite and test clients on Ubuntu 26.04,
# for use on older Ubuntu hosts through bind-mounted sockets.
FROM ubuntu:26.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates gpg-agent software-properties-common \
 && add-apt-repository -y ppa:avengemedia/danklinux \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      waypipe xwayland xwayland-satellite \
      foot xterm x11-utils wayland-utils fonts-dejavu-core tini \
 && rm -rf /var/lib/apt/lists/*

COPY wp-session /usr/local/bin/wp-session
RUN chmod 755 /usr/local/bin/wp-session

# -g: forward signals to the whole process group (waypipe and its children)
ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["waypipe", "--version"]

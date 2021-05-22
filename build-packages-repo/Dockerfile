# CentOS 7.9 2009
FROM centos:7.9.2009 as centos7
ARG OS_VERSION=7
ARG ARCH=x86_64
ARG BUILD_TOOLS="yum-utils createrepo centos-release-gluster epel-release curl"

RUN yum install -q -y $BUILD_TOOLS \
    && yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo \
    && yum makecache && yum update -y -q

RUN curl -sL -o /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v4.9.3/yq_linux_amd64 \
    && chmod a+x /usr/local/bin/yq \
    && curl -sL -o /usr/local/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 \
    && chmod a+x /usr/local/bin/jq

WORKDIR /centos/$OS_VERSION/os/$ARCH
COPY packages.yaml packages.yaml 
RUN yq eval packages.yaml -j | jq -r '.common[],.yum[],.centos[]' | sort -u > packages.list \
    && rpm -qa >> packages.list
RUN cat packages.list | xargs yumdownloader --resolve \
    && createrepo -d .

# Debian 9 stretch
FROM debian:stretch-slim as stretch
ARG OS_VERSION=stretch
ARG ARCH=amd64

ARG DEP_PACKAGES="apt-transport-https ca-certificates curl gnupg aptitude dpkg-dev"
RUN apt update -y -q \
    && apt install -y --no-install-recommends $DEP_PACKAGES \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian ${OS_VERSION} stable" \
    | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt update -y -q

RUN curl -sL -o /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v4.9.3/yq_linux_amd64 \
    && chmod a+x /usr/local/bin/yq \
    && curl -sL -o /usr/local/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 \
    && chmod a+x /usr/local/bin/jq

WORKDIR /debian/${OS_VERSION}
COPY packages.yaml packages.yaml 
RUN yq eval packages.yaml -j | jq -r '.common[],.apt[],.debian[]' | sort -u > packages.list \
    && dpkg --get-selections | grep -v deinstall | cut -f1 >> packages.list

RUN chown -R _apt /debian/$OS_VERSION \
    && cat packages.list | xargs -L1 -I {} apt-cache depends --recurse --no-recommends --no-suggests \
    --no-conflicts --no-breaks --no-replaces --no-enhances {}  | grep '^\w' | sort -u | xargs apt-get download

RUN cd ../ && dpkg-scanpackages $OS_VERSION | gzip -9c > $OS_VERSION/Packages.gz

# Debian 10 buster
FROM debian:buster-slim as buster
ARG OS_VERSION=buster
ARG ARCH=amd64

ARG DEP_PACKAGES="apt-transport-https ca-certificates curl gnupg aptitude dpkg-dev"
RUN apt update -y -q \
    && apt install -y --no-install-recommends $DEP_PACKAGES \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian ${OS_VERSION} stable" \
    | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt update -y -q

RUN curl -sL -o /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v4.9.3/yq_linux_amd64 \
    && chmod a+x /usr/local/bin/yq \
    && curl -sL -o /usr/local/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 \
    && chmod a+x /usr/local/bin/jq

WORKDIR /debian/${OS_VERSION}
COPY packages.yaml packages.yaml 
RUN yq eval packages.yaml -j | jq -r '.common[],.apt[],.debian[]' | sort -u > packages.list \
    && dpkg --get-selections | grep -v deinstall | cut -f1 >> packages.list

RUN chown -R _apt /debian/$OS_VERSION \
    && cat packages.list | xargs -L1 -I {} apt-cache depends --recurse --no-recommends --no-suggests \
    --no-conflicts --no-breaks --no-replaces --no-enhances {}  | grep '^\w' | sort -u | xargs apt-get download

RUN cd ../ && dpkg-scanpackages $OS_VERSION | gzip -9c > $OS_VERSION/Packages.gz

# Ubuntu 18.04 bionic
FROM ubuntu:bionic as bionic
ARG OS_VERSION=bionic
ARG ARCH=amd64

ARG DEP_PACKAGES="apt-transport-https ca-certificates curl gnupg aptitude dpkg-dev"
RUN apt update -y -q \
    && apt install -y --no-install-recommends $DEP_PACKAGES \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu ${OS_VERSION} stable" \
    | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt update -y -q

RUN curl -sL -o /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v4.9.3/yq_linux_amd64 \
    && chmod a+x /usr/local/bin/yq \
    && curl -sL -o /usr/local/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 \
    && chmod a+x /usr/local/bin/jq

WORKDIR /ubuntu/${OS_VERSION}
COPY packages.yaml packages.yaml 
RUN yq eval packages.yaml -j | jq -r '.common[],.apt[],.ubuntu[]' | sort -u > packages.list \
    && dpkg --get-selections | grep -v deinstall | cut -f1 >> packages.list

RUN chown -R _apt /ubuntu/$OS_VERSION \
    && cat packages.list | xargs -L1 -I {} apt-cache depends --recurse --no-recommends --no-suggests \
    --no-conflicts --no-breaks --no-replaces --no-enhances {}  | grep '^\w' | sort -u | xargs apt-get download

RUN cd ../ && dpkg-scanpackages $OS_VERSION | gzip -9c > $OS_VERSION/Packages.gz

# Ubuntu 20.04 focal
FROM ubuntu:focal as focal
ARG OS_VERSION=focal
ARG ARCH=amd64

ARG DEP_PACKAGES="apt-transport-https ca-certificates curl gnupg aptitude dpkg-dev"
RUN apt update -y -q \
    && apt install -y --no-install-recommends $DEP_PACKAGES \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu ${OS_VERSION} stable" \
    | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt update -y -q

RUN curl -sL -o /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v4.9.3/yq_linux_amd64 \
    && chmod a+x /usr/local/bin/yq \
    && curl -sL -o /usr/local/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 \
    && chmod a+x /usr/local/bin/jq

WORKDIR /ubuntu/${OS_VERSION}
COPY packages.yaml packages.yaml 
RUN yq eval packages.yaml -j | jq -r '.common[],.apt[],.ubuntu[]' | sort -u > packages.list \
    && dpkg --get-selections | grep -v deinstall | cut -f1 >> packages.list

RUN chown -R _apt /ubuntu/$OS_VERSION \
    && cat packages.list | xargs -L1 -I {} apt-cache depends --recurse --no-recommends --no-suggests \
    --no-conflicts --no-breaks --no-replaces --no-enhances {}  | grep '^\w' | sort -u | xargs apt-get download

RUN cd ../ && dpkg-scanpackages $OS_VERSION | gzip -9c > $OS_VERSION/Packages.gz

FROM scratch
COPY --from=centos7 /centos /centos
COPY --from=stretch /debian /debian
COPY --from=buster /debian /debian
COPY --from=bionic /ubuntu /ubuntu
COPY --from=focal /ubuntu /ubuntu

# Build offline packages repo

## Support system

- CentOS 7
- Debian 9 stretch
- Debian 10 buster
- Ubuntu 18.04 bionic
- Ubuntu 20.04 focal

## Build progress

- Config repo and install some build tools.
- Gen packages list to packages.list.
- Download packages by packages.list.
- Build packages index file.
- Copy all os packages to an empty image.
- Export images to local path

## Archive

### Dockerfile

### packages.list

```yaml
---
common:
  - vim
  - tcpdump
  - sshpass
  - rsync
  - curl
  - wget
  - tree
  - socat
  - unzip
  - bash-completion
  - openssl

yum:
  - nfs-utils
  - yum-utils
  - createrepo
  - epel-release
  - containerd.io
  - centos-release-gluster

apt:
  - nfs-common
  - apt-transport-https
  - ca-certificates
  - gnupg
  - lsb-release
  - software-properties-common
  - aptitude
  - dpkg-dev
  - gnupg2

centos:
  - centos-release

debian:
  - debian-builder

ubuntu:
  - ubuntu-dev-tools

debian-buster:
  - docker-ce=5:19.03.15~3-0~debian-buster

ubuntu-focal:
  - docker-ce=5:19.03.15~3-0~ubuntu-focal
```

- common

- yum

- apt

- centos

- debian

- ubuntu

- debian-buster

Some package's name

- ubuntu-bionic

## Install package

### CentOS

### Debian

### Ubuntu

## Other

**Not support GPG authentication**

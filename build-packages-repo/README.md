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
  - ansible
  - vim
  - tmux
  - htop
  - ncdu
  - tcpdump
  - nload
  - sshpass
  - rsync
  - curl
  - wget
  - tree
  - glusterfs-client
  - glusterfs-server
  - lvm2
  - ceph-common
  - jq
  - ipvsadm
  - ipset
  - socat
  - unzip
  - e2fsprogs
  - xfsprogs
  - ebtables
  - bash-completion
  - openssl

yum:
  - nfs-utils
  - yum-utils
  - createrepo
  - centos-release-gluster
  - epel-release
  - glusterfs
  - glusterfs-cli
  - docker-ce
  - docker-ce-cli
  - containerd.io

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
  - glusterfs-server
  - docker-ce
  - docker-ce-cli

centos:
  - nfs-utils

debian:
  - nfs-common

ubuntu:
  - nfs-common
```

- common

- yum

- apt

- centos

- debian

- ubuntu

- debian-buster

- ubuntu-bionic

## Install package

### CentOS

### Debian

### Ubuntu

## Other

**Not support GPG authentication**

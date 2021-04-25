#!/bin/bash
set -eo pipefail

IMAGES_DIR="$1"
REGISTRY_DIR="$2"
BLOBS_PATH="docker/registry/v2/blobs"
REPO_PATH="docker/registry/v2/repositories"

rm -rf ${REGISTRY_DIR}
for image in $(find ${IMAGES_DIR} -type f | sed -n "s|${IMAGES_DIR}/||g;s|/manifest.json||p" | sort -u); do
    image_name=${image%%:*}
    image_tag=${image##*:}
    manifest="${IMAGES_DIR}/${image}/manifest.json"
    manifest_sha256=$(sha256sum ${manifest} | awk '{print $1}')
    mkdir -p ${BLOBS_PATH}/sha256/${manifest_sha256:0:2}/${manifest_sha256}
    ln -f ${manifest} ${BLOBS_PATH}/sha256/${manifest_sha256:0:2}/${manifest_sha256}/data

    # make image repositories dir
    mkdir -p ${REPO_PATH}/${image_name}/{_uploads,_layers,_manifests}
    mkdir -p ${REPO_PATH}/${image_name}/_manifests/revisions/sha256/${manifest_sha256}
    mkdir -p ${REPO_PATH}/${image_name}/_manifests/tags/${image_tag}/{current,index/sha256}
    mkdir -p ${REPO_PATH}/${image_name}/_manifests/tags/${image_tag}/index/sha256/${manifest_sha256}

    # create image tag manifest link file
    echo -n "sha256:${manifest_sha256}" > ${REPO_PATH}/${image_name}/_manifests/tags/${image_tag}/current/link
    echo -n "sha256:${manifest_sha256}" > ${REPO_PATH}/${image_name}/_manifests/revisions/sha256/${manifest_sha256}/link
    echo -n "sha256:${manifest_sha256}" > ${REPO_PATH}/${image_name}/_manifests/tags/${image_tag}/index/sha256/${manifest_sha256}/link

    # move image layers file to registry blobs dir
    for layer in $(sed '/v1Compatibility/d' ${manifest} | grep -Eo "\b[a-f0-9]{64}\b"); do
        mkdir -p ${BLOBS_PATH}/sha256/${layer:0:2}/${layer}
        mkdir -p ${REPO_PATH}/${image_name}/_layers/sha256/${layer}
        echo -n "sha256:${layer}" > ${REPO_PATH}/${image_name}/_layers/sha256/${layer}/link
        ln -f ${IMAGES_DIR}/${image}/${layer} ${BLOBS_PATH}/sha256/${layer:0:2}/${layer}/data
    done
done

#!/bin/bash
set -eo pipefail

IMAGES_LIST="$1"
REGISTRY_PATH="$2"
OUTPUT_DIR="$3"
BLOB_DIR="docker/registry/v2/blobs/sha256"
REPO_DIR="docker/registry/v2/repositories"

rm -rf ${OUTPUT_DIR}; mkdir -p ${OUTPUT_DIR}
for image in $(find ${IMAGES_LIST} -type f -name "*.list" | xargs grep -Ev '^#|^/' | grep ':'); do
    image_tag=${image##*:}
    image_name=${image%%:*}
    tag_link=${REGISTRY_PATH}/${REPO_DIR}/${image_name}/_manifests/tags/${image_tag}/current/link
    manifest_sha256=$(sed 's/sha256://' ${tag_link})
    manifest=${REGISTRY_PATH}/${BLOB_DIR}/${manifest_sha256:0:2}/${manifest_sha256}/data
    mkdir -p ${OUTPUT_DIR}/${BLOB_DIR}/${manifest_sha256:0:2}/${manifest_sha256}
    ln -f ${manifest} ${OUTPUT_DIR}/${BLOB_DIR}/${manifest_sha256:0:2}/${manifest_sha256}/data

    # make image repositories dir
    mkdir -p ${OUTPUT_DIR}/${REPO_DIR}/${image_name}/{_uploads,_layers,_manifests}
    mkdir -p ${OUTPUT_DIR}/${REPO_DIR}/${image_name}/_manifests/revisions/sha256/${manifest_sha256}
    mkdir -p ${OUTPUT_DIR}/${REPO_DIR}/${image_name}/_manifests/tags/${image_tag}/{current,index/sha256}
    mkdir -p ${OUTPUT_DIR}/${REPO_DIR}/${image_name}/_manifests/tags/${image_tag}/index/sha256/${manifest_sha256}

    # create image tag manifest link file
    echo -n "sha256:${manifest_sha256}" > ${OUTPUT_DIR}/${REPO_DIR}/${image_name}/_manifests/tags/${image_tag}/current/link
    echo -n "sha256:${manifest_sha256}" > ${OUTPUT_DIR}/${REPO_DIR}/${image_name}/_manifests/revisions/sha256/${manifest_sha256}/link
    echo -n "sha256:${manifest_sha256}" > ${OUTPUT_DIR}/${REPO_DIR}/${image_name}/_manifests/tags/${image_tag}/index/sha256/${manifest_sha256}/link
    for layer in $(sed '/v1Compatibility/d' ${manifest} | grep -Eo '\b[a-f0-9]{64}\b' | sort -u); do
        mkdir -p ${OUTPUT_DIR}/${BLOB_DIR}/${layer:0:2}/${layer}
        mkdir -p ${OUTPUT_DIR}/${REPO_DIR}/${image_name}/_layers/sha256/${layer}
        ln -f ${BLOB_DIR}/${layer:0:2}/${layer}/data ${OUTPUT_DIR}/${BLOB_DIR}/${layer:0:2}/${layer}/data
        echo -n "sha256:${layer}" > ${OUTPUT_DIR}/${REPO_DIR}/${image_name}/_layers/sha256/${layer}/link
    done
done

#!/bin/bash
set -eo pipefail

REGISTRY_PATH="$1"
OUTPUT_DIR="$2"

BLOB_DIR="docker/registry/v2/blobs/sha256"
REPO_DIR="docker/registry/v2/repositories"

cd ${REGISTRY_PATH}
rm -rf ${OUTPUT_DIR}; mkdir -p ${OUTPUT_DIR}
for image in $(find ${REPO_DIR} -type d -name 'current'); do
    image_tag=$(echo ${image} | sed 's|.*_manifests/tags/||g;s|/current||g')
    image_name=$(echo ${image} | sed 's|.*/repositories/||g;s|/_manifests/.*||g')
    manifest_sha256=$(sed 's/sha256://' ${image}/link)
    manifest="${BLOB_DIR}/${manifest_sha256:0:2}/${manifest_sha256}/data"
    mkdir -p ${OUTPUT_DIR}/${image_name}:${image_tag}
    ln -f ${manifest} ${OUTPUT_DIR}/${image_name}:${image_tag}/manifest.json
    for layer in $(sed '/v1Compatibility/d' ${manifest} | grep -Eo '\b[a-f0-9]{64}\b' | sort -u); do
        ln -f ${BLOB_DIR}/${layer:0:2}/${layer}/data ${OUTPUT_DIR}/${image_name}:${image_tag}/${layer}
    done
done

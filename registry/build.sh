#!/bin/bash
GREEN_COL="\\033[32;1m"
RED_COL="\\033[1;31m"
NORMAL_COL="\\033[0;39m"

INPUT=$1
SOURCE_REGISTRY=$2
TARGET_REGISTRY=$3
REGISTRY_PATH=$2
OUTPUT_DIR=$3

: ${IMAGES_DIR:="images"}
: ${IMAGES_LIST_DIR:="."}
: ${TARGET_REGISTRY:="hub.k8s.li"}
: ${SOURCE_REGISTRY:="docker.io"}
: ${REGISTRY_PATH:="/var/lib/registry"}
: ${OUTPUT_DIR:="/var/lib/registry/images"}
: ${SOURCE_IMAGES_YAML:="images_origin.yaml"}

BLOBS_PATH="docker/registry/v2/blobs/sha256"
REPO_PATH="docker/registry/v2/repositories"

set -eo pipefail

CURRENT_NUM=0
ALL_IMAGES="$(sed -n '/#/d;s/:/:/p' ${IMAGES_LIST_DIR}/images_*.list | grep -E '^library|^release' | sort -u)"
TOTAL_NUMS=$(echo "${ALL_IMAGES}" | wc -l)

skopeo_copy() {
    if skopeo copy --insecure-policy --src-tls-verify=false --dest-tls-verify=false \
    --override-arch amd64 --override-os linux -q docker://$1 docker://$2; then
        echo -e "$GREEN_COL Progress: ${CURRENT_NUM}/${TOTAL_NUMS} sync $1 to $2 successful $NORMAL_COL"
    else
        echo -e "$RED_COL Progress: ${CURRENT_NUM}/${TOTAL_NUMS} sync $1 to $2 failed $NORMAL_COL"
        exit 2
    fi
}

skopeo_sync() {
    if skopeo sync --insecure-policy --src-tls-verify=false --dest-tls-verify=false \
    --override-arch amd64 --override-os linux --src docker --dest dir $1 $2 > /dev/null; then
        echo -e "$GREEN_COL Progress: ${CURRENT_NUM}/${TOTAL_NUMS} sync $1 to $2 successful $NORMAL_COL"
    else
        echo -e "$RED_COL Progress: ${CURRENT_NUM}/${TOTAL_NUMS} sync $1 to $2 failed $NORMAL_COL"
        exit 2
    fi
}

sync_images() {
    for image in ${ALL_IMAGES}; do
        let CURRENT_NUM=${CURRENT_NUM}+1
        image_name=${image%%:*}
        image_tag=${image##*:}
        image_repo=${image%%/*}
        skopeo_copy ${origin_image}:${image_tag} ${TARGET_REGISTRY}/${image}
    done
}

convert_images() {
    rm -rf ${IMAGES_DIR}; mkdir -p ${IMAGES_DIR}
    for image in ${ALL_IMAGES}; do
        let CURRENT_NUM=${CURRENT_NUM}+1
        image_name=${image%%:*}
        image_tag=${image##*:}
        skopeo_sync ${SOURCE_REGISTRY}/${image} ${IMAGES_DIR}/${image%%/*}
        manifest="${IMAGES_DIR}/${image}/manifest.json"
        manifest_sha256=$(sha256sum ${manifest} | awk '{print $1}')
        mkdir -p ${BLOBS_PATH}/${manifest_sha256:0:2}/${manifest_sha256}
        ln -f ${manifest} ${BLOBS_PATH}/${manifest_sha256:0:2}/${manifest_sha256}/data

        # make image repositories dir
        mkdir -p ${REPO_PATH}/${image_name}/{_uploads,_layers,_manifests}
        mkdir -p ${REPO_PATH}/${image_name}/_manifests/revisions/sha256/${manifest_sha256}
        mkdir -p ${REPO_PATH}/${image_name}/_manifests/tags/${image_tag}/{current,index/sha256}
        mkdir -p ${REPO_PATH}/${image_name}/_manifests/tags/${image_tag}/index/sha256/${manifest_sha256}

        # create image tag manifest link file
        echo -n "sha256:${manifest_sha256}" > ${REPO_PATH}/${image_name}/_manifests/tags/${image_tag}/current/link
        echo -n "sha256:${manifest_sha256}" > ${REPO_PATH}/${image_name}/_manifests/revisions/sha256/${manifest_sha256}/link
        echo -n "sha256:${manifest_sha256}" > ${REPO_PATH}/${image_name}/_manifests/tags/${image_tag}/index/sha256/${manifest_sha256}/link

        # link image layers file to registry blobs dir
        for layer in $(sed '/v1Compatibility/d' ${manifest} | grep -Eo "\b[a-f0-9]{64}\b"); do
            mkdir -p ${BLOBS_PATH}/${layer:0:2}/${layer}
            mkdir -p ${REPO_PATH}/${image_name}/_layers/sha256/${layer}
            echo -n "sha256:${layer}" > ${REPO_PATH}/${image_name}/_layers/sha256/${layer}/link
            ln -f ${IMAGES_DIR}/${image}/${layer} ${BLOBS_PATH}/${layer:0:2}/${layer}/data
        done
    done
}

select_images(){
    rm -rf ${OUTPUT_DIR}; mkdir -p ${OUTPUT_DIR}
    for image in ${ALL_IMAGES}; do
        image_tag=${image##*:}
        image_name=${image%%:*}
        tag_link=${REGISTRY_PATH}/${REPO_PATH}/${image_name}/_manifests/tags/${image_tag}/current/link
        manifest_sha256=$(sed 's/sha256://' ${tag_link})
        manifest=${REGISTRY_PATH}/${BLOBS_PATH}/${manifest_sha256:0:2}/${manifest_sha256}/data
        mkdir -p ${OUTPUT_DIR}/${BLOBS_PATH}/${manifest_sha256:0:2}/${manifest_sha256}
        ln -f ${manifest} ${OUTPUT_DIR}/${BLOBS_PATH}/${manifest_sha256:0:2}/${manifest_sha256}/data

        # make image repositories dir
        mkdir -p ${OUTPUT_DIR}/${REPO_PATH}/${image_name}/{_uploads,_layers,_manifests}
        mkdir -p ${OUTPUT_DIR}/${REPO_PATH}/${image_name}/_manifests/revisions/sha256/${manifest_sha256}
        mkdir -p ${OUTPUT_DIR}/${REPO_PATH}/${image_name}/_manifests/tags/${image_tag}/{current,index/sha256}
        mkdir -p ${OUTPUT_DIR}/${REPO_PATH}/${image_name}/_manifests/tags/${image_tag}/index/sha256/${manifest_sha256}

        # create image tag manifest link file
        echo -n "sha256:${manifest_sha256}" > ${OUTPUT_DIR}/${REPO_PATH}/${image_name}/_manifests/tags/${image_tag}/current/link
        echo -n "sha256:${manifest_sha256}" > ${OUTPUT_DIR}/${REPO_PATH}/${image_name}/_manifests/revisions/sha256/${manifest_sha256}/link
        echo -n "sha256:${manifest_sha256}" > ${OUTPUT_DIR}/${REPO_PATH}/${image_name}/_manifests/tags/${image_tag}/index/sha256/${manifest_sha256}/link
        for layer in $(sed '/v1Compatibility/d' ${manifest} | grep -Eo '\b[a-f0-9]{64}\b' | sort -u); do
            mkdir -p ${OUTPUT_DIR}/${BLOBS_PATH}/${layer:0:2}/${layer}
            mkdir -p ${OUTPUT_DIR}/${REPO_PATH}/${image_name}/_layers/sha256/${layer}
            ln -f ${REGISTRY_PATH}/${BLOBS_PATH}/${layer:0:2}/${layer}/data ${OUTPUT_DIR}/${BLOBS_PATH}/${layer:0:2}/${layer}/data
            echo -n "sha256:${layer}" > ${OUTPUT_DIR}/${REPO_PATH}/${image_name}/_layers/sha256/${layer}/link
        done
    done

}

case $INPUT in
    sync )
        sync_images
    ;;
    build )
        convert_images
    ;;
    select )
        select_images
    ;;
    docker )
        DOCKER_BUILDKIT=1 docker build -o type=local,dest=$PWD -f Dockerfile .
    ;;
esac
